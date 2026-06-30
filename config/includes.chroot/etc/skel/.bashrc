# OkayOS default .bashrc — copied to every new user's home directory.

# Source the system-wide bashrc if present.
[ -f /etc/bash.bashrc ] && . /etc/bash.bashrc

# History niceties
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth
shopt -s histappend checkwinsize

# A friendly OkayOS prompt: user@okayos:cwd$
PS1='\[\033[1;36m\]\u\[\033[0m\]@\[\033[1;32m\]\h\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\]\$ '

# Handy aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'

# Show the OkayOS welcome banner on interactive login shells.
if [ -t 1 ] && command -v okayos-welcome >/dev/null 2>&1; then
	okayos-welcome
fi
