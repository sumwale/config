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

alias cdl='cd ~/product/lightspeed-spark'
alias cds='cd ~/product/snappy-spark'
alias cds1='cd ~/product/SnappyData/1.snappydata'
alias cdd='cd /shared/sumedh/Downloads'
alias lessdp='less *dunit*/*progress*.txt'
alias lessR='less -RL'
alias q='QHOME=~/q rlwrap -r ~/q/l32/q'
alias rmvmtmp='rm -rf vm_* .attach_pid* spark-warehouse target'

export PATH="$PATH:$HOME/.cargo/bin:$HOME/product/SnappyData/thirdparty/vsd/70/vsd/bin"

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

# completions for tldr
tldr_cachedir=~/.local/share/tldr
compctl -k "($(q=($tldr_cachedir/*/*/*); sed 's,\.md\>,,g' <<<${q[@]##*/}))" tldr

setopt autocd autopushd pushdignoredups
