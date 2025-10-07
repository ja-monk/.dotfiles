#-----     [[ Alias File ]]     -----#
alias rm='rm -i'
alias cp='cp -i'
alias ll='ls -lrth'
alias la='ls -A'
alias cdomv='cd /mnt/omv-share'
alias glog='git log --oneline --color=always | head'

# set aliases for nvim if installed
if command -v nvim &> /dev/null; then
    alias vim='nvim'
    alias vi='nvim'
    alias v='nvim'
fi
