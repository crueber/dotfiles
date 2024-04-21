#!/bin/bash

source ~/.bin/align.sh

X=0
PAGE=1
PERPAGE=100
TOKEN=""
DIR=$(pwd)
num_re='^[0-9]+$'  # regex to match positive integers only

if [ -z "$1" ]; then  
    echo "Pull or update github repos for specific user or org. Always sorted by last pushed. \nUsage:"
    echo "./get-gh-repos-for.sh <username>"
    echo "./get-gh-repos-for.sh <username> (max)"
    echo "./get-gh-repos-for.sh org <org name>"
    echo "./get-gh-repos-for.sh org <org name> (max)"
    exit 0
fi

if [[ ! ("$1" == "org") ]]; then
    TYPE=user
    ENTITY=$1
    if [ ! -z $2 ]; then
        MAX=$2
    fi
    URL=https://api.github.com/users/${ENTITY}/repos
else
    TYPE=$1
    ENTITY=$2
    MAX=$3
    if [ "$TYPE" == "org" ] && [ -z "$ENTITY" ]; then  # if no username is provided as an argument
        echo "No organization name specified. Please provide a GitHub organization name." >&2; exit 1
    fi

    if [ "$TYPE" == "org" ]; then  # if no username is provided as an argument
        URL=https://api.github.com/orgs/${ENTITY}/repos
    fi
fi

if [ ! -z $MAX ] && ! [[ $MAX =~ $num_re ]]; then   # if the third parameter does not match the regex pattern
    echo "Error: Max parameter is not a number"
fi
if [[ ! -z "$MAX" && $MAX -lt $PERPAGE ]]; then
    PERPAGE=$MAX
fi

DIR="$(pwd)/$ENTITY"

if [ ! -d "$DIR" ]; then 
    mkdir -p ${DIR}
fi
cd ${DIR}

right_aligned "$(date)"
right_aligned "Settings:"
right_aligned "$PERPAGE per_page, $PAGE page, $MAX max, $TYPE type, $ENTITY entity"
right_aligned "$DIR working directory"
REPOSITORIES=$(curl --silent --header "Authorization: Bearer ${TOKEN}" $URL?sort=pushed\&per_page=$PERPAGE\&page=$PAGE  | grep '"git_url":' | sed 's/.*:\(.*\)\/\(.*\)\.git.*/\2/')
while [ ! -z "$REPOSITORIES" ]; do
    NUM_REPOS=$(echo "$REPOSITORIES" | wc -l)

    right_aligned "$URL?sort=pushed\&per_page=$PERPAGE\&page=$PAGE"
    right_aligned "Currently processing $(echo $NUM_REPOS | cut -d ' ' -f1) repositories in this batch."
    for repo in $REPOSITORIES; do 
        X=$((X + 1))
        right_aligned "Processing repository $X: $repo"

        repo_name="$(basename $repo .git)"
        if [ ! -d "$repo_name" ]; then 
            git clone git@github.com:${ENTITY}/$repo_name.git $DIR/$repo_name
        fi
        cd $DIR/$repo_name && (git pull origin master || git pull origin main) && cd $DIR

        if [[ $X == $MAX ]]; then exit 0; fi
    done

    PAGE=$((PAGE + 1))
    REPOSITORIES=$(curl --silent --header "Authorization: Bearer ${TOKEN}" $URL?sort=pushed\&per_page=$PERPAGE\&page=$PAGE  | grep '"git_url":' | sed 's/.*:\(.*\)\/\(.*\)\.git.*/\2/')
done
