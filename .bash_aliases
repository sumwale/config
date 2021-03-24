alias cp='cp -i'                          # confirm before overwriting something
alias mv='mv -i'                          # confirm before overwriting something
alias df='df -m'                          # show sizes in MB
alias free='free -m'                      # show sizes in MB
alias vi=nvim
alias vim=nvim

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
