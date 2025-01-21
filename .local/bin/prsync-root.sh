#!/bin/bash -e

[ "$#" -ne 1 ] && { echo "Usage: $0 <sync source root>"; exit 1; }

fg_green='\033[32m'
fg_orange='\033[33m'
fg_reset='\033[00m'
rsync_common_flags='-aHSAX --progress --zc=zstd --zl=1'

# First deal with package modifications since they may have new files from backup
# which should be overwritten by the backup (else if /etc file is synced from backup,
#   for example, and also present in package, then package install will fail)

echo -e "${fg_green}Updating package list.$fg_reset"
apt-fast update

# Sync package lists

rsync $rsync_common_flags $1/$HOME/pkgs/ $HOME/pkgs/

# Compare host machine packages with the backup and offer to apply any changes.

echo -e "${fg_green}Comparing packages on this host with the backup.$fg_reset"
pkg_diffs=$(comm -3 <(sort $HOME/pkgs/deb-explicit.list) <(apt-mark showmanual | sort) \
  | grep -vwE 'fprintd|libfprint|command-configure' | sed 's/^\</INSTALL: /;s/^\s\+/PURGE: /')
if [ -n "$pkg_diffs" ]; then
  echo -e "${fg_orange}Changes detected, see the following package modifications.$fg_reset"
  echo "$pkg_diffs"
  echo -en "${fg_orange}Perform the above changes (y/N)? $fg_reset"
  if read resp && [ "$resp" = y -o "$resp" = Y ]; then
    purge_pkgs=$(echo "$pkg_diffs" | sed -n 's/^PURGE: //p')
    if [ -n "$purge_pkgs" ]; then
      apt-fast purge $purge_pkgs
    fi
    install_pkgs=$(echo "$pkg_diffs" | sed -n 's/^INSTALL: //p')
    if [ -n "$install_pkgs" ]; then
      apt-fast install $install_pkgs
    fi
    sudo apt --purge autoremove
  fi
fi


# Sync data from backup (including system /etc, /usr/local etc).

echo -e "${fg_green}Running rsync to synchronize HOME with remote...$fg_reset"
rsync $rsync_common_flags --delete --exclude-from=$HOME/.config/prsync/excludes-home.list \
  --include-from=$HOME/.config/prsync/includes-home.list $1/$HOME/ $HOME/

echo -e "${fg_green}Running rsync to synchronize system configs with remote...$fg_reset"
sudo rsync $rsync_common_flags --exclude=/borgmatic --exclude=/home \
  --exclude-from=$HOME/.config/prsync/excludes-root.list $1/ /

echo -e "${fg_green}Unpacking and writing encrypted sensitive data.$fg_reset"
gpg --decrypt $HOME/Documents/others.key.gpg | sudo tar --xz -C / -xpSf -

# Special check for fprintd that may not be present on the host, then update PAM config.

if [ -f /usr/share/pam-configs/fprintd ] && ! dpkg -s libpam-fprintd 2>/dev/null >/dev/null; then
  echo -e "${fg_orange}No fprintd present. Removing fprintd configuration.$fg_reset"
  sudo rm -f /usr/share/pam-configs/fprintd /usr/local/share/pam-configs/fprintd.orig
fi
echo -e "${fg_green}Updating PAM configuration.$fg_reset"
sudo pam-auth-update


echo -e "${fg_orange}All done. MAKE SURE TO CHECK THE LOCAL DPKG DIVERSIONS IN \
  '$HOME/pkgs/deb-diversions' and adjust according to your system (the local ones have \
  package name as ':' in this file), so check and apply the missing ones relevant to \
  this system manually.$fg_reset"
