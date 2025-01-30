#!/bin/bash

# Custom script to sync/restore data from a remote backup server to local directory.
#
# This can be used to sync the current system from the backup, in which case it is
# recommended that this be run in text mode with little or no other running user
# programs else update of their configuration dynamically can cause unknown effects
# like logout in the middle of sync.
#
# Alternatively one can boot off a USB, for example, mount the system to be upgraded
# somewhere, then run the script providing the second <DEST_ROOT> argument to the script.
#
# The installation can be an existing one being used or an entirely fresh one.
# The script makes no assumption of any existing data on the system apart from
# a minimal Ubuntu based one having dpkg/apt (optionally apt-fast) and basic
# utilities rsync, ssh, ssh-agent with ssh-add, gpg, git, curl (and basic ones
#   like sudo/awk/sed/comm that are present in all usable installations).
# It makes use of mrpsync.sh script to launch parallel rsync processes which is
# downloaded, if not present, from its github repository.

set -e

# ensure that system path is always searched first for all the utilities
export PATH="/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/sbin:/usr/local/bin:$PATH"

# Before anything, copy this script to /tmp if not there and run from there to
# avoid overwrite by rsync later which can cause all kinds of trouble
SCRIPT="$(basename "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sync_data_conf=/tmp/sync-data
log_file=/tmp/sync-data.log
err_file=/tmp/sync-data.err
pkgs_err=/tmp/sync-data-pkgs.err

if [ "$SCRIPT_DIR" != "/tmp" ]; then
  cp -f "$SCRIPT_DIR/$SCRIPT" /tmp/
  cp -f "$SCRIPT_DIR/enc-init.sh" "$SCRIPT_DIR/enc-finish.sh" /tmp/
  cp -rfL "$SCRIPT_DIR/../../.config/sync-data" $sync_data_conf
  /bin/bash /tmp/$SCRIPT "$@" > >(tee $log_file) 2> >(tee $err_file)
  exit $?
fi

sync_root=
sync_user=
home_dir=$HOME
def_remote_root=$USER@$BORG_BACKUP_SERVER:backup.sync
fg_red='\033[31m'
fg_green='\033[32m'
fg_orange='\033[33m'
fg_reset='\033[00m'
rsync_common_options='-aHSOJ --info=progress2 --zc=zstd --zl=1'
sync_enc_data=/tmp/others.txz
ssh_key_created=0
auth_keys_orig=authorized_keys.sync-bak
ssh_agent_started=0
unpack_gpg_key=0

function usage() {
  echo
  echo "Usage: $SCRIPT [--help] [--user=USER] [<SOURCE_ROOT>] [<DEST_ROOT>]"
  echo
  echo "--help           show this usage"
  echo "--user=USER      user name on source and destination if different from '$USER'"
  echo
  echo "  SOURCE_ROOT     source location for the sync (default: $def_remote_root)"
  echo "  DEST_ROOT       desination root directory to sync; empty means /"
  echo
  echo "NOTE: the script assumes that none of the argument values have whitespace characters"
}

function cleanup() {
  echo -e "${fg_red}Cleaning up...$fg_reset"
  rm -rf /tmp/$SCRIPT /tmp/enc-init.sh /tmp/enc-finish.sh $sync_data_conf /tmp/mprsync.sh $pkgs_err
  rm -rf $HOME/passwd $HOME/group
  if [ $home_dir != $HOME ]; then
    rm -rf $HOME/pkgs
  fi
  [ -e $sync_enc_data ] && shred -u $sync_enc_data
  if [ -f $home_dir/enc.dirs.orig ]; then
    sudo rm -f $home_dir/enc.dirs
    sudo mv $home_dir/enc.dirs.orig $home_dir/enc.dirs
  fi
  if [ $ssh_key_created -eq 1 -a -n "$keyfile" ]; then
    remote_server=${remote_root%:*}
    ssh $remote_server mv -f .ssh/$auth_keys_orig .ssh/authorized_keys || true
    ssh-add -d $keyfile
    rm -f $keyfile*
  fi
  if [ $ssh_agent_started -eq 1 ]; then
    kill $SSH_AGENT_PID
  fi
  if [ $unpack_gpg_key -eq 1 -a $home_dir != $HOME ]; then
    find $HOME/.gnupg -type f -print0 | xargs -0 shred -u
    rm -rf $HOME/.gnupg
  fi
}

