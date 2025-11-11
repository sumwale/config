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
# utilities rsync, ssh, git, curl (and basic ones like sudo/awk/sed/comm that are
#   present in all usable installations).
# It makes use of mrpsync.sh script to launch parallel rsync processes which is
# downloaded, if not present, from its github repository.

set -e
set -x

# ensure that only system paths are searched for all the utilities
export PATH="/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/sbin:/usr/local/bin"
# set umask to default so that root operations create readable entities
umask 022

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
  cp -rfL "$SCRIPT_DIR/../../.config/sync-data" $sync_data_conf
  /bin/bash /tmp/$SCRIPT "$@" > >(tee $log_file) 2> >(tee $err_file)
  exit $?
fi

sync_root=
sync_user=
home_dir=$HOME
def_remote_root=root@$BORG_BACKUP_SERVER:/home/$USER/backup.sync
fg_red='\033[31m'
fg_green='\033[32m'
fg_orange='\033[33m'
fg_reset='\033[00m'
rsync_common_options='-aHSOJ --info=progress2 --zc=zstd --zl=1'
tmp_keyfile=$HOME/.ssh/id_ed25519_synctmp
tmp_enc_pass=/tmp/login.pass
tmp_askpass=/tmp/login.askpass
rsync_ssh_opt="ssh -o Compression=no -c aes256-gcm@openssh.com -i $tmp_keyfile"
auth_keys_orig=authorized_keys.sync-bak
unpack_gpg_key=0
gpg_key_id=C9C718FF0C9D3AA4B54E18D93FD1139880CD9DB7
gpg_key_user=sumwale@gmail.com
borg_secrets_dir=/etc/borgmatic/secrets
luks_tpm2_pin_file=/etc/luks/tpm2.pin
sys_creds_enc_opts="--with-key=host+tpm2 encrypt"

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
  rm -rf /tmp/$SCRIPT $sync_data_conf /tmp/sync.py $pkgs_err
  rm -rf $HOME/passwd $HOME/group
  if [ $home_dir != $HOME ]; then
    rm -rf $HOME/pkgs
  fi

  rm -f $tmp_askpass 2>/dev/null
  if [ -e "$tmp_keyfile" ]; then
    remote_server=${remote_root%:*}
    ssh -i $tmp_keyfile $remote_server "rm -f .ssh/authorized_keys; mv .ssh/$auth_keys_orig .ssh/authorized_keys" || true
    rm -f $tmp_keyfile*
  fi

  if [ $unpack_gpg_key -eq 1 -a $home_dir != $HOME ]; then
    find $HOME/.gnupg -type f -print0 | xargs -0 -r shred -u
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

sudo dpkg --add-architecture i386
sudo apt-get update || true
sudo apt-get install -y rsync gpg openssh-client coreutils util-linux mawk tar curl sudo
sudo apt-get install -y apt dpkg

AWK=awk
type -p mawk >/dev/null && AWK=mawk

