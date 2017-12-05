#!/bin/bash

# Make by bash env familiar
scp ~/.bashrc bonet:~
scp ~/.bash_aliases bonet:~

# Replace old executables w updated ones
ssh bonet rm -rf ~/bin
scp -r ./bin bonet:~/bin
scp -r ./js bonet:~/js

# Make everything executable
ssh bonet chmod 755 bin/\*.sh
ssh bonet rename 's/.sh$//' bin/\*

echo "Done!"
