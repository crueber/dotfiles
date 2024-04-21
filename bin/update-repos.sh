#!/bin/bash

# Get all subdirectories
for d in */; do
    # Change into the directory
    cd "$d" || exit 1
    
    remote_branches=$(git branch -r)
    
    if echo "$remote_branches" | grep -q "origin/master"; then
        echo "Pulling from master in $d"
        git pull origin master
    elif echo "$remote_branches" | grep -q "origin/main"; then
        echo "Pulling from main in $d"
        git pull origin main
    fi

    cd ..
done
