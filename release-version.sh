#!/bin/bash

# vars for colors
term=${TERM:-"dumb"}
red=$(tput -T$term setaf 1)
green=$(tput -T$term setaf 2)
yellow=$(tput -T$term setaf 3)
blue=$(tput -T$term setaf 4)
bold=$(tput -T$term bold)
dim=$(tput -T$term dim)
underline=$(tput -T$term smul)
normal=$(tput -T$term sgr0)

# if ! [ -z "$(git status --porcelain)" ]; then
#   printf "\n${red}Your working tree is dirty.\nCommit or stash first.${normal}\n\n"
#   exit 1
# fi

# delete local version tags
# git tag -d $(git tag -l | grep -E "^(v[0-9]+(\.[0-9])?(\.[0-9]+)?|latest)$") > /dev/null 2>&1

# fetch tags from origin
# git fetch origin --tags > /dev/null 2>&1

printf "\n${yellow}$0 $1${normal}\n"

