#!/bin/zsh

HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=10000

# variables
export EDITOR="vim"
if [ x$DISPLAY != x ]
then
	export TERM="xterm-256color"
fi

# aliases
if [ -f ~/.aliases ]; then . ~/.aliases; fi

# colored man pages (from https://wiki.archlinux.org/index.php/Man_Page#Colored_man_pages)
man() {
	env \
		LESS_TERMCAP_mb=$(printf "\e[1;31m") \
		LESS_TERMCAP_md=$(printf "\e[1;31m") \
		LESS_TERMCAP_me=$(printf "\e[0m") \
		LESS_TERMCAP_se=$(printf "\e[0m") \
		LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
		LESS_TERMCAP_ue=$(printf "\e[0m") \
		LESS_TERMCAP_us=$(printf "\e[1;32m") \
			man "$@"
}

# fortune!
# goo.gl/rQBxa
if [ x$DISPLAY != x ]
then
	command -v fortune -as | command -v cowsay | command -v lolcat
else
	fortune -as | cowsay
fi

