#!/bin/bash

set -e

# script to separately encrypt directories containing sensitive information and these
# must be excluded from regular home backups

# the new encrypted file always overwrites resulting in a new file in backup, so exclude some
# large directories that do not have any sensitive information (also conky.conf and ssh keys
#   which are machine specific)
EXCLUDES="--exclude=.config/Code --exclude=.config/JetBrains --exclude=.config/chromium --exclude=.config/kdeconnect --exclude=.config/libreoffice --exclude=.config/conky/conky.conf --exclude=WidevineCdm --exclude=.kube/cache --exclude=.kube/http-cache --exclude=.ssh/id_ed25519 --exclude=.ssh/id_ed25519.pub --exclude=.ssh/id_rsa --exclude=.ssh/id_rsa.pub"

function strip_lead_slash() {
  echo "$1" | sed 's,^/,,'
}

HOMEDIR=$(strip_lead_slash $HOME)

rm -f $HOME/Documents/others.key.gpg $HOME/Documents/rest.key $HOME/Documents/rest.key.gpg $HOME/Documents/dconf-dump.gpg $HOME/pkgs/deb-diversions

# encrypt stored firefox, thunderbird passwords and key separately

# first search for firefox profile in ybox $HOMEs
ybox_root=$HOME/.local/share/ybox
ybox_ffox=$(/bin/ls -d $ybox_root/*/home/.mozilla/firefox 2>/dev/null || true)
if [ -d "$(echo "$ybox_ffox" | head -n 1)" ]; then
  FFOX=$(strip_lead_slash "$ybox_ffox")
# then flatpak
elif [ -d $HOME/.var/app/org.mozilla.firefox/.mozilla/firefox ]; then
  FFOX=$HOMEDIR/.var/app/org.mozilla.firefox/.mozilla/firefox
else
  FFOX=$HOMEDIR/.mozilla/firefox
fi

# thunderbird profile is always kept in $HOME and mounted into containers if required
if [ -d $HOME/.var/app/org.mozilla.Thunderbird/.thunderbird ]; then
  TBIRD=$HOMEDIR/.var/app/org.mozilla.Thunderbird/.thunderbird
else
  TBIRD=$HOMEDIR/.thunderbird
fi

GPG_ID=sumwale@gmail.com
# firefox can have multiple configuration directories, so expand each of them
for ffox_dir in $FFOX; do
  FFOX_TBIRD_INC="$FFOX_TBIRD_INC $(cd / && /bin/ls $ffox_dir/*/key4.db $ffox_dir/*/logins*.json $ffox_dir/*/places* $ffox_dir/*/recovery* $ffox_dir/*/webappsstore* 2>/dev/null || true)"
done
FFOX_TBIRD_INC="$FFOX_TBIRD_INC $(cd / && /bin/ls $TBIRD/*/key4.db $TBIRD/*/logins*.json $TBIRD/*/places* $TBIRD/*/recovery* $TBIRD/*/webappsstore* 2>/dev/null || true)"

( cd / && \
  tar $EXCLUDES -cpSf - $HOMEDIR/.aws $HOMEDIR/.cert $HOMEDIR/.config $HOMEDIR/.kube $HOMEDIR/.local/share/keyrings $FFOX_TBIRD_INC $HOMEDIR/.ssh etc/grub.d | \
  xz -7 -T 0 -F xz -c - | \
  gpg --batch --no-tty --encrypt -r $GPG_ID -o $HOMEDIR/Documents/others.key.gpg - 2>/dev/null && \
  tar chpSJf $HOMEDIR/Documents/rest.key $HOMEDIR/.gnupg 2>/dev/null && \
  secret-tool lookup borg-repository borgbase-store | \
  gpg --batch --no-tty --pinentry-mode loopback --symmetric --cipher-algo AES256 --no-symkey-cache --passphrase-fd 0 -o $HOMEDIR/Documents/rest.key.gpg $HOMEDIR/Documents/rest.key 2>/dev/null )

shred -u $HOME/Documents/rest.key

mkdir -p $HOME/pkgs
if type -p pacman >/dev/null; then
  pacman -Qe > $HOME/pkgs/pac-explicit.list
  pacman -Q > $HOME/pkgs/pac.list
elif type -p dpkg >/dev/null; then
  dpkg -l > $HOME/pkgs/deb.list
  apt-mark showmanual > $HOME/pkgs/deb-explicit.list
else
  rpm -ql > $HOME/pkgs/rpm.list
fi

if [ -r /var/lib/dpkg/diversions ]; then
  /bin/cp -f /var/lib/dpkg/diversions $HOME/pkgs/deb-diversions
fi

if type -p ybox-ls >/dev/null; then
  for container in $(ybox-ls --format='{{ .Names }}'); do
    ybox-pkg list -z "$container" -p ' ' 2>/dev/null > "$HOME/pkgs/$container-YBOX-explicit.list"
    ybox-pkg list -z "$container" -a -p ' ' 2>/dev/null > "$HOME/pkgs/$container-YBOX.list"
  done
fi

# dump the full dconf configuration
if type -p dconf >/dev/null; then
  dconf dump / | gpg --batch --no-tty --encrypt -r $GPG_ID -o $HOME/Documents/dconf-dump.gpg -
fi
