#!/bin/sh


# script to separately encrypt directories containing sensitive information and these
# must be excluded from regular home backups

# the new encrypted file always overwrites resulting in a new file in backup, so exclude some large
# directories that do are known to not have any sensitive information
CONFIG_EXCLUDES="--exclude=JetBrains --exclude=chromium --exclude=libreoffice"

rm -f $HOME/others.key

HOMEDIR="`echo $HOME | sed 's,^/,,'`"

if [ -d $HOME/.var/app/org.mozilla.Thunderbird/.thunderbird ]; then
  TBIRD=$HOMEDIR/.var/app/org.mozilla.Thunderbird/.thunderbird
else
  TBIRD=$HOMEDIR/.thunderbird
fi

(cd / && tar $CONFIG_EXCLUDES -cpSJf $HOMEDIR/others.key $HOMEDIR/.aws $HOMEDIR/.config $HOMEDIR/.gnupg $HOMEDIR/.kube $HOMEDIR/.local/share/keyrings $HOMEDIR/.mozilla/firefox/*/key4.db $HOMEDIR/.mozilla/firefox/*/logins*.json $HOMEDIR/.ssh $TBIRD/*/key4.db $TBIRD/*/logins*.json) && \
rm -f $HOME/Documents/others.key.gpg && \
gpg --encrypt -r sumwale@gmail.com -o $HOME/Documents/others.key.gpg $HOME/others.key 2>/dev/null || \
  gpg --encrypt -r swale@tibco.com -o $HOME/Documents/others.key.gpg $HOME/others.key

rm -f $HOME/others.key

if type -p pacman > /dev/null; then
  pacman -Qe > $HOME/pkgs-explicit.list
  pacman -Q > $HOME/pkgs.list
elif type -p dpkg > /dev/null; then
  dpkg -l > $HOME/pkgs.list
  apt-mark showmanual > $HOME/pkgs-explicit.list
else
  rpm -ql > $HOME/pkgs.list
fi
