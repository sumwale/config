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
# utilities rsync, ssh, ssh-agent with ssh-add, gpg, git (and basic ones
#   like sudo/awk/sed/comm that are present in all usable installations).
# It makes use of mrpsync.sh script to launch parallel rsync processes which is
# downloaded, if not present, from the github repository.

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

if [ "$SCRIPT_DIR" != "/tmp" ]; then
  cp -f "$SCRIPT_DIR/$SCRIPT" /tmp/
  cp -rfL "$SCRIPT_DIR/../../.config/sync-data" $sync_data_conf
  exec /bin/bash /tmp/$SCRIPT "$@" > >(tee $log_file) 2> >(tee $err_file)
  exit $?
fi

sync_root=
home_dir=$HOME
def_remote_root=$USER@$BORG_BACKUP_SERVER:backup.sync
fg_red='\033[31m'
fg_green='\033[32m'
fg_orange='\033[33m'
fg_reset='\033[00m'
rsync_common_options='-aHSOJ --info=progress2 --zc=zstd --zl=1'
sync_enc_data=/tmp/others.txz
ssh_agent_started=0

function usage() {
  echo
  echo "Usage: $SCRIPT [--home=HOME] [<SOURCE_ROOT>] [<DEST_ROOT>]"
  echo
  echo "--home=HOME      home directory for the user on source and destination if "
  echo "                 different from '$HOME'"
  echo
  echo "  SOURCE_ROOT     source location for the sync (default: $def_remote_root)"
  echo "  DEST_ROOT       desination root directory to sync; empty means /"
  echo
  echo "NOTE: the script assumes that neither of the two args have whitespace characters"
}

function cleanup() {
  rm -rf /tmp/$SCRIPT $sync_data_conf $home_dir/enc.dirs.new /tmp/mprsync.sh
  [ -e $sync_enc_data ] && shred -u $sync_enc_data
  if [ -f $home_dir/enc.dirs.orig ]; then
    rm -f $home_dir/enc.dirs
    mv $home_dir/enc.dirs.orig $home_dir/enc.dirs
  fi
  if [ $ssh_agent_started -eq 1 ]; then
    kill $SSH_AGENT_PID
  fi
}

# argument processing

if [[ "$1" = --home=* ]]; then
  home_dir="${1/*=/}"
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

remote_home=$remote_root$home_dir
home_dir=$sync_root$home_dir
if [ -n "$sync_root" ]; then
  divert_root_arg="--root $sync_root"
  dpkg_root_arg="--root=$sync_root"
  apt_root_arg="-o RootDir=$sync_root"
fi

trap "cleanup" 0 1 2 3 4 5 6 11 12 15

# First deal with package modifications since they may have new files from backup
# which should be overwritten by the backup (else if /etc file is synced from backup,
#   for example, and also present in package, then package install will fail)

echo -e "${fg_green}Output logged to $log_file, errors to $err_file.$fg_reset"
echo

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
if [ -r $home_dir/.ssh/id_rsa ]; then
  keyfile=$home_dir/.ssh/id_rsa
elif [ -r $home_dir/.ssh/id_ed25519 ]; then
  keyfile=$home_dir/.ssh/id_ed25519
fi
if [ -n "$keyfile" ]; then
  fp=$(ssh-keygen -l -f $keyfile | $AWK '{ print $2 }')
  if [ -z "$fp" ] || ! ssh-add -l | grep -qwF "$fp"; then
    ssh-add
  fi
fi

# Sync package lists and apt configuration.
# Also fetch and extract the gnupg encrypted data so that the password, if required,
# can be obtained now and user can come back leisurely after the full sync is done
# (else gnupg password popup can timeout so user will need to keep an eye on sync being finished)

echo -e "${fg_green}Updating package lists, sync packages and fetch encrypted data.$fg_reset"
APT_FAST=apt
type -p apt-fast >/dev/null && APT_FAST=apt-fast
$APT_FAST update || true

rsync $rsync_common_options --delete $remote_home/pkgs \
  $remote_home/Documents/others.key.gpg $home_dir/
sudo -E rsync $rsync_common_options --exclude-from=$sync_data_conf/excludes-root.list \
  $remote_root/etc/apt/ $sync_root/etc/apt/
gpg --decrypt $home_dir/others.key.gpg > $sync_enc_data
shred -u $home_dir/others.key.gpg

# Apply diversions recorded in the backup.

