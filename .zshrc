#
# ~/.zshrc
#

## Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
## Initialization code that may require console input (password prompts, [y/n]
## confirmations, etc.) must go above this block; everything else may go below.
#if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
#fi

# Source manjaro-zsh-configuration
if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
  source /usr/share/zsh/manjaro-zsh-config
fi
## Use powerline
#USE_POWERLINE=true
## Use manjaro zsh prompt
#if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
#  source /usr/share/zsh/manjaro-zsh-prompt
#fi
#
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
#
case $(basename "$(cat "/proc/$PPID/comm")") in
  login)
    source /usr/share/zsh/zsh-maia-prompt
    alias x='startx ~/.xinitrc'
    ;;
  *)
    if [ "$TERM" = "linux" ]; then
      # TTY does not have powerline fonts
      source /usr/share/zsh/zsh-maia-prompt
      alias x='startx ~/.xinitrc'
    else
      # Use powerline
      source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
      [ -f ~/.p10k.zsh ] && source ~/.p10k.zsh
      #POWERLEVEL9K_DISABLE_GITSTATUS=true
      source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
      ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
    fi
    ;;
esac

# git diff all files including untracked
gitdiffall() {
  if test "$#" = 0; then
  (
    git diff --color
    git ls-files --others --exclude-standard |
      while read -r i; do git diff --color -- /dev/null "$i"; done
  ) | less -R
  else
    git diff "$@"
  fi
}

# colors for ls
if type -p vivid >/dev/null; then
  export LS_COLORS="$(vivid generate catppuccin-mocha)"
elif test -r ~/.dir_colors; then
  eval $(dircolors -b ~/.dir_colors)
elif test -r /etc/DIR_COLORS; then
  eval $(dircolors -b /etc/DIR_COLORS)
fi

# colors for less
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

export LESS="-R"

if [ -z "$LESSOPEN" ]; then
  if which lesspipe.sh 2>/dev/null >/dev/null; then
    export LESSOPEN="|$(which lesspipe.sh) %s"
  elif type lesspipe 2>/dev/null >/dev/null; then
    export LESSOPEN="|$(which lesspipe.sh) %s"
  fi
fi

# completions for tldr
tldr_cachedir=
if [ -d ~/.local/share/tldr ]; then
  tldr_cachedir=~/.local/share/tldr
elif [ -d ~/.tldr ]; then
  tldr_cachedir=~/.tldr
fi
if [ -n "$tldr_cachedir" ]; then
  compctl -k "($(q=($tldr_cachedir/*/*/*); sed 's,\.md\>,,g' <<<${q[@]##*/}))" tldr
fi

setopt autocd autopushd pushdignoredups no_auto_remove_slash

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# common aliases
[ -f ~/.aliases ] && source ~/.aliases

# common functions
[ -f ~/.custom_funcs.sh ] && source ~/.custom_funcs.sh

if which kubectl 2>/dev/null >/dev/null; then
  source <(kubectl completion zsh | dos2unix)

  if type eksctl 2>/dev/null >/dev/null; then
    source <(eksctl completion zsh)
  fi
fi
