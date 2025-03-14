[ -f "$HOME/.sh_env" ] && . "$HOME/.sh_env"

systemctl --user import-environment SSH_AUTH_SOCK

# if running bash
if [ -n "$BASH_VERSION" ]; then
  # include .bashrc if it exists
  [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
fi

#if [ "$DESKTOP_SESSION" = "gnome" ]; then
#  QT_AUTO_SCREEN_SCALE_FACTOR=1
#  QT_QPA_PLATFORMTHEME=gnome
#  QT_STYLE_OVERRIDE=kvantum
#
#  export QT_AUTO_SCREEN_SCALE_FACTOR QT_QPA_PLATFORMTHEME QT_STYLE_OVERRIDE
#
#  # set the kvantum theme
#  perl -pi -e 's/theme=.*/theme=WhiteSur-dark#/' "$HOME/.config/Kvantum/kvantum.kvconfig"
#
  # reduce backlight for the theme
#  xbacklight -set 75
#elif [ -n "$DESKTOP_SESSION" ]; then
#  # set the kvantum theme
#  perl -pi -e 's/theme=.*/theme=Sweet#/' "$HOME/.config/Kvantum/kvantum.kvconfig"
#fi

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
