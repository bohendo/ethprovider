#!/bin/bash

# Make by bash env familiar
scp ~/.bashrc bonet:~
scp ~/.bash_aliases bonet:~

# Replace old executables w updated ones
ssh bonet rm -rf ~/bin
scp -r ./bin bonet:~/bin

# Make everything executable
ssh bonet rename 's/.sh$//' bin/\*
ssh bonet chmod 755 bin/\*

echo "Done!"