# add temporary key-pair for public key authentication without password
rm -f $tmp_keyfile*
remote_server=${remote_root%:*}
sudo systemd-creds setup
echo -en "${fg_orange}Will use public key auth without password using a temporary key-pair. "
echo -en "Without public key auth, every rsync process will ask for password. "
echo -e "Generating a temporary key-pair and adding to '$remote_server'.$fg_reset"
ssh-keygen -t ed25519 -N "" -f $tmp_keyfile
remote_server_addr=${remote_server#*@}
remote_pass_login=${remote_server/root@/$sync_user@}

# get the password for remote login and sudo, and store encrypted in a temporary file
pass_tries=1
while true; do
  sudo rm -f $tmp_enc_pass $tmp_askpass
  systemd-ask-password 'Remote password:' | \
    sudo systemd-creds --name=remote-pass encrypt - $tmp_enc_pass
  dec_cmd="sudo /usr/bin/systemd-creds --name=remote-pass decrypt $tmp_enc_pass"
  cat > $tmp_askpass << EOF
#!/bin/sh
$dec_cmd
EOF
  chmod 0755 $tmp_askpass
  export SSH_ASKPASS=$tmp_askpass
  export SSH_ASKPASS_REQUIRE=force
  mkdir -p ~/.ssh
  if ! grep -q "^$remote_server_addr " ~/.ssh/known_hosts 2>/dev/null; then
    ssh-keyscan $remote_server_addr 2>/dev/null >> ~/.ssh/known_hosts
  fi
  # test if the password works
  if ssh -o PubkeyAuthentication=no $remote_pass_login whoami | grep -Fwq $sync_user; then
    break
  fi
  ((pass_tries++))
  if [ $pass_tries -gt 3 ]; then
    echo -e "${fg_red}Too many password failures!$fg_reset"
    exit 1
  fi
  echo -e "${fg_red}Incorrect password, try again.$fg_reset"
done

{ $dec_cmd; cat $tmp_keyfile.pub; } | ssh -o PubkeyAuthentication=no $remote_pass_login \
  "sudo -S -p '' /bin/bash -c 'mv -f ~/.ssh/authorized_keys ~/.ssh/$auth_keys_orig 2>/dev/null; \
   cat - > ~/.ssh/authorized_keys && chmod 0400 ~/.ssh/authorized_keys'"
unset SSH_ASKPASS SSH_ASKPASS_REQUIRE
sudo rm -f $tmp_enc_pass $tmp_askpass

# Sync package lists and apt configuration.
# Also fetch and extract the gnupg encrypted data so that the password, if required,
# can be obtained now and user can come back leisurely after the full sync is done
# (else gnupg password popup can timeout so user will need to keep an eye on sync being finished)

APT_FAST=apt-get
APT_COMMON_OPTS="-y --purge -o Dpkg::Options::=--force-confold"
if sudo $chroot_arg which apt-fast >/dev/null; then
  APT_FAST=apt-fast
elif sudo $chroot_arg which add-apt-repository >/dev/null; then
  echo -e "${fg_green}Installing apt-fast for faster downloads.$fg_reset"
  sudo $chroot_arg env DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common
  sudo $chroot_arg add-apt-repository ppa:apt-fast/stable
  sudo $chroot_arg apt-get update || true
  sudo $chroot_arg env DEBIAN_FRONTEND=noninteractive apt-get install -y apt-fast
  APT_FAST=apt-fast
fi

echo -e "${fg_green}Updating package lists, sync packages and fetch encrypted data.$fg_reset"

# If gpg secret key is not present, then fetch the .gnupg encrypted tar

export GPG_TTY=$(tty)
if ! gpg --quiet --list-secret-key $gpg_key_id >/dev/null 2>/dev/null; then
  enc_bundles="$remote_home/Documents/gpg-backup.pgp"
  unpack_gpg_key=1
fi
# most rsync calls will use sudo since the current user's UID may be different from that
# of the backup user whose data is being synced; '-E' option is to enable using
# current user's ssh key for remote server public key authentication
rsync $rsync_common_options -e "$rsync_ssh_opt" --delete $remote_root/etc/group \
  $remote_root/etc/passwd $remote_home/pkgs $enc_bundles $HOME/
sudo -E rsync $rsync_common_options -e "$rsync_ssh_opt" --delete $remote_home/deb-local \
  $home_dir/
sudo -E rsync $rsync_common_options -e "$rsync_ssh_opt" \
  --exclude-from=$sync_data_conf/excludes-root.list $remote_root/etc/apt/ $sync_etc/apt/
sudo -E rsync $rsync_common_options -e "$rsync_ssh_opt" \
  --exclude-from=$sync_data_conf/excludes-root.list \
  $remote_root/usr/share/keyrings/ $sync_root/usr/share/keyrings/
sudo -E rsync $rsync_common_options -e "$rsync_ssh_opt" \
  --exclude-from=$sync_data_conf/excludes-root.list \
  $remote_root/var/opt/ $sync_root/var/opt/
# switch to the standard India server for packages since others may not be functional at this time
plucky_src=$sync_etc/apt/sources.list.d/ubuntu-plucky.sources
ub_src=$sync_etc/apt/sources.list.d/ubuntu.sources
if [ -f $ub_src ]; then
  if [ -f $plucky_src ]; then
    ub_src="$ub_src $plucky_src"
    # disable plucky for now and enable towards the end
    sudo sed -i 's|Enabled:.*|Enabled: no|' $plucky_src
  fi
  sudo sed -i 's|URIs:.*|URIs: https://in.archive.ubuntu.com/ubuntu/|' $ub_src
fi
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
# gpg needs scdaemon and pcscd for yubikey access
sudo $chroot_arg env DEBIAN_FRONTEND=noninteractive $APT_FAST install $APT_COMMON_OPTS \
  tpm2-tools scdaemon pcscd || true

if [ $unpack_gpg_key -eq 1 ]; then
  find $HOME/.gnupg -type f -print0 | xargs -0 -r shred -u
  rm -rf $HOME/.gnupg/*
  gpg --import $HOME/gpg-backup.pgp
  shred -u $HOME/gpg-backup.pgp
  # copy over gnupg keys from host setup if required and link gpg.conf to the one in config repo
  if [ $home_dir != $HOME ]; then
    $chroot_arg_user mkdir -p $home_dir_local/.gnupg
    $chroot_arg_user chmod 0700 $home_dir_local/.gnupg
    sudo find $home_dir/.gnupg -type f -print0 | sudo xargs -0 -r shred -u
    sudo rm -rf $home_dir/.gnupg/*
    sudo cp -a $HOME/.gnupg/* $home_dir/.gnupg/.
    sudo rm -f $home_dir/.gnupg/gpg.conf
    sudo ln -s ../config/.gnupg/gpg.conf $home_dir/.gnupg/gpg.conf
    sudo $chroot_arg chown -R $sync_user:$sync_user_group $home_dir_local/.gnupg
  fi
fi

# Re-create the KeePassXC databases registered with keepassxc-unlock if possible
if [ -n "$sync_root" ]; then
  echo
  echo -e "${fg_orange}Skipping keepassxc and other TPM2 encrypted keys due to '/' not being sync root."
  echo -e "Perform this manually after booting into the machine post full sync.$fg_reset"
  echo
elif sudo systemd-creds has-tpm2 2>/dev/null >/dev/null; then
  echo
  echo -e "${fg_green}Restoring keepassxc-unlock database registrations.$fg_reset"
  echo
  sudo systemd-creds setup
  kp_base=/etc/keepassxc-unlock
  sudo mkdir -p $kp_base && sudo chmod 0700 $kp_base
  borg_backup_base=$sync_root/var/opt/borg/backups
  kp_backup_base=$borg_backup_base/keepassxc-unlock
  for kp_backup_dir in $kp_backup_base/*; do
    kp_dir=$kp_base/$(basename $kp_backup_dir)
    sudo mkdir -p $kp_dir && sudo chmod 0700 $kp_dir
    for kp_conf_gpg in $kp_backup_dir/kdbx-*.gpg; do
      kp_conf_name=$(basename $kp_conf_gpg .gpg)
      kp_conf_name=${kp_conf_name#kdbx-}
      kp_conf=$kp_dir/kdbx-$kp_conf_name.conf
      sudo rm -f $kp_conf
      gpg --decrypt $kp_conf_gpg | tee >(head -3 -) >(tail -n+4 - | \
        sudo systemd-creds --name=$kp_conf_name $sys_creds_enc_opts - -) >/dev/null | \
        sudo tee $kp_conf >/dev/null
      sudo chmod 0400 $kp_conf
    done
    if [ -f $kp_backup_dir/keepassxc.sha512 ]; then
      sudo cp -af $kp_backup_dir/keepassxc.sha512 $kp_dir/keepassxc.sha512
      sudo chmod 0400 $kp_dir/keepassxc.sha512
    fi
  done
  sudo mkdir -p $borg_secrets_dir
  sudo chmod 0700 $borg_secrets_dir
  for borg_key in $borg_backup_base/borg-*.key.gpg; do
    kname=$(echo $borg_key | sed 's/^.*\/borg-//;s/.key.gpg$//')
    out_file=$borg_secrets_dir/$kname.key
    sudo rm -f $out_file
    gpg --decrypt $borg_key | sudo systemd-creds --name=borg-$kname $sys_creds_enc_opts - $out_file
    sudo chmod 0400 $out_file
  done
  sudo mkdir -p /etc/luks
  sudo chmod 0700 /etc/luks
  sudo rm -f $luks_tpm2_pin_file
  gpg --decrypt $borg_backup_base/luks-tpm2.pin.gpg | \
    sudo systemd-creds --name=tpm2-pin $sys_creds_enc_opts - $luks_tpm2_pin_file
  sudo chmod 0400 $luks_tpm2_pin_file
else
  echo
  echo -e "${fg_orange}WARNING: skipping keepassxc registrations due to missing TPM2."
  echo -e "Perform this manually after booting into the machine post full sync.$fg_reset"
  echo
fi


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
sudo $chroot_arg env DEBIAN_FRONTEND=noninteractive dpkg --configure -a --force-confold
sudo $chroot_arg env DEBIAN_FRONTEND=noninteractive apt-get install -f $APT_COMMON_OPTS

echo -e "${fg_green}Installing default locally built packages with dependencies.$fg_reset"
sudo $chroot_arg /bin/sh -c "/usr/bin/env DEBIAN_FRONTEND=noninteractive $APT_FAST install \
  $APT_COMMON_OPTS $home_dir_local/deb-local/default/*.deb"

echo
echo -e "${fg_green}Comparing packages on this host with the backup.$fg_reset"
# "apt-mark showinstall" does not include arch in package names, so better to use
# "dpkg -l" rather than curating their outputs for arch
new_pkgs=$(sed -n 's/^ii\s\+\(\S\+\).*$/\1/p' $HOME/pkgs/deb.list | sort)
pkg_diffs=$(comm -3 <(echo "$new_pkgs") \
                    <(dpkg -l $dpkg_root_arg | sed -n 's/^ii\s\+\(\S\+\).*$/\1/p' | sort) |
  grep -vwE 'command-configure|srvadmin' |
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
      selected_inst_pkgs=$(sudo $chroot_arg apt-cache -q=0 show $install_pkgs 2> $pkgs_err | \
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
    fi
    if [ -n "$selected_inst_pkgs" -o -n "$purge_pkgs" ]; then
      if [ -z "$selected_inst_pkgs" ]; then
        sudo $chroot_arg env DEBIAN_FRONTEND=noninteractive apt-get purge -y $purge_pkgs
      else
        purge_pkgs_minus=$(echo "$purge_pkgs" | sed -E 's/[[:space:]]+|$/-\0/g')
        sudo $chroot_arg env DEBIAN_FRONTEND=noninteractive $APT_FAST install \
          --allow-downgrades $APT_COMMON_OPTS $selected_inst_pkgs $purge_pkgs_minus || true
      fi
    fi
    # mark the ones in deb-explicit.list as manually installed while the rest as auto
    sudo $chroot_arg apt-mark auto $new_pkgs || true
    sudo $chroot_arg apt-mark auto plasma-integration plasma-workspace python3-proton-keyring-linux || true
    sudo $chroot_arg apt-mark manual $(cat $HOME/pkgs/deb-explicit.list) || true
    #sudo $chroot_arg env DEBIAN_FRONTEND=noninteractive apt-get autopurge || true
  fi
fi
# enable plucky before the upgrade
if [ -f $plucky_src ]; then
  sudo sed -i 's|Enabled:.*|Enabled: yes|' $plucky_src
fi
sudo $chroot_arg env DEBIAN_FRONTEND=noninteractive $APT_FAST full-upgrade \
  --allow-downgrades $APT_COMMON_OPTS || true
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
  echo -en "${fg_orange}Add these system groups to the sync desination (y/N)? $fg_reset"
  if read resp && [ "$resp" = y -o "$resp" = Y ]; then
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
  echo -en "${fg_orange}Add these system users to the sync destination (y/N)? $fg_reset"
  if read resp && [ "$resp" = y -o "$resp" = Y ]; then
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
  echo -en "${fg_orange}Add user '$sync_user' to these groups (y/N)? $fg_reset"
  if read resp && [ "$resp" = y -o "$resp" = Y ]; then
    # the new group may not exist, so try one by one and ignore errors
    for ng in $new_groups; do
      sudo $chroot_arg usermod -aG $ng $sync_user || true
    done
  fi
fi
rm -f $HOME/passwd $HOME/group

# Sync data from backup (including system /etc, /usr/local etc).

echo -e "${fg_green}Running mprsync to synchronize $home_dir from remote...$fg_reset"
curl -fsSL -o /tmp/sync.py "https://github.com/sumwale/mprsync/blob/main/mprsync/sync.py?raw=true"
# sudo is used here since there are some directories in HOME marked with "t" and owned by subuid
# that cannot be modified/deleted despite write ACLs (e.g. /tmp inside ybox shared ROOTS)
sudo -E python3 /tmp/sync.py $rsync_common_options -A -e "$rsync_ssh_opt" --delete \
  --exclude-from=$sync_data_conf/excludes-home.list \
  --include-from=$sync_data_conf/includes-home.list --jobs=10 $remote_home/ $home_dir/
# run a plain rsync at the end to fix any discrepencies
sudo -E rsync $rsync_common_options -A -e "$rsync_ssh_opt" --delete \
  --exclude-from=$sync_data_conf/excludes-home.list \
  --include-from=$sync_data_conf/includes-home.list $remote_home/ $home_dir/

# TODO: mprsync is failing here, check and switch since this is also few hundred MBs
echo -e "${fg_green}Running rsync to synchronize system configs from remote...$fg_reset"
sudo -E rsync $rsync_common_options -A -e "$rsync_ssh_opt" \
  --exclude-from=$sync_data_conf/excludes-root.list \
  $remote_root/boot $remote_root/etc $remote_root/opt $remote_root/usr $sync_root/
sudo $chroot_arg update-grub
sudo $chroot_arg env DEBIAN_FRONTEND=noninteractive dpkg-reconfigure libdvd-pkg || true

echo -e "${fg_green}Importing public GPG key $gpg_key_id of $gpg_key_user and marking"
echo "as trusted for encryption in backup scripts.$fg_reset"
sudo $chroot_arg gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys $gpg_key_id
echo -e '5\ny\n' | sudo $chroot_arg gpg --command-fd 0 --expert --edit-key $gpg_key_id trust

if [ -x $sync_root/usr/bin/pamu2fcfg -a ! -f $sync_root/etc/yubikey/u2f_keys ]; then
  echo
  echo -e "${fg_green}Registering YubiKey for login credentials.$fg_reset"
  echo
  $chroot_arg_user pamu2fcfg --resident --type=eddsa --pin-verification | \
    sudo tee $sync_root/etc/yubikey/u2f_keys >/dev/null
  sudo chmod 0644 $sync_root/etc/yubikey/u2f_keys
fi

echo -e "${fg_green}Disabling automatic borgmatic backup timer.$fg_reset"
sudo $chroot_arg systemctl stop borgmatic-backup.timer
sudo $chroot_arg systemctl disable borgmatic-backup.timer

echo -e $fg_orange
echo "Note the following steps that may need to be taken manually:"
echo
if [ ! -f $home_dir/.ssh/id_ed25519_sk ]; then
  echo "0. You may need to generate ssh key and register it in the authorized_keys of "
  echo "   the backup server and github, if not done already. For example, a good command "
  echo "   to generate the public-private keypair is:"
  echo "     ssh-keygen -a 100 -t ed25519 -C <email> -f ~/.ssh/id_ed25519"
  echo "   Or to store the key in a FIDO2 security key like yubikey:"
  echo "     ssh-keygen -a 100 -t ed25519-sk -O resident -O verify-required -O \\"
  echo "         application=ssh:<email> -C ssh:<email> -f ~/.ssh/id_ed25519_sk"
  echo "   Use the same password as that of the existing ed25519-sk key in KeePassXC "
  echo "   under SSH group so that it gets auto-loaded in ssh-agent."
  echo "   Add this to authorized_keys of the backup server and in github settings."
fi
echo "1. If the restoration of keepassxc and other TPM2 encrypted keys was skipped due to missing"
echo "   TPM2 or when running in a chroot, then you will need to register the KeePassXC databases"
echo "   again by running keepassxc-unlock-setup for auto-unlock of KeePassXC databases to work."
echo "   In addition passwords for borg backup need to be registered in $borg_secrets_dir"
echo "   using 'echo $$<type>_pass | sudo systemd-creds --name=borg-<type> $sys_creds_enc_opts\\"
echo "     - - | sudo tee $borg_secrets_dir/<type>.key' where <type> is 'login' "
echo "   and 'store' for the login password and storage password. Change mode using 'chmod 0400'."
echo "   Likewise PIN for LUKS decryption using TPM2 needs to be registered in $luks_tpm2_pin_file"
echo "   using 'echo <password> | sudo systemd-creds --name=tpm2-pin $sys_creds_enc_opts\\"
echo "     - - | sudo tee $luks_tpm2_pin_file && sudo chmod 0400 $luks_tpm2_pin_file'."
echo "   Take care to disable shell history so that the passwords are not stored in plain-text."
echo "   Alternatively run ~/.local/bin/tpm2-update-all.sh that will recreate all of the above"
echo "   and also re-enroll TPM2 with PIN for LUKS encrypted root."
echo "2. Borg backup timer service has been stopped to disable automatic backups due to"
echo "   above reasons and possible other required changes. Once the sync destination has"
echo "   been verified, you can enable the daily backup timer by running"
echo "     sudo systemctl enable --now borgmatic-backup.timer"
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
echo "6. It is assumed that the system is using full-disk encryption using LUKS with"
echo "   TPM2 with PIN unlock in first slot, password in second slot and a key file"
echo "   for the third slot (which is stored in the encrypted partition itself and only"
echo "     used for convenience when re-enrolling TPM2), so ensure this is the case."
echo "   The key file is a random one that can be generated as below:"
echo "     sudo dd if=/dev/random of=/etc/luks/lvm.key bs=512 count=4"
echo -e $fg_green
echo "ALL DONE. If you skipped any of the options asked before (package installation,"
echo "directory encryption etc), then you may also need to perform those changes manually."
echo -e $fg_reset
