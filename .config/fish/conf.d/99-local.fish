# hide welcome message
set fish_greeting
set VIRTUAL_ENV_DISABLE_PROMPT "1"

# functions needed for !! and !$ https://github.com/oh-my-fish/plugin-bang-bang
function __history_previous_command
  switch (commandline -t)
  case "!"
    commandline -t $history[1]; commandline -f repaint
  case "*"
    commandline -i !
  end
end

function __history_previous_command_arguments
  switch (commandline -t)
  case "!"
    commandline -t ""
    commandline -f history-token-search-backward
  case "*"
    commandline -i '$'
  end
end

if [ "$fish_key_bindings" = fish_vi_key_bindings ];
  bind -Minsert ! __history_previous_command
  bind -Minsert '$' __history_previous_command_arguments
else
  bind ! __history_previous_command
  bind '$' __history_previous_command_arguments
end

# fish command history
#function history
#    builtin history --show-time='%F %T '
#end

function backup --argument filename
    cp $filename $filename.bak
end

# copy DIR1 DIR2
function copy
  set count (count $argv | tr -d \n)
  if test "$count" = 2; and test -d "$argv[1]"
    set from (echo $argv[1] | trim-right /)
    set to (echo $argv[2])
    command cp -r $from $to
  else
    command cp $argv
  end
end

# git diff all files including untracked
function gitdiffall
  set count (count $argv | tr -d \n)
  if test "$count" = 0
    begin
      git diff --color
      git ls-files --others --exclude-standard |
        while read --line i; git diff --color -- /dev/null "$i"; end
    end | less -R
  else
    git diff $argv
  end
end

# colors for ls
if test -r ~/.dir_colors
  eval (dircolors -c ~/.dir_colors)
else if test -r /etc/DIR_COLORS
  eval (dircolors -c /etc/DIR_COLORS)
end

# colors for less
set -gx LESS_TERMCAP_mb \e'[1;32m'
set -gx LESS_TERMCAP_md \e'[1;32m'
set -gx LESS_TERMCAP_me \e'[0m'
set -gx LESS_TERMCAP_se \e'[0m'
set -gx LESS_TERMCAP_so \e'[01;33m'
set -gx LESS_TERMCAP_ue \e'[0m'
set -gx LESS_TERMCAP_us \e'[1;4;31m'

set -gx LESS '-R'

if test -z "$LESSOPEN"
  if which lesspipe.sh 2>/dev/null >/dev/null
    set -gx LESSOPEN '|'(which lesspipe.sh)' %s'
  else if which lesspipe 2>/dev/null >/dev/null
    set -gx LESSOPEN '|'(which lesspipe)' %s'
  end
end

# completions for tldr
set tldr_cachedir ''
if test -d ~/.local/share/tldr/pages
  set tldr_cachedir ~/.local/share/tldr/pages
else if test -d ~/.tldr/tldr/pages
  set tldr_cachedir ~/.tldr/tldr/pages
else if test -d ~/.tldr/pages
  set tldr_cachedir ~/.tldr/pages
end
if test -n "$tldr_cachedir"
  complete -x -c tldr -a "(printf '%s\n' $tldr_cachedir/**/*.md | sed -r 's,^.*/([^/]*)/(.*)\.md,\2\t\1,')"
end

# common aliases
if test -r ~/.aliases
  source ~/.aliases
end

if type kubectl 2>/dev/null >/dev/null
  source ~/.kube_funcs.fish
end
