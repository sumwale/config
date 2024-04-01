#!/bin/bash -e


# script to separately encrypt directories containing sensitive information and these
# must be excluded from regular home backups

# the new encrypted file always overwrites resulting in a new file in backup, so exclude some
# large directories that do not have any sensitive information
CONFIG_EXCLUDES="--exclude=Code --exclude=JetBrains --exclude=chromium --exclude=libreoffice --exclude=conky.conf --exclude=id_ed25519 --exclude=id_ed25519.pub"

HOMEDIR="`echo $HOME | sed 's,^/,,'`"

rm -f $HOME/Documents/others.key.gpg $HOME/Documents/rest.key $HOME/Documents/rest.key.gpg

if [ -d $HOME/.var/app/org.mozilla.firefox/.mozilla/firefox ]; then
  FFOX=$HOMEDIR/.var/app/org.mozilla.firefox/.mozilla/firefox
else
  FFOX=$HOMEDIR/.mozilla/firefox
fi
if [ -d $HOME/.var/app/org.mozilla.Thunderbird/.thunderbird ]; then
  TBIRD=$HOMEDIR/.var/app/org.mozilla.Thunderbird/.thunderbird
else
  TBIRD=$HOMEDIR/.thunderbird
fi

if gpg --list-secret-key sumwale@gmail.com >/dev/null 2>/dev/null; then
  GPG_ID=sumwale@gmail.com
else
  GPG_ID=swale@tibco.com
fi
( cd / && \
  tar $CONFIG_EXCLUDES -c -p -S -f - $HOMEDIR/.aws $HOMEDIR/.cert $HOMEDIR/.config $HOMEDIR/.gnupg $HOMEDIR/.kube $HOMEDIR/.local/share/keyrings $FFOX/*/key4.db $FFOX/*/logins*.json $HOMEDIR/.ssh $TBIRD/*/key4.db $TBIRD/*/logins*.json etc/grub.d | \
  xz -7 -T 0 -F xz -c - | \
  gpg --batch --no-tty --encrypt -r $GPG_ID -o $HOMEDIR/Documents/others.key.gpg - 2>/dev/null && \
  tar cpSJf $HOMEDIR/Documents/rest.key $HOMEDIR/.gnupg && \
  secret-tool lookup borg-repository borgbase-store | \
  gpg --batch --no-tty --pinentry-mode loopback --symmetric --cipher-algo AES256 --no-symkey-cache --passphrase-fd 0 -o $HOMEDIR/Documents/rest.key.gpg $HOMEDIR/Documents/rest.key 2>/dev/null )

rm -f $HOME/Documents/rest.key

if type -p pacman > /dev/null; then
  pacman -Qe > $HOME/pkgs-explicit.list
  pacman -Q > $HOME/pkgs.list
elif type -p dpkg > /dev/null; then
  dpkg -l > $HOME/pkgs.list
  apt-mark showmanual > $HOME/pkgs-explicit.list
else
  rpm -ql > $HOME/pkgs.list
fi
