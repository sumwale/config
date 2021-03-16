# Use powerline
USE_POWERLINE="true"
# Source manjaro-zsh-configuration
if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
  source /usr/share/zsh/manjaro-zsh-config
fi
# Use manjaro zsh prompt
if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
  source /usr/share/zsh/manjaro-zsh-prompt
fi

# Customizations

alias cp='cp -i'
alias mv='mv -i'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias ip='ip -color=auto'

alias ls='exa --color=always --group-directories-first'
alias la='exa -a --color=always --group-directories-first'
alias ll='exa -l --color=always --group-directories-first'
alias lt='exa -smod -r --color=always --group-directories-first'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# common aliases
if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

export PATH="$PATH:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/product/SnappyData/thirdparty/vsd/70/vsd/bin"

export GCMDIR=/gcm
export JAVA_HOME=$GCMDIR/where/software/jdk8
export IDEA_JDK=$GCMDIR/where/software/jdk11

#export LDAP_SERVER_FQDN=ldap.pune.gemstone.com

systemctl --user import-environment PATH

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

#export CLUTTER_VBLANK=none

# colors for ls
if test -r ~/.dir_colors; then
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
  if type lesspipe.sh 2>/dev/null >/dev/null; then
    export LESSOPEN="| /usr/bin/lesspipe.sh %s"
  elif type lesspipe 2>/dev/null >/dev/null; then
    export LESSOPEN="| /usr/bin/lesspipe %s"
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
