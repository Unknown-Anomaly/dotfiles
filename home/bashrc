#!/bin/bash

# if not running interactively, don't do anything
[[ $- != *i* ]] && return

# prompts
PS1="[\u@\h \W]\$ " # arch default

# variables
export EDITOR="vim"

# bash aliases
if [ -f ~/.aliases ]; then
    . ~/.aliases
fi