echo -e "${fg_green}Applying any changes to local diversions.$fg_reset"
$AWK -v root=$sync_root -v root_arg="$divert_root_arg" '{
  diversion = $0; getline
  divert_to = $0; getline
  if ($0 == ":") {
    system("sudo /bin/sh -c \"mv -f " root diversion " " root diversion ".divert; " \
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
}' $home_dir/pkgs/deb-diversions

# Compare host machine packages with the backup and offer to apply any changes.

echo -e "${fg_green}Comparing packages on this host with the backup.$fg_reset"
new_pkgs=$(sed -n 's/^ii\s\+\(\S\+\).*$/\1/p' $home_dir/pkgs/deb.list | sort)
# "apt-mark showinstall" does not include arch in package names, so better to use
# "dpkg -l" rather than curating their outputs for arch
pkg_diffs=$(comm -3 <(echo "$new_pkgs") \
                    <(dpkg -l $dpkg_root_arg | sed -n 's/^ii\s\+\(\S\+\).*$/\1/p' | sort) \
  | grep -vwE 'fprintd|libfprint|command-configure|srvadmin' \
  | sed 's/^\</INSTALL: /;s/^\s\+/PURGE: /')
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
      $APT_FAST $apt_root_arg install $install_pkgs
    fi
    if [ -n "$purge_pkgs" ]; then
      sudo apt $apt_root_arg purge $purge_pkgs
    fi
    # mark the ones in deb-explicit.list as manually installed while the rest as auto
    sudo apt-mark $apt_root_arg auto $new_pkgs || true
    sudo apt-mark $apt_root_arg manual $(cat $home_dir/pkgs/deb-explicit.list) || true
  fi
fi

# Encrypt any new directories listed in backup

rsync $rsync_common_options $remote_home/enc.dirs $home_dir/enc.dirs.new
if ! cmp $home_dir/enc.dirs $home_dir/enc.dirs.new >/dev/null 2>/dev/null; then
  echo -e "${fg_green}Following new directories require encryption:$fg_reset"
  comm -13 <(sort $home_dir/enc.dirs) <(sort $home_dir/enc.dirs.new)
  home_mnt=$(findmnt -n -o TARGET --target $home_dir)
  sync_root_fs=${sync_root:-/}
  echo
  echo -n "Encryption will work only if '$sync_root_fs' has already been setup by "
  echo -n "fscrypt (as well as '$home_mnt' if different) and filesystems have been "
  echo -n "marked for encryption (e.g. tune2fs -O encrypt /dev/... for ext4). "
  echo -n "The PAM configuration for auto-unlocking directories using your login "
  echo -n "password should be copied during the sync from the backup."
  echo
  echo -en "${fg_orange}Encrypt the above directories (y/N)? $fg_reset"
  if read resp && [ "$resp" = y -o "$resp" = Y ]; then
    mv -f $home_dir/enc.dirs $home_dir/enc.dirs.orig
    mv $home_dir/enc.dirs.new $home_dir/enc.dirs
    ( cd $home_dir && enc-init.sh && enc-finish.sh && rm -f $home_dir/enc.dirs.orig )
  fi
fi

# Sync data from backup (including system /etc, /usr/local etc).

echo -e "${fg_green}Running mprsync.sh to synchronize $home_dir from remote...$fg_reset"
mprsync_sh=$(type -p mprsync.sh || true)
if [ -z "$mprsync_sh" ]; then
  curl -fsSL -o /tmp/mprsync.sh "https://github.com/sumwale/mprsync/blob/main/mprsync.sh?raw=true"
  chmod +x /tmp/mprsync.sh
  mprsync_sh=/tmp/mprsync.sh
fi
# sudo is used here since there are some directories in HOME marked with "t" and owned by subuid
# that cannot be modified/deleted despite write ACLs (e.g. /tmp inside ybox shared ROOTS)
sudo -E "$mprsync_sh" $rsync_common_options -A --delete \
  --exclude-from=$sync_data_conf/excludes-home.list \
  --include-from=$sync_data_conf/includes-home.list --jobs=10 $remote_home/ $home_dir/

# non-HOME changes are small, so use the plain rsync
echo -e "${fg_green}Running rsync to synchronize system configs from remote...$fg_reset"
sudo -E rsync $rsync_common_options --exclude-from=$sync_data_conf/excludes-root.list \
  $remote_root/boot $remote_root/etc $remote_root/usr $sync_root/

echo -e "${fg_green}Unpacking and writing encrypted data.$fg_reset"
sudo tar --xz -C $sync_root/ --overwrite -xpSf $sync_enc_data
if [ -z "$sync_root" ]; then
  sudo update-grub
else
  echo -e "${fg_orange}Remember to run update-grub on booting into '$sync_root'.$fg_reset"
fi

# Check for fprintd that may not be present on the target, then update PAM configuration.

if [ ! -f /usr/share/pam-configs/fprintd ] || ! dpkg -s libpam-fprintd 2>/dev/null >/dev/null; then
  echo -e "${fg_orange}Removing any changes related to fingerprint authentication.$fg_reset"
  sudo rm -f /usr/share/pam-configs/fprintd /usr/local/share/pam-configs/fprintd.orig
fi
echo -e "${fg_green}Updating PAM configuration.$fg_reset"
sudo pam-auth-update --package --force
