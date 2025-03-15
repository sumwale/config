#!/bin/sh

# Adapted from https://gist.github.com/vorstrelok/3b7a2b43c85e2b8b6cd3f81abe7a93fa

# !!!Security note!!!
# This will give any process running as your user access to your password while
# key has not expired (2 minutes or revocation by service, whatever comes first)
# Proper solution would probably be writing PAM module and transfering key
# straight to KeePassXC's own keyring

PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

. "/etc/keepassxc-pam.conf"

user_id="`/usr/bin/id -u $PAM_USER`"
mkpasswd_args="-m sha512crypt -R $ROUNDS -S $SALT --stdin"
sed_pattern='s/^.*\$'$SALT'\$//'
if [ "$PAM_TYPE" = "auth" ]; then
  if keyctl show %:_uid.$user_id 2>/dev/null >/dev/null; then
    # reap just in case something went wrong and key expired by timeout
    keyctl reap
    key_no="`mkpasswd $mkpasswd_args | sed "$sed_pattern" | keyctl padd user keepassxc:password %:_uid.$user_id`"
  else
    # workaround noted in https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=870126#10
    keyctl link @u @s
    key_no="`mkpasswd $mkpasswd_args | sed "$sed_pattern" | keyctl padd user keepassxc:password @u`"
    # give root permission to access key
    keyctl setperm "$key_no" 0x3f190000
  fi
  keyctl timeout "$key_no" 120
elif [ "$PAM_TYPE" = "open_session" ]; then
  keyctl move -f %user:keepassxc:password %keyring:_uid.0 %keyring:_uid.$user_id
elif [ "$PAM_TYPE" = "close_session" ]; then
  :
else
  echo unexpected PAM_TYPE $PAM_TYPE
  exit 1
fi
