export SHELL=bash

PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
case "$TERM" in
    xterm-color|*-256color) PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \$ ';;
esac

alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'

source <(ng completion script)
