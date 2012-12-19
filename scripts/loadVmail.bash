#!/bin/bash

# Set load defaults
export VMAIL_BROWSER="links"
export VMAIL_HTML_PART_READER="links -dump"

# Add Ruby gems executables to PATH, then run.
echo -e "Please type and execute\n\nPATH=\$PATH:\$HOME/.gem/ruby/1.9.1/\nexport PATH\nvmail"
