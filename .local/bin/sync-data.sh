#!/bin/bash

set -e

# ensure that system path is always searched first for all the utilities
export PATH="/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/sbin:/usr/local/bin:$PATH"

[ "$#" -gt 1 ] && { echo Unexpected args: "$@"; echo "Usage: $0 [<sync source root>]"; exit 1; }

# Before anything, copy this script to /tmp if not there and run from there to
# avoid overwrite by rsync later which can cause all kinds of trouble
SCRIPT="$(basename "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sync_data_conf=/tmp/sync-data
sync_enc_data=/tmp/others.txz
log_file=/tmp/sync-data.log
err_file=/tmp/sync-data.err

if [ "$SCRIPT_DIR" != "/tmp" ]; then
  /bin/cp -f "$SCRIPT_DIR/$SCRIPT" /tmp/
  /bin/cp -rfL $HOME/.config/sync-data $sync_data_conf
  exec /bin/bash /tmp/$SCRIPT "$@" > >(tee $log_file) 2> >(tee $err_file)
  exit $?
fi

fg_red='\033[31m'
fg_green='\033[32m'
fg_orange='\033[33m'
fg_reset='\033[00m'
rsync_common_options='-aHSOJ --info=progress2 --zc=zstd --zl=1'
ssh_agent_started=0

function cleanup() {
  rm -rf /tmp/$SCRIPT $sync_data_conf $HOME/enc.dirs.new
  [ -f $sync_enc_data ] && shred -u $sync_enc_data
  if [ -f $HOME/enc.dirs.orig ]; then
    rm -f $HOME/enc.dirs
    mv $HOME/enc.dirs.orig $HOME/enc.dirs
  fi
  if [ $ssh_agent_started -eq 1 ]; then
    kill $SSH_AGENT_PID
  fi
}

trap "cleanup" 0 1 2 3 4 5 6 11 12 15

remote_dir=${1:-$USER@$BORG_BACKUP_SERVER:backup.sync}

# First deal with package modifications since they may have new files from backup
# which should be overwritten by the backup (else if /etc file is synced from backup,
#   for example, and also present in package, then package install will fail)

echo -e "${fg_green}Output logged to $log_file, errors to $err_file.$fg_reset"
echo

# Start ssh-agent and set it up if it does not exist

if [ -z "$SSH_AUTH_SOCK" -o ! -e "$SSH_AUTH_SOCK" ]; then
  echo -e "${fg_orange}No usable ssh-agent found. It is hightly recommended to start one.$fg_reset"
  echo -en "${fg_orange}Should one be started and configured (Y/n)? $fg_reset"
  if read resp && [ "$resp" != n -a "$resp" != N ]; then
    eval $(ssh-agent -s)
    ssh_agent_started=1
  fi
fi
ssh-add

# Sync package lists and apt configuration.
# Also fetch and extract the gnupg encrypted data so that the password, if required,
# can be obtained now and user can come back leisurely after the full sync is done
# (else gnupg password popup can timeout so user will need to keep an eye on sync being finished)

echo -e "${fg_green}Updating package lists, sync packages and fetch encrypted data.$fg_reset"
apt-fast update || true

rsync $rsync_common_options --delete $remote_dir$HOME/pkgs \
  $remote_dir$HOME/Documents/others.key.gpg $HOME/
sudo -E rsync $rsync_common_options --exclude-from=$sync_data_conf/excludes-root.list \
  $remote_dir/etc/apt/ /etc/apt/
gpg --decrypt $HOME/others.key.gpg > $sync_enc_data
shred -u $HOME/others.key.gpg

# Special check for fprintd that may not be present on the host.

has_fprintd=1
if [ ! -f /usr/share/pam-configs/fprintd ] || ! dpkg -s libpam-fprintd 2>/dev/null >/dev/null; then
  has_fprintd=0
  echo -e "${fg_orange}Will skip changes related to fingerprint authentication.$fg_reset"
fi

# Apply diversions recorded in the backup.

