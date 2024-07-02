#
# ~/.bashrc
#

# mask permissions for others by default
umask 027

[[ $- != *i* ]] && return

[ -z "$SHENV_READ" -a -f "$HOME/.sh_env" ] && . "$HOME/.sh_env"

if [[ $- == *m* && "$INTERACTIVE_SHELL_IS_FISH" == "true" ]]; then
  export INTERACTIVE_SHELL_IS_FISH=false
  if [ -x /bin/fish ]; then
    fishShell=/bin/fish
  elif [ -x /usr/bin/fish ]; then
    fishShell=/usr/bin/fish
  elif [ -x /usr/local/bin/fish ]; then
    fishShell=/usr/local/bin/fish
  fi
  if [ -n "$fishShell" ]; then
    exec -a fish $fishShell
  fi
fi

iatest=$(expr index "$-" i)

colors() {
  local fgc bgc vals seq0

  printf "Color escapes are %s\n" '\e[${value};...;${value}m'
  printf "Values 30..37 are \e[33mforeground colors\e[m\n"
  printf "Values 40..47 are \e[43mbackground colors\e[m\n"
  printf "Value  1 gives a  \e[1mbold-faced look\e[m\n\n"

  # foreground colors
  for fgc in {30..37}; do
    # background colors
    for bgc in {40..47}; do
      fgc=${fgc#37} # white
      bgc=${bgc#40} # black

      vals="${fgc:+$fgc;}${bgc}"
      vals=${vals%%;}

      seq0="${vals:+\e[${vals}m}"
      printf "  %-9s" "${seq0:-(default)}"
      printf " ${seq0}TEXT\e[m"
      printf " \e[${vals:+${vals+$vals;}}1mBOLD\e[m"
    done
    echo; echo
  done
}

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Change the window title of X terminals
case ${TERM} in
  xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|interix|konsole*)
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
    ;;
  screen*)
    PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
    ;;
esac

use_color=true

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
  && type -P dircolors >/dev/null \
  && match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

if ${use_color} ; then
  # Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
  if type -P dircolors >/dev/null ; then
    if [[ -f ~/.dir_colors ]] ; then
      eval $(dircolors -b ~/.dir_colors)
    elif [[ -f /etc/DIR_COLORS ]] ; then
      eval $(dircolors -b /etc/DIR_COLORS)
    fi
  fi

  if [[ ${EUID} == 0 ]] ; then
    PS1='\[\033[01;31m\][\h\[\033[01;36m\] \W\[\033[01;31m\]]\$\[\033[00m\] '
  else
    PS1='\[\033[01;32m\][\u@\h\[\033[01;37m\] \W\[\033[01;32m\]]\$\[\033[00m\] '
  fi
else
  if [[ ${EUID} == 0 ]] ; then
    # show root@ when we don't have colors
    PS1='\u@\h \W \$ '
  else
    PS1='\u@\h \w \$ '
  fi
fi

unset use_color safe_term match_lhs sh

xhost +local:root > /dev/null 2>&1

complete -cf sudo

# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.  #65623
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize

shopt -s expand_aliases

# export QT_SELECT=4

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTSIZE=5000
export HISTFILESIZE=10000

# Don't put duplicate lines in the history and do not add lines that start with a space
export HISTCONTROL=erasedups:ignoredups:ignorespace

# Enable history appending instead of overwriting.  #139609
shopt -s histappend

# Allow ctrl-S for history navigation (with ctrl-R)
[[ $- == *i* ]] && stty -ixon

#
# # ex - archive extractor
# # usage: ex <file>
ex() {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

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

# Copy file with a progress bar
cpp() {
  set -e
  strace -q -ewrite cp -- "${1}" "${2}" 2>&1 \
    | awk '{
      count += $NF
      if (count % 10 == 0) {
        percent = count / total_size * 100
        printf "%3d%% [", percent
        for (i=0;i<=percent;i++)
          printf "="
          printf ">"
          for (i=percent;i<100;i++)
            printf " "
            printf "]\r"
          }
      }
    END { print "" }' total_size="$(stat -c '%s' "${1}")" count=0
}

# colors for less
export CLICOLOR=1
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
    export LESSOPEN="|$(which lesspipe.sh) %s"
  elif type lesspipe 2>/dev/null >/dev/null; then
    export LESSOPEN="|$(which lesspipe) %s"
  fi
fi

# Disable the bell
if [[ $iatest -gt 0 ]]; then bind "set bell-style visible"; fi

# Ignore case on auto-completion
# Note: bind used instead of sticking these in .inputrc
if [[ $iatest -gt 0 ]]; then bind "set completion-ignore-case on"; fi

# Show auto-completion list automatically, without double tab
if [[ $iatest -gt 0 ]]; then bind "set show-all-if-ambiguous On"; fi

# completions for tldr
tldr_cachedir=
if [ -d ~/.local/share/tldr ]; then
  tldr_cachedir=~/.local/share/tldr
elif [ -d ~/.tldr ]; then
  tldr_cachedir=~/.tldr
fi
if [ -n "$tldr_cachedir" ]; then
  complete -W "$(q=($tldr_cachedir/*/*/*); sed 's,\.md\>,,g' <<<${q[@]##*/})" tldr
fi

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# common aliases
[ -f ~/.aliases ] && source ~/.aliases

# common functions
[ -f ~/.custom_funcs.sh ] && source ~/.custom_funcs.sh

if type kubectl 2>/dev/null >/dev/null; then
  source <(kubectl completion bash | dos2unix)

  if type eksctl 2>/dev/null >/dev/null; then
    source <(eksctl completion bash)
  fi
fi


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"


# starship prompt and autojump
if type starship >/dev/null 2>/dev/null; then
  eval "$(starship init bash)"
fi
if [ -f "/usr/share/autojump/autojump.bash" ]; then
  source /usr/share/autojump/autojump.bash
elif [ -f "/usr/share/autojump/autojump.sh" ]; then
  source /usr/share/autojump/autojump.sh
fi


#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"


# BEGIN_KITTY_SHELL_INTEGRATION
if test -n "$KITTY_INSTALLATION_DIR" -a -e "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; then source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; fi
# END_KITTY_SHELL_INTEGRATION
