# set PATH so it includes user's private bin, cargo and vsd
PATH="$PATH:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/product/SnappyData/thirdparty/vsd/70/vsd/bin"
GCMDIR=/gcm
JAVA_HOME=$GCMDIR/where/software/jdk8
IDEA_JDK=$GCMDIR/where/software/jdk11
SSH_AUTH_SOCK=/run/user/`id -u`/keyring/ssh
#CLUTTER_VBLANK=none

export PATH GCMDIR JAVA_HOME IDEA_JDK SSH_AUTH_SOCK

# if running bash
if [ -n "$BASH_VERSION" ]; then
  # include .bashrc if it exists
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi
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
#  xbacklight -set 50
#elif [ -n "$DESKTOP_SESSION" ]; then
#  # set the kvantum theme
#  perl -pi -e 's/theme=.*/theme=Sweet#/' "$HOME/.config/Kvantum/kvantum.kvconfig"
#fi