echo -e "${fg_green}Applying any changes to local diversions.$fg_reset"
AWK=awk
type -p mawk >/dev/null && AWK=mawk
$AWK '{
  diversion = $0; getline
  divert_to = $0; getline
  if ($0 == ":") {
    system("sudo /bin/sh -c \"mv -f " diversion " " diversion \
      ".divert; dpkg-divert --local --remove --rename --divert " divert_to " " diversion "\"")
  }
}' /var/lib/dpkg/diversions
$AWK -v has_fprintd=$has_fprintd '{
  diversion = $0; getline
  divert_to = $0; getline
  if ($0 == ":") {
    system("sudo /bin/sh -c \"mkdir -p `dirname " divert_to \
      "`; dpkg-divert --local --add --rename --divert " divert_to " " diversion "\"")
    system("sudo /bin/sh -c \"[ -f " diversion ".divert ] && mv -f " \
      diversion ".divert " diversion "\"")
  }
}' $HOME/pkgs/deb-diversions

# Compare host machine packages with the backup and offer to apply any changes.

echo -e "${fg_green}Comparing packages on this host with the backup.$fg_reset"
new_pkgs=$(sed -n 's/^ii\s\+\(\S\+\).*$/\1/p' $HOME/pkgs/deb.list | sort)
# "apt-mark showinstall" does not include arch in package names, so better to use
# "dpkg -l" rather than curating their outputs for arch
pkg_diffs=$(comm -3 <(echo "$new_pkgs") <(dpkg -l | sed -n 's/^ii\s\+\(\S\+\).*$/\1/p' | sort) \
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
      apt-fast install $install_pkgs
    fi
    if [ -n "$purge_pkgs" ]; then
      sudo apt purge $purge_pkgs
    fi
    # mark the ones in deb-explicit.list as manually installed while the rest as auto
    sudo apt-mark auto $new_pkgs || true
    sudo apt-mark manual $(cat $HOME/pkgs/deb-explicit.list) || true
  fi
fi

# Encrypt any new directories listed in backup

rsync $rsync_common_options $remote_dir$HOME/enc.dirs $HOME/enc.dirs.new
if ! cmp $HOME/enc.dirs $HOME/enc.dirs.new >/dev/null; then
  echo -e "${fg_green}Following new directories require encryption:$fg_reset"
  comm -13 <(sort $HOME/enc.dirs) <(sort $HOME/enc.dirs.new)
  echo -en "${fg_orange}Encrypt the above directories (y/N)? $fg_reset"
  if read resp && [ "$resp" = y -o "$resp" = Y ]; then
    mv -f $HOME/enc.dirs $HOME/enc.dirs.orig && mv $HOME/enc.dirs.new $HOME/enc.dirs
    ( cd $HOME && enc-init.sh && enc-finish.sh && rm -f $HOME/enc.dirs.orig )
  fi
fi

# Sync data from backup (including system /etc, /usr/local etc).

echo -e "${fg_green}Running mprsync.sh to synchronize $HOME from remote...$fg_reset"
mprsync_sh=$(type -p mprsync.sh)
# sudo is used here since there are some directories in HOME marked with "t" and owned by subuid
# that cannot be modified/deleted despite write ACLs (e.g. /tmp inside ybox shared ROOTS)
sudo -E "$mprsync_sh" $rsync_common_options -A --delete \
  --exclude-from=$sync_data_conf/excludes-home.list \
  --include-from=$sync_data_conf/includes-home.list --jobs=10 $remote_dir$HOME/ $HOME/

# non-HOME changes are small, so use the plain rsync
echo -e "${fg_green}Running rsync to synchronize system configs from remote...$fg_reset"
sudo -E rsync $rsync_common_options --exclude-from=$sync_data_conf/excludes-root.list \
  $remote_dir/boot $remote_dir/etc $remote_dir/usr /

echo -e "${fg_green}Unpacking and writing encrypted data.$fg_reset"
sudo tar --xz -C / --overwrite -xpSf $sync_enc_data
sudo update-grub

# Update PAM configuration.

if [ $has_fprintd -eq 0 ]; then
  sudo rm -f /usr/share/pam-configs/fprintd /usr/local/share/pam-configs/fprintd.orig
fi
echo -e "${fg_green}Updating PAM configuration.$fg_reset"
sudo pam-auth-update --package --force
