#!/bin/sh

# ensure that only system paths are searched for all the utilities
PATH="/usr/sbin:/usr/bin:/sbin:/bin"
export PATH

yk_dir=yubikey
last_hidraws=
# poll for changes in /dev/$yk_dir every 2 secs and update the links in /dev accordingly
while [ -e /dev/$yk_dir ]; do
  new_hidraws="`ls -d /dev/$yk_dir/hidraw* 2>/dev/null`"
  if [ "$last_hidraws" != "$new_hidraws" ]; then
    echo "Updating links for new yubikey device files: $new_hidraws"
    for hidraw in $last_hidraws $new_hidraws; do
      sudo rm -f `echo $hidraw | sed "s,/$yk_dir/,/,"`
    done
    if [ -n "$new_hidraws" ]; then
      sudo ln -sf $new_hidraws /dev/. && last_hidraws="$new_hidraws"
    else
      last_hidraws=
    fi
  fi
  sleep 2
done

exit 0
