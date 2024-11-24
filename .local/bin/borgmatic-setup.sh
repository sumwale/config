#!/bin/bash -e


# script to separately encrypt directories containing sensitive information and these
# must be excluded from regular home backups

# the new encrypted file always overwrites resulting in a new file in backup, so exclude some
# large directories that do not have any sensitive information (also conky.conf and ssh keys
#   which are machine specific)
EXCLUDES="--exclude=.config/Code --exclude=.config/JetBrains --exclude=.config/chromium --exclude=.config/libreoffice --exclude=.config/conky/conky.conf --exclude=WidevineCdm --exclude=.kube/cache --exclude=.kube/http-cache --exclude=.ssh/id_ed25519 --exclude=.ssh/id_ed25519.pub --exclude=.ssh/id_rsa --exclude=.ssh/id_rsa.pub"

function strip_lead_slash() {
  echo "$1" | sed 's,^/,,'
}

HOMEDIR="$(strip_lead_slash "$HOME")"

rm -f "$HOME/Documents/others.key.gpg" "$HOME/Documents/rest.key" "$HOME/Documents/rest.key.gpg" "$HOME/Documents/dconf-dump.gpg" "$HOME/pkgs/deb-diversions"

# first search in ybox $HOMEs
ybox_ffox="$(/bin/ls -d "$HOME/.local/share/ybox"/*/home/.mozilla/firefox 2>/dev/null | head -n 1)"
if [ -d "$ybox_ffox" ]; then
  FFOX="$(strip_lead_slash "$ybox_ffox")"
# then flatpak
elif [ -d "$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox" ]; then
  FFOX="$HOMEDIR/.var/app/org.mozilla.firefox/.mozilla/firefox"
else
  FFOX="$HOMEDIR/.mozilla/firefox"
fi

# first search in ybox $HOMEs
ybox_tbird="$(/bin/ls -d "$HOME/.local/share/ybox"/*/home/.thunderbird 2>/dev/null | head -n 1)"
if [ -d "$ybox_tbird" ]; then
  TBIRD="$(strip_lead_slash "$ybox_tbird")"
# then flatpak
elif [ -d "$HOME/.var/app/org.mozilla.Thunderbird/.thunderbird" ]; then
  TBIRD="$HOMEDIR/.var/app/org.mozilla.Thunderbird/.thunderbird"
else
  TBIRD="$HOMEDIR/.thunderbird"
fi

if gpg --list-secret-key sumwale@gmail.com 2>/dev/null >/dev/null; then
  GPG_ID="sumwale@gmail.com"
else
  GPG_ID="swale@tibco.com"
fi
( cd / && \
  tar $EXCLUDES -c -p -S -f - "$HOMEDIR/.aws" "$HOMEDIR/.cert" "$HOMEDIR/.config" "$HOMEDIR/.gnupg" "$HOMEDIR/.kube" "$HOMEDIR/.local/share/keyrings" "$FFOX"/*/key4.db "$FFOX"/*/logins*.json "$HOMEDIR/.ssh" "$TBIRD"/*/key4.db "$TBIRD"/*/logins*.json etc/grub.d etc/pam.d/common-* | \
  xz -7 -T 0 -F xz -c - | \
  gpg --batch --no-tty --encrypt -r "$GPG_ID" -o "$HOMEDIR/Documents/others.key.gpg" - 2>/dev/null && \
  tar cpSJf "$HOMEDIR/Documents/rest.key" "$HOMEDIR/.gnupg" && \
  secret-tool lookup borg-repository borgbase-store | \
  gpg --batch --no-tty --pinentry-mode loopback --symmetric --cipher-algo AES256 --no-symkey-cache --passphrase-fd 0 -o "$HOMEDIR/Documents/rest.key.gpg" "$HOMEDIR/Documents/rest.key" 2>/dev/null )

shred -u "$HOME/Documents/rest.key"

mkdir -p "$HOME/pkgs"
if type -p pacman >/dev/null; then
  pacman -Qe > "$HOME/pkgs/pac-explicit.list"
  pacman -Q > "$HOME/pkgs/pac.list"
elif type -p dpkg >/dev/null; then
  dpkg -l > "$HOME/pkgs/deb.list"
  apt-mark showmanual > "$HOME/pkgs/deb-explicit.list"
else
  rpm -ql > "$HOME/pkgs/rpm.list"
fi

if [ -r /var/lib/dpkg/diversions ]; then
  /bin/cp -f /var/lib/dpkg/diversions "$HOME/pkgs/deb-diversions"
fi

if type -p ybox-ls >/dev/null; then
  for container in $(ybox-ls --format='{{ .Names }}'); do
    ybox-pkg list -z "$container" -p ' ' 2>/dev/null > "$HOME/pkgs/$container-explicit.list"
    ybox-pkg list -z "$container" -a -p ' ' 2>/dev/null > "$HOME/pkgs/$container.list"
  done
fi

# dump the full dconf configuration
if type -p dconf >/dev/null; then
  dconf dump / | gpg --batch --no-tty --encrypt -r "$GPG_ID" -o "$HOME/Documents/dconf-dump.gpg" -
fi
