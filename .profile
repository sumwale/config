export QT_QPA_PLATFORMTHEME="qt5ct"
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"

# if running bash
if [ -n "$BASH_VERSION" ]; then
  # include .bashrc if it exists
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi
else
  # set PATH so it includes user's private bin
  PATH="$PATH:$HOME/.local/bin:$HOME/.cargo/bin"
  export PATH
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
#  # reduce backlight for the theme
#  xbacklight -set 50
#elif [ -n "$DESKTOP_SESSION" ]; then
#  # set the kvantum theme
#  perl -pi -e 's/theme=.*/theme=Sweet#/' "$HOME/.config/Kvantum/kvantum.kvconfig"
#fi