# argument processing

if [ "$1" = "--help" ]; then
  usage
  exit 1
fi
if [[ "$1" = --user=* ]]; then
  sync_user="${1/*=/}"
  shift
fi
[ $# -gt 2 ] && { echo -e "${fg_red}Unexpected args:" "$@"$fg_reset; usage; exit 1; }
if [ $# -ge 1 ]; then
  remote_root=$1
  if [ -z "$remote_root" ]; then
    echo -e "${fg_red}Expected non-empty source location$fg_reset"
    usage
    exit 1
  fi
elif [ -z "$BORG_BACKUP_SERVER" ]; then
  echo -e "${fg_red}Neither source location specified, nor \$BORG_BACKUP_SERVER is set!$fg_reset"
  usage
  exit 1
else
  remote_root=$def_remote_root
fi
[ $# -eq 2 -a "$2" != "/" ] && sync_root=$2
sync_root_fs=${sync_root:-/}
sync_etc=$sync_root/etc

if [ -n "$sync_root" ]; then
  divert_root_arg="--root $sync_root"
  dpkg_root_arg="--root=$sync_root"
  chroot_arg="chroot $sync_root"
fi
if [ -n "$sync_user" ]; then
  home_dir=$(sudo $chroot_arg getent passwd $sync_user | cut -d: -f6)
  sync_user_group=$(sudo $chroot_arg id -gn $sync_user)
  echo -e "${fg_green}Using '$home_dir' as the HOME for backup user '$sync_user'$fg_reset"
  echo
else
  sync_user=$USER
  sync_user_group=$(id -gn $sync_user)
fi
if [ -n "$sync_root" ]; then
  chroot_arg_user="sudo chroot --userspec=$sync_user:$sync_user_group $sync_root"
fi
remote_home=$remote_root$home_dir
home_dir_local=$home_dir
home_dir=$sync_root$home_dir

trap "cleanup" 0 1 2 3 4 5 6 7 8 10 11 12 14 15

# First deal with package modifications since they may have new files from backup
# which should be overwritten by the backup (else if /etc file is synced from backup,
#   for example, and also present in package, then package install will fail)

echo -e "${fg_green}Output logged to $log_file, errors to $err_file.$fg_reset"
echo

# Install or update packages used by the script

sudo apt-get update
sudo apt-get install -y rsync gpg openssh-client coreutils util-linux mawk sed tar curl sudo
sudo apt-get install -y apt dpkg

# Start ssh-agent if it does not exist and set it up

if [ -z "$SSH_AUTH_SOCK" -o ! -e "$SSH_AUTH_SOCK" ]; then
  echo -e "${fg_orange}No usable ssh-agent found. It is hightly recommended to start one.$fg_reset"
  echo -en "${fg_orange}Should one be started and configured (Y/n)? $fg_reset"
  if read resp && [ "$resp" != n -a "$resp" != N ]; then
    eval $(ssh-agent -s)
    ssh_agent_started=1
  fi
fi
AWK=awk
type -p mawk >/dev/null && AWK=mawk
# check and add keys if not added (only RSA and ED25519 keys are checked)
if [ -r $HOME/.ssh/id_rsa ]; then
  keyfile=$HOME/.ssh/id_rsa
elif [ -r $HOME/.ssh/id_ed25519 ]; then
  keyfile=$HOME/.ssh/id_ed25519
else
  remote_server=${remote_root%:*}
  echo -en "${fg_orange}No ssh private key found for use on ssh server. "
  echo "Without public key auth, every rsync process will ask for password."
  echo -en "Should one be generated and added to '$remote_server' (y/N)? $fg_reset"
  if read resp && [ "$resp" = y -o "$resp" = Y ]; then
    keyfile=$HOME/.ssh/id_ed25519
    ssh-keygen -o -a 100 -t ed25519 -f $keyfile
    cat $keyfile.pub | ssh -o PubkeyAuthentication=no $remote_server \
      "mv -f .ssh/authorized_keys .ssh/$auth_keys_orig &&
       cat .ssh/$auth_keys_orig - > .ssh/authorized_keys && chmod 400 .ssh/authorized_keys"
    ssh_key_created=1
  fi
fi
if [ -n "$keyfile" ]; then
  fp=$(ssh-keygen -l -f $keyfile | $AWK '{ print $2 }')
  if [ -z "$fp" ] || ! ssh-add -l | grep -qwF "$fp"; then
    ssh-add $keyfile
  fi
fi

# Sync package lists and apt configuration.
# Also fetch and extract the gnupg encrypted data so that the password, if required,
# can be obtained now and user can come back leisurely after the full sync is done
# (else gnupg password popup can timeout so user will need to keep an eye on sync being finished)

APT_FAST=apt-get
if sudo $chroot_arg which apt-fast >/dev/null; then
  APT_FAST=apt-fast
elif sudo $chroot_arg which add-apt-repository >/dev/null; then
  echo -e "${fg_green}Installing apt-fast for faster downloads.$fg_reset"
  sudo $chroot_arg add-apt-repository ppa:apt-fast/stable
  sudo $chroot_arg apt-get update || true
  sudo DEBIAN_FRONTEND=noninteractive $chroot_arg apt-get install -y apt-fast
  APT_FAST=apt-fast
fi

echo -e "${fg_green}Updating package lists, sync packages and fetch encrypted data.$fg_reset"

# If gpg secret key is not present, then fetch the .gnupg encrypted tar

enc_bundles=$remote_home/Documents/others.key.gpg
if ! gpg --quiet --list-secret-key sumwale@gmail.com >/dev/null 2>/dev/null; then
  enc_bundles="$enc_bundles $remote_home/Documents/rest.key.gpg"
  unpack_gpg_key=1
fi
# most rsync calls will use sudo since the current user's UID may be different from that
# of the backup user whose data is being synced; '-E' option is to enable using
# current user's ssh key for remote server public key authentication
rsync $rsync_common_options --delete $remote_root/etc/group $remote_root/etc/passwd \
  $remote_home/pkgs $enc_bundles $HOME/
sudo -E rsync $rsync_common_options --exclude-from=$sync_data_conf/excludes-root.list \
  $remote_root/etc/apt/ $sync_etc/apt/
sudo -E rsync $rsync_common_options --exclude-from=$sync_data_conf/excludes-root.list \
  $remote_root/usr/share/keyrings/ $sync_root/usr/share/keyrings/
# check for ubuntu pro repositories and if they are accessible, else remove them
if compgen -G "$sync_etc/apt/sources.list.d/ubuntu-esm-*" >/dev/null; then
  pro_status=$(sudo $chroot_arg pro status --format=yaml | $AWK '/attached:/ { print $2 }')
  if [ "$pro_status" != true ]; then
    echo -e "${fg_orange}Removing Ubuntu Pro repositories since it is not enabled.$fg_reset"
    sudo rm -f $sync_etc/apt/sources.list.d/ubuntu-esm-*
  fi
fi
# enable 32-bit packages and update package lists after the changes to apt configuration
sudo $chroot_arg dpkg --add-architecture i386
sudo $chroot_arg apt-get update || true

if [ $unpack_gpg_key -eq 1 ]; then
  find $HOME/.gnupg -type f -print0 | xargs -0 shred -u
  rm -rf $HOME/.gnupg/*
  gpg --decrypt $HOME/rest.key.gpg | tar --strip-components=2 -C $HOME -xpSJf -
  shred -u $HOME/rest.key.gpg
  # copy over gnupg keys from host setup if required and link gpg.conf to the one in config repo
  if [ $home_dir != $HOME ]; then
    $chroot_arg_user mkdir -p $home_dir_local/.gnupg
    $chroot_arg_user chmod 0700 $home_dir_local/.gnupg
    sudo find $home_dir/.gnupg -type f -print0 | sudo xargs -0 shred -u
    sudo rm -rf $home_dir/.gnupg/*
    sudo cp -a $HOME/.gnupg/* $home_dir/.gnupg/.
    sudo rm -f $home_dir/.gnupg/gpg.conf
    sudo ln -s ../config/.gnupg/gpg.conf $home_dir/.gnupg/gpg.conf
    sudo $chroot_arg chown -R $sync_user:$sync_user_group $home_dir_local/.gnupg
  fi
fi
gpg --decrypt $HOME/others.key.gpg > $sync_enc_data
shred -u $HOME/others.key.gpg

# Apply diversions recorded in the backup.

echo -e "${fg_green}Applying any changes to local diversions.$fg_reset"
$AWK -v root=$sync_root -v root_arg="$divert_root_arg" '{
  diversion = $0; getline
  divert_to = $0; getline
  if ($0 == ":") {
    system("sudo /bin/sh -c \"mv -f " root diversion " " root diversion ".divert 2>/dev/null; " \
      "dpkg-divert " root_arg " --local --remove --rename --divert " divert_to " " diversion "\"")
  }
}' $sync_root/var/lib/dpkg/diversions
$AWK -v root=$sync_root -v root_arg="$divert_root_arg" '{
  diversion = $0; getline
  divert_to = $0; getline
  if ($0 == ":") {
    system("sudo /bin/sh -c \"mkdir -p `dirname " root divert_to \
      "`; dpkg-divert " root_arg " --local --add --rename --divert " divert_to " " diversion "\"")
    system("sudo /bin/sh -c \"[ -f " diversion ".divert ] && mv -f " \
      diversion ".divert " diversion "\"")
  }
}' $HOME/pkgs/deb-diversions

# Compare host machine packages with the backup and offer to apply any changes.

# first fix any broken stuff
sudo DEBIAN_FRONTEND=noninteractive $chroot_arg dpkg --configure -a
sudo DEBIAN_FRONTEND=noninteractive $chroot_arg apt-get install -f --purge
echo -e "${fg_green}Comparing packages on this host with the backup.$fg_reset"
# "apt-mark showinstall" does not include arch in package names, so better to use
# "dpkg -l" rather than curating their outputs for arch
new_pkgs=$(sed -n 's/^ii\s\+\(\S\+\).*$/\1/p' $HOME/pkgs/deb.list | sort)
pkg_diffs=$(comm -3 <(echo "$new_pkgs") \
                    <(dpkg -l $dpkg_root_arg | sed -n 's/^ii\s\+\(\S\+\).*$/\1/p' | sort) |
  grep -vwE 'fprintd|libfprint|command-configure|srvadmin' |
  sed 's/^\</INSTALL: /;s/^\s\+/PURGE: /')
if [ -n "$pkg_diffs" ]; then
  echo -e "${fg_orange}Changes detected, see the following package modifications.$fg_reset"
  install_pkgs=$(echo "$pkg_diffs" | sed -n 's/^INSTALL: //p')
  purge_pkgs=$(echo "$pkg_diffs" | sed -n 's/^PURGE: //p')
  if [ -n "$install_pkgs" ]; then
    echo -e New packages to be installed: $fg_green$install_pkgs$fg_reset
  fi
  if [ -n "$purge_pkgs" ]; then
    echo -e Packages to be removed and purged: $fg_red$purge_pkgs$fg_reset
  fi
  echo -en "${fg_orange}Perform the above changes (y/N)? $fg_reset"
  if read resp && [ "$resp" = y -o "$resp" = Y ]; then
    if [ -n "$install_pkgs" ]; then
      # unfortunately apt provides no way to skip unavailable packages (e.g. separately downloaded
      #   in deb-local and elsewhere), so need to check for the available ones
      selected_pkgs=$(sudo $chroot_arg apt-cache -q=0 show $install_pkgs 2> $pkgs_err |
        $AWK '/^Package: / {
          pkg = $2
          arch = ""
          while (getline != 0) {
            if ($1 == "Architecture:") {
              arch = $2
              break
            }
          }
          if (!arch) print pkg
          else print pkg ":" arch
        }' | uniq) # using uniq to filter dups is much faster than --no-all-versions
      if [ -s $pkgs_err ]; then
        skipped_pkgs=$(sed -n \
          "s/.* package '\([^']*\)'.*/\1/p;s/.*Unable to locate.* \(\S\+\)$/\1/p" $pkgs_err)
        echo -e "${fg_red}Skipping the following unavailable packages: "$skipped_pkgs$fg_reset
      fi
      if [ -n "$selected_pkgs" ]; then
        sudo DEBIAN_FRONTEND=noninteractive $chroot_arg $APT_FAST install -y --purge $selected_pkgs
      fi
    fi
    if [ -n "$purge_pkgs" ]; then
      sudo DEBIAN_FRONTEND=noninteractive $chroot_arg apt-get purge -y $purge_pkgs
    fi
    # mark the ones in deb-explicit.list as manually installed while the rest as auto
    sudo $chroot_arg apt-mark auto $new_pkgs || true
    sudo $chroot_arg apt-mark manual $(cat $HOME/pkgs/deb-explicit.list) || true
    sudo DEBIAN_FRONTEND=noninteractive $chroot_arg apt-get autopurge || true
  fi
fi
sudo DEBIAN_FRONTEND=noninteractive $chroot_arg $APT_FAST dist-upgrade --purge || true
sudo $chroot_arg $APT_FAST clean
if [ $home_dir != $HOME ]; then
  rm -rf $HOME/pkgs
fi

# Check for any new system users or groups (/etc/group and /etc/passwd are deliberately
#   not synced since IDs may have changed for the same user/group names)

user_conf=$sync_etc/adduser.conf
last_sys_uid=$(sed -n 's/^\s*LAST_SYSTEM_UID\s*=\s*["'\'']\?\([0-9]*\).*/\1/p' $user_conf)
last_sys_uid=${last_sys_uid:-999}
last_sys_gid=$(sed -n 's/^\s*LAST_SYSTEM_GID\s*=\s*["'\'']\?\([0-9]*\).*/\1/p' $user_conf)
last_sys_gid=${last_sys_gid:-999}

function user_gid() {
  # args: <user> <passwd file>
  $AWK -F: "{ if (\$1 == \"$1\") print \$4 }" "$2"
}
function group_name() {
  # args: <gid> <group file>
  $AWK -F: "{ if (\$3 == \"$1\") print \$1 }" "$2"
}
function user_groups() {
  # args: <user> <primary gid> <group file>
  $AWK -F: "{ if (\$3 != \"$2\" && \$4 ~ /(^|,)$1(,|$)/) printf \"%s,\",\$1 }" "$3" | sed 's/,$//'
}

gid_awk_cmd="{ if (\$3 <= $last_sys_gid) print \$1 }"
new_sys_groups=$(comm -13 <($AWK -F: "$gid_awk_cmd" $sync_etc/group | sort) \
                          <($AWK -F: "$gid_awk_cmd" $HOME/group | sort))
if [ -n "$new_sys_groups" ]; then
  echo
  echo -e "Following new system groups have been found in backup /etc/group:" $new_sys_groups
  echo -en "${fg_orange}Add these system groups to the sync desination (Y/n)? $fg_reset"
  if read resp && [ "$resp" != n -a "$resp" != N ]; then
    for s_group in $new_sys_groups; do
      sudo $chroot_arg groupadd -r "$s_group"
    done
  fi
fi

uid_awk_cmd="{ if (\$3 <= $last_sys_uid) print \$1 }"
new_sys_users=$(comm -13 <($AWK -F: "$uid_awk_cmd" $sync_etc/passwd | sort) \
                         <($AWK -F: "$uid_awk_cmd" $HOME/passwd | sort))
if [ -n "$new_sys_users" ]; then
  echo
  echo -e "Following new system users have been found in backup /etc/passwd:" $new_sys_users
  echo -en "${fg_orange}Add these system users to the sync destination (Y/n)? $fg_reset"
  if read resp && [ "$resp" != n -a "$resp" != N ]; then
    for s_user in $new_sys_users; do
      readarray -t -d : user_details < <($AWK -F: \
        "{ if (\$1 == \"$s_user\") printf \"%s:%s:%s:%s\",\$4,\$5,\$6,\$7 }" $HOME/passwd)
      primary_group=$(group_name ${user_details[0]} $HOME/group)
      secondary_groups=$(user_groups "$s_user" ${user_details[0]} $HOME/group)
      sudo $chroot_arg useradd -r -g "$primary_group" -G "$secondary_groups" \
        -c "${user_details[1]}" -d "${user_details[2]}" -s "${user_details[3]}" "$s_user"
    done
  fi
fi

# Also check for synced user's secondary groups

sync_gid=$(user_gid $sync_user $sync_etc/passwd)
sync_new_gid=$(user_gid $sync_user $HOME/passwd) # can this be empty?
new_groups=$(comm -13 <(user_groups $sync_user "$sync_gid" $sync_etc/group | tr ',' '\n' | sort) \
                      <(user_groups $sync_user "$sync_new_gid" $HOME/group | tr ',' '\n' | sort))
if [ -n "$new_groups" ]; then
  echo
  echo "Synced user '$sync_user' is present in these additional groups in the backup:" $new_groups
  echo -en "${fg_orange}Add user '$sync_user' to these groups (Y/n)? $fg_reset"
  if read resp && [ "$resp" != n -a "$resp" != N ]; then
    sudo $chroot_arg usermod -aG "$(echo -n "$new_groups" | tr '\n' ',')" $sync_user
  fi
fi
rm -f $HOME/passwd $HOME/group

# Encrypt any new directories listed in backup

[ ! -e $home_dir/enc.dirs ] && $chroot_arg_user touch $home_dir_local/enc.dirs
$chroot_arg_user mv -f $home_dir_local/enc.dirs $home_dir_local/enc.dirs.orig
sudo -E rsync $rsync_common_options $remote_home/enc.dirs $home_dir/
sudo cp -f $SCRIPT_DIR/enc-init.sh $SCRIPT_DIR/enc-finish.sh $home_dir/
sudo chmod 0755 $home_dir/enc-*.sh
if ! sudo cmp $home_dir/enc.dirs.orig $home_dir/enc.dirs >/dev/null 2>/dev/null; then
  echo -e "${fg_green}Following new directories require encryption:$fg_reset"
  comm -13 <(sudo sort $home_dir/enc.dirs.orig) <(sudo sort $home_dir/enc.dirs)
  home_mnt=$(findmnt -n -o TARGET --target $home_dir)
  echo
  echo -n "Encryption will work only if '$sync_root_fs' has already been setup by "
  echo -n "fscrypt (as well as '$home_mnt' if different) and filesystems have been "
  echo -n "marked for encryption (e.g. tune2fs -O encrypt /dev/... for ext4). "
  echo -n "This script will try to do this setup, if not detected, for an ext4 filesystem"
  echo "but if that fails, then do it manually first and then proceed."
  echo
  echo -n "The PAM configuration for auto-unlocking directories using your login "
  echo "password should be copied during the sync from the backup."
  echo
  echo -en "${fg_orange}Encrypt the above directories (y/N)? $fg_reset"
  if read resp && [ "$resp" = y -o "$resp" = Y ]; then
    # check if fscrypt needs to be setup for root and possibly home mount
    if ! sudo $chroot_arg which fscrypt >/dev/null; then
      sudo DEBIAN_FRONTEND=noninteractive $chroot_arg $APT_FAST install -y --purge libpam-fscrypt
    fi
    if ! sudo $chroot_arg fscrypt status / --quiet 2>/dev/null; then
      # set encrypt flag for ext4
      if [ $(findmnt -n -o FSTYPE --target $sync_root_fs) = ext4 ]; then
        sudo tune2fs -O encrypt $(findmnt -n -o SOURCE --target $sync_root_fs)
      fi
      sudo $chroot_arg fscrypt setup --all-users
    fi
    if [ $sync_root_fs != $home_mnt ]; then
      home_mnt=${home_mnt#$sync_root_fs}
      if ! sudo $chroot_arg fscrypt status $home_mnt --quiet 2>/dev/null; then
        # set encrypt flag for ext4
        if [ $(findmnt -n -o FSTYPE --target $sync_root_fs$home_mnt) = ext4 ]; then
          sudo tune2fs -O encrypt $(findmnt -n -o SOURCE --target $sync_root_fs$home_mnt)
        fi
        sudo $chroot_arg fscrypt setup $home_mnt --all-users
      fi
    fi
    $chroot_arg_user /bin/bash -c "export HOME=$home_dir_local && export USER=$sync_user &&
      export LOGNAME=$sync_user && cd $home_dir_local && ./enc-init.sh --tty && ./enc-finish.sh"
    sudo rm -f $home_dir/enc-init.sh $home_dir/enc-finish.sh $home_dir/enc.dirs.orig
  fi
fi

# Sync data from backup (including system /etc, /usr/local etc).

echo -e "${fg_green}Running mprsync.sh to synchronize $home_dir from remote...$fg_reset"
curl -fsSL -o /tmp/mprsync.sh "https://github.com/sumwale/mprsync/blob/main/mprsync.sh?raw=true"
chmod +x /tmp/mprsync.sh
# sudo is used here since there are some directories in HOME marked with "t" and owned by subuid
# that cannot be modified/deleted despite write ACLs (e.g. /tmp inside ybox shared ROOTS)
sudo -E /tmp/mprsync.sh $rsync_common_options -A --delete \
  --exclude-from=$sync_data_conf/excludes-home.list \
  --include-from=$sync_data_conf/includes-home.list --jobs=10 $remote_home/ $home_dir/

# non-HOME changes are small, so use the plain rsync
echo -e "${fg_green}Running rsync to synchronize system configs from remote...$fg_reset"
sudo -E rsync $rsync_common_options --exclude-from=$sync_data_conf/excludes-root.list \
  $remote_root/boot $remote_root/etc $remote_root/usr $sync_root/

echo -e "${fg_green}Unpacking and writing encrypted data.$fg_reset"
sudo tar -C $sync_root/ --overwrite -xpSJf $sync_enc_data
shred -u $sync_enc_data
sudo $chroot_arg update-grub
sudo DEBIAN_FRONTEND=noninteractive $chroot_arg dpkg-reconfigure libdvd-pkg || true

echo -e "${fg_green}Disabling automatic borgmatic backup timer.$fg_reset"
sudo sed -i 's/systemctl --user start borgmatic-backup/systemctl --user stop borgmatic-backup/' \
  $home_dir/.local/bin/user-services.sh || true

# Check for fprintd that may not be present on the target, then update PAM configuration.

if [ ! -f $sync_root/usr/share/pam-configs/fprintd ] ||
  ! dpkg -s $dpkg_root_arg libpam-fprintd 2>/dev/null >/dev/null; then
  echo -e "${fg_orange}Removing changes related to fingerprint authentication.$fg_reset"
  sudo mv -f $sync_root/usr/share/pam-configs/fprintd \
    $sync_root/usr/local/share/pam-configs/fprintd.bak 2>/dev/null || true
fi
echo -e "${fg_green}Updating PAM configuration.$fg_reset"
sudo $chroot_arg pam-auth-update --package --force

echo -e $fg_orange
echo "Note the following steps that may need to be taken manually:"
echo
echo "1. You may need to generate ssh key for the synced setup and register it in the"
echo "   authorized_keys of the backup server, if not done already. For example, a good"
echo "   command to generate the public-private keypair is:"
echo "     ssh-keygen -o -a 100 -t ed25519"
echo "   After this, ssh to the backup server(s) manually at least once to accept the"
echo "   server keys and provide the password used for the mentioned ssh-keygen which"
echo "   will get stored in keyring and will allow the automatic backup service to succeed."
echo "2. Borg backup timer service has been stopped to disable automatic backups due to"
echo "   above reason and possible other required changes. Once the sync destination has"
echo "   been verified, you can enable the daily backup timer by changing the 'stop' to"
echo "   'start' in the line 'systemctl --user stop borgmatic-backup.timer' in"
echo "   $home_dir_local/.local/bin/user-services.sh"
echo "3. User container images and data were restored from the backup, but some containers may"
echo "   fail to start due to the changes in the new environment and may need to be recreated."
echo "   Note that if these were for ybox containers, then you should review and update"
echo "   the profiles in $home_dir_local/.config/ybox/profiles for the new setup as"
echo "   required before recreating those containers."
echo "4. Ubuntu Pro subscription, if configured in the backup, was removed in the sync destination"
echo "   and you will need to go to the site (https://ubuntu.com/login) to set it up again."
echo "5. The backup does not include conky configuration directly which is machine-specific"
echo "   ($home_dir_local/.config/conky/conky.conf). Review the couple of configurations"
echo "   present in $home_dir_local/config/.config/conky and adapt to the new setup."
echo "6. If there are any normal users other than the user data that was restored from backup,"
echo "   then they will need to be created manually and their data restored by other means."
echo -e $fg_green
echo "ALL DONE. If you skipped any of the options asked before (package installation,"
echo "directory encryption etc), then you may also need to perform those changes manually."
echo -e $fg_reset
