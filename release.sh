#!/bin/bash

t="${TERM:-"dumb"}"
r=$(tput -T$t setaf 1)
g=$(tput -T$t setaf 2)
y=$(tput -T$t setaf 3)
m=$(tput -T$t setaf 5)
gr=$(tput -T$t setaf 8)
bl=$(tput -T$t setaf 12)
b=$(tput -T$t bold)
u=$(tput -T$t smul)
x=$(tput -T$t sgr0)

function banner() {
  printf "\n${m}┌───────────────────────────────────────────────────┐${x}"
  printf "\n${m}│  ${y}RELEASE VERSION SCRIPT${m}                           │${x}"
  printf "\n${m}│  ${bl}${u}https://github.com/simbo/release-version-script${x}${m}  │${x}"
  printf "\n${m}└───────────────────────────────────────────────────┘${x}"
}

function error() {
  printf "\n${r}ERROR: ${1}${x}\n"
  exit 1
}

function xsed() {
  x=$([[ "$(uname -s)" = "Darwin" ]] && echo true || echo false)
  if $x; then r="-E"; else r="-r"; fi
  if [[ "$2" = "" ]]; then sed $r -e "$@"; elif $x; then sed $r -i "" -e "$@"; else sed $r -i -e "$@"; fi
}

# input param to lowercase
update=$(echo "$1" | tr [A-Z] [a-z])

# display usage info if params are not set or invalid
if ! [[ "$update" = "major" || "$update" = "minor" || "$update" = "patch" ]]; then
  banner
  printf "\n   ${gr}Author: Simon Lepel ${u}https://simbo.de/${x}"
  printf "\n   ${gr}License: MIT ${u}http://simbo.mit-license.org/${x}"
  printf "\n\nA simple yet convenient bash script to create a semantic version tag and push it to the git remote."
  printf "\n\nUsage:\n\n  ./release.sh UPDATE"
  printf "\n\nAllowed values for UPDATE are \"major\", \"minor\" or \"patch\".\n"
  exit 1
fi

# test if everything is prepared
if ! command -v git &> /dev/null; then
  error "command 'git' is not available"
fi
if ! [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) ]]; then
  error "current working directory is not inside a git working tree"
fi
if ! [[ -d .git ]]; then
  error "current working directory is not the git working tree root directory"
fi
ref=$(git symbolic-ref -q HEAD)
if ! [[ "$ref" = "refs/heads/"* ]]; then
  error "current ref is not a regular branch"
fi
branch=${ref:11}
if ! [ -z "$(git status --porcelain)" ]; then
  error "git status is dirty\n${x}Please commit or stash first."
fi

# delete local version tags and fetch from origin
git tag -d $(git tag -l | grep -E "^(v[0-9]+(\.[0-9])?(\.[0-9]+)?|latest)$") > /dev/null 2>&1
git fetch origin --tags > /dev/null 2>&1

# get latest version from git tags
latest=$(git tag -l | grep -E "^(v[0-9]+(\.[0-9])?(\.[0-9]+)?)$" | sort -r | head -n 1)
if [[ "$latest" = "" ]]; then
  latest="v0.0.0"
fi

# extract semver parts from latest version
major=$(echo "${latest:1}" | cut -d . -f 1)
minor=$(echo "${latest:1}" | cut -d . -f 2)
patch=$(echo "${latest:1}" | cut -d . -f 3)

# build new semver version
case $update in
  "major")
    new="v$((major+1)).0.0"
    ;;
  "minor")
    new="v${major}.$((minor+1)).0"
    ;;
  "patch")
    new="v${major}.${minor}.$((patch+1))"
    ;;
esac

pkg=$([[ -f package.json ]] && grep -q "\"version\":" package.json && echo true || echo false)

# inform about changes and ask to continue
banner
printf "\n\n   Repository:       ${b}$(basename $(pwd -P))${x}"
printf "\n\n   Current Branch:   $([[ "$branch" = "main" || "$branch" = "master" ]] && echo "$g" || echo "$r")${b}${branch}${x}"
printf "\n\n   Latest Version:   $([[ "$latest" = "v0.0.0" ]] && echo "${r}${b}N/A${x}" || echo "${b}${latest}${x}")"
printf "\n\n   New Version:      ${y}${b}${new}${x}"
printf "\n\nContinue to create the version tag and push it to the git remote."
$pkg && printf "\nThe version field in the package.json will be updated and committed."
printf "\n\n${gr}(press ANY KEY to continue or ESCAPE to cancel)${x}\n"
read -rsn1 key

# remove continue hint
tput -T$t cuu1
tput -T$t el

# exit on escape
if [[ $key = $'\e' ]]; then
  printf "${gr}Cancelled.${x}\n"
  exit 1
fi

# message for tag and commit
message="Release ${new}"

# exit on errors
set -e

# fetch and pull
git fetch origin
git pull origin

# update and commit package.json if present
if $pkg; then
  xsed "s/(\"version\":[[:space:]]*\")(.+)(\")/\1${new:1}\3/g" package.json
  git add package.json
  git commit -m "$message"
fi

# create tag and push
git tag -a -m "$message" $new
git push origin $branch
git push origin $new

# link to github releases
gitURL=$(git remote -v | grep "(push)" | grep -m1 origin | xsed 's/^origin[[:blank:]]+|\.git[[:blank:]]+\(push\)$//g')
if echo "$gitURL" | grep -q github.com ; then
  if [[ "$gitURL" = "git@"* ]]; then
    gitURL=$(echo "$gitURL" | xsed 's/git@(github\.com):/http:\/\/\1\//')
  fi
  printf "\nReleases on GitHub:\n${bl}${u}${gitURL}/releases${x}\n"
fi

printf "\n✅ ${g}Done!${x}\n"
