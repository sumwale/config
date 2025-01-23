#!/bin/bash

set -e

# ensure that system path is always searched first for all the utilities
export PATH="/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/sbin:/usr/local/bin:$PATH"

[ "$#" -ne 1 ] && { echo "Usage: $0 <sync source root>"; exit 1; }

# Before anything, copy this script to /tmp if not there and run from there to
# avoid overwrite by rsync later which can cause all kinds of trouble
SCRIPT="$(basename "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sync_data_conf=/tmp/sync-data

if [ "$SCRIPT_DIR" != "/tmp" ]; then
  /bin/cp -f "$SCRIPT_DIR/$SCRIPT" /tmp/
  /bin/cp -rfL $HOME/.config/sync-data $sync_data_conf
  exec /bin/bash /tmp/$SCRIPT "$@"
fi

fg_green='\033[32m'
fg_orange='\033[33m'
fg_reset='\033[00m'
rsync_common_options='-aHSAX --info=progress2 --zc=zstd --zl=1'

trap "/bin/rm -rf /tmp/$SCRIPT $sync_data_conf $HOME/enc.dirs.new" 0 1 2 3 4 5 6 11 12 15

# First deal with package modifications since they may have new files from backup
# which should be overwritten by the backup (else if /etc file is synced from backup,
#   for example, and also present in package, then package install will fail)

echo -e "${fg_green}Updating package list.$fg_reset"
apt-fast update

# Sync package lists and apt configuration

rsync $rsync_common_options $1/$HOME/pkgs/ $HOME/pkgs/
sudo rsync $rsync_common_options --exclude-from=$sync_data_conf/excludes-root.list $1/etc/apt/ /etc/apt/

# Special check for fprintd that may not be present on the host.

skip_fprintd=0
if [ -f /usr/share/pam-configs/fprintd ] && ! dpkg -s libpam-fprintd 2>/dev/null >/dev/null; then
  skip_fprintd=1
fi

# Apply diversions recorded in the backup.

echo -e "${fg_green}Applying any changes to local diversions.$fg_reset"
AWK=awk
type -p mawk >/dev/null && AWK=mawk
$AWK '{
  diversion = $0; getline
  divert_to = $0; getline
  if ($0 == ":") {
    system("sudo dpkg-divert --local --remove --rename --divert " divert_to " " diversion)
  }
}' /var/lib/dpkg/diversions
$AWK -v skip_fprintd=$skip_fprintd '{
  diversion = $0; getline
  divert_to = $0; getline
  if ($0 == ":" && (skip_fprintd == 0 || diversion !~ /fprintd/)) {
    system("sudo dpkg-divert --local --add --rename --divert " divert_to " " diversion)
  }
}' $HOME/pkgs/deb-diversions

# Compare host machine packages with the backup and offer to apply any changes.

echo -e "${fg_green}Comparing packages on this host with the backup.$fg_reset"
new_pkgs=$(sed -n 's/^ii\s\+\(\S\+\).*$/\1/p' $HOME/pkgs/deb.list | sort)
# "apt-mark showinstall" does not include arch in package names, so better to use
# "dpkg -l" rather than curating their outputs for arch
pkg_diffs=$(comm -3 <(echo "$new_pkgs") <(dpkg -l | sed -n 's/^ii\s\+\(\S\+\).*$/\1/p' | sort) \
  | grep -vwE 'fprintd|libfprint|command-configure' | sed 's/^\</INSTALL: /;s/^\s\+/PURGE: /')
if [ -n "$pkg_diffs" ]; then
  echo -e "${fg_orange}Changes detected, see the following package modifications.$fg_reset"
  echo "$pkg_diffs"
  echo -en "${fg_orange}Perform the above changes (y/N)? $fg_reset"
  if read resp && [ "$resp" = y -o "$resp" = Y ]; then
    install_pkgs=$(echo "$pkg_diffs" | sed -n 's/^INSTALL: //p')
    if [ -n "$install_pkgs" ]; then
      apt-fast install $install_pkgs
    fi
    purge_pkgs=$(echo "$pkg_diffs" | sed -n 's/^PURGE: //p')
    if [ -n "$purge_pkgs" ]; then
      sudo apt purge $purge_pkgs
    fi
    # mark the ones in deb-explicit.list as manually installed while the rest as auto
    sudo apt-mark auto $new_pkgs
    sudo apt-mark manual $(cat $HOME/pkgs/deb-explicit.list)
  fi
fi

# Encrypt any new directories listed in backup

rsync $rsync_common_options $1/$HOME/enc.dirs $HOME/enc.dirs.new
if ! cmp $HOME/enc.dirs $HOME/enc.dirs.new >/dev/null; then
  echo "Following new directories have been recorded as requiring encryption:"
  comm -13 <(sort $HOME/enc.dirs) <(sort $HOME/enc.dirs.new)
  echo -en "${fg_orange}Encrypt the above directories (y/N)? $fg_reset"
  if read resp && [ "$resp" = y -o "$resp" = Y ]; then
    rm -f $HOME/enc.dirs && mv $HOME/enc.dirs.new $HOME/enc.dirs
    enc-init.sh
    enc-finish.sh
  fi
fi

# Sync data from backup (including system /etc, /usr/local etc).

echo -e "${fg_green}Running mprsync.sh to synchronize HOME from remote...$fg_reset"
mprsync.sh $rsync_common_options --delete --exclude-from=$sync_data_conf/excludes-home.list \
  --include-from=$sync_data_conf/includes-home.list --jobs=10 $1/$HOME/ $HOME/

# non-HOME changes are small, so use the plain rsync
echo -e "${fg_green}Running rsync to synchronize system configs from remote...$fg_reset"
sudo rsync $rsync_common_options --exclude-from=$sync_data_conf/excludes-root.list $1/ /

echo -e "${fg_green}Unpacking and writing encrypted data.$fg_reset"
gpg --decrypt $HOME/Documents/others.key.gpg | sudo tar --xz -C / -xpSf -

# Update PAM configuration.

if [ -n "$skip_fprintd" ]; then
  echo -e "${fg_orange}No fprintd present. Removing fprintd configuration.$fg_reset"
  sudo rm -f /usr/share/pam-configs/fprintd /usr/local/share/pam-configs/fprintd.orig
fi
echo -e "${fg_green}Updating PAM configuration.$fg_reset"
sudo pam-auth-update
