#!/bin/bash

# Set load defaults
export VMAIL_BROWSER="links"
export VMAIL_HTML_PART_READER="links -dump"

# Add Ruby gems executables to PATH
PATH=$PATH:$HOME/.gem/ruby/1.9.1/
export PATH

# Start vmail
vmail
