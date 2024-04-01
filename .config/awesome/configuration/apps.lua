local filesystem = require('gears.filesystem')

-- Thanks to jo148 on github for making rofi dpi aware!
local with_dpi = require('beautiful').xresources.apply_dpi
local get_dpi = require('beautiful').xresources.get_dpi
local rofi_command = 'env /usr/bin/rofi -dpi ' .. get_dpi() .. ' -width ' .. with_dpi(400) .. ' -show drun -theme ' .. filesystem.get_configuration_dir() .. '/configuration/rofi.rasi -run-command "/bin/bash -c -i \'shopt -s expand_aliases; {cmd}\'"'

return {
  -- List of apps to start by default on some actions
  default = {
    terminal = 'kitty-custom.sh',
    rofi = rofi_command,
    rofi_combi = 'rofi -combi-modi window,drun,ssh -show combi -modi combi -display-combi ""',
    lock = 'i3lock-fancy -- scrot -z -o',
    quake = 'kitty',
    screenshot_save = 'gnome-screenshot',
    screenshot_save_win = 'scrot -u -z -o ~/Pictures/Screenshot_of_window_from_%F-%T.png -e "canberra-gtk-play -i camera-shutter -d screenshot"',
    screenshot_save_area = 'scrot -s -z -f -o ~/Pictures/Screenshot_of_area_from_%F-%T.png -e "canberra-gtk-play -i camera-shutter -d screenshot"',
    screenshot_clip = 'gnome-screenshot -c',
    screenshot_clip_win = 'scrot -u -z -o /tmp/Screenshot_of_window_from_%F-%T.png -e "xclip -selection clipboard -target image/png -i \\$f && rm \\$f && canberra-gtk-play -i camera-shutter -d screenshot"',
    screenshot_clip_area = 'scrot -s -z -f -o /tmp/Screenshot_of_area_from_%F-%T.png -e "xclip -selection clipboard -target image/png -i \\$f && rm \\$f && canberra-gtk-play -i camera-shutter -d screenshot"',
    screenshot = 'gnome-screenshot -i',
    browser = 'firefox',
    mail = 'thunderbird',
    editor = 'env idea.sh', -- gui text editor
    social = 'zoom',
    game = rofi_command,
    files = 'nautilus --new-window',
    music = 'sh -c "smplayer || totem"',
    software = 'sh -c "pamac-manager || kitty aptitude"'
  },
  -- List of apps to start once on start-up
  run_on_start_up = {
    'xsettingsd',
    'picom --config ' .. filesystem.get_configuration_dir() .. '/configuration/picom.conf',
    '{ /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 || /usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1; } & sleep 0.25 && eval $(gnome-keyring-daemon -s --components=pkcs11,secrets,ssh,gpg)', -- credential manager
    'conky',
    -- 'pa-applet', -- shows an audiocontrol applet in systray when installed.
    'xfce4-power-manager', -- Power manager
    'xss-lock -- i3lock-fancy -- scrot -z -o', -- xfce4-power-manager does not handle lid
    -- 'pamac-tray', -- now handled by update-notifier.sh run by conky
    '~/.local/bin/touchpad-settings.sh', -- touchpad tap to click, natural scrolling
    '~/.local/bin/user-services.sh', -- includes wifi, alsa restore
    'redshift',
    -- 'caffeine & { caffeine-indicator || /bin/true; }', -- disable screen locking when required
    --'nitrogen --random --set-zoom-fill ~/Pictures/wallpapers', -- run by conky periodically
    -- Add applications that need to be killed between reloads
    -- to avoid multipled instances, inside the awspawn script
    --'~/.config/awesome/configuration/awspawn' -- Spawn "dirty" apps that can linger between sessions
  }
}
