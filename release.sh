#!/bin/bash

# vars for colors
red=$(tput -T${TERM:-"dumb"} setaf 1)
green=$(tput -T${TERM:-"dumb"} setaf 2)
yellow=$(tput -T${TERM:-"dumb"} setaf 3)
magenta=$(tput -T${TERM:-"dumb"} setaf 5)
blue=$(tput -T${TERM:-"dumb"} setaf 12)
gray=$(tput -T${TERM:-"dumb"} setaf 8)
bold=$(tput -T${TERM:-"dumb"} bold)
underline=$(tput -T${TERM:-"dumb"} smul)
normal=$(tput -T${TERM:-"dumb"} sgr0)

function displayBanner() {
  printf "\n${magenta}┌───────────────────────────────────────────────────┐${normal}"
  printf "\n${magenta}│  ${yellow}RELEASE VERSION SCRIPT${magenta}                           │${normal}"
  printf "\n${magenta}│  ${blue}${underline}https://github.com/simbo/release-version-script${normal}${magenta}  │${normal}"
  printf "\n${magenta}└───────────────────────────────────────────────────┘${normal}"
}

# print error message and exit
function error() {
  printf "\n${red}ERROR: ${1}${normal}\n"
  exit 1
}

# sed with params depending on operating system
function xsed() {
  if [ "$(uname -s | xargs)" = "Darwin" ]; then
    sed -E -i "" -e "$@"
  else
    sed -r -i -e "$@"
  fi
}

# input param to lowercase
semverUpdate=$(echo "$1" | tr [A-Z] [a-z])

# display usage info if params are not set or invalid
if ! [[ "$semverUpdate" = "major" || "$semverUpdate" = "minor" || "$semverUpdate" = "patch" ]]; then
  displayBanner
  printf "\n   ${gray}Author: Simon Lepel ${underline}https://simbo.de/${normal}"
  printf "\n   ${gray}License: MIT ${underline}http://simbo.mit-license.org/${normal}"
  printf "\n\nA simple yet convenient bash script to create a semantic version tag and push it to the git remote."
  command=$([[ "$0" = "bash" ]] && echo "curl -s https://raw.githubusercontent.com/simbo/release-version-script/latest/release-version.sh | bash -s" || echo $0)
  printf "\n\nUsage:\n  $command <UPDATE>"
  printf "\n\nParameters:"
  printf "\n  UPDATE (required)  should be either 'major', 'minor' or 'patch'"
  printf "\n"
  exit 1
fi

# test for git command
if ! command -v git &> /dev/null; then
  error "command 'git' is not available"
fi

# test for git working tree
if ! [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) ]]; then
  error "current working directory is not inside a git working tree"
fi

# test for root directory of git working tree
if ! [[ -d .git ]]; then
  error "current working directory is not the git working tree root directory"
fi

# get current branch
currentRef=$(git symbolic-ref -q HEAD)
if ! [[ "$currentRef" = "refs/heads/"* ]]; then
  error "current ref is not a regular branch"
fi
currentBranch=${currentRef:11}

# test for clean git status
if ! [ -z "$(git status --porcelain)" ]; then
  error "git status is dirty\n${normal}Please commit or stash first."
fi

# delete local version tags
git tag -d $(git tag -l | grep -E "^(v[0-9]+(\.[0-9])?(\.[0-9]+)?|latest)$") > /dev/null 2>&1

# fetch tags from origin
git fetch origin --tags > /dev/null 2>&1

# get latest version from git tags
latestVersion=$(git tag -l | grep -E "^(v[0-9]+(\.[0-9])?(\.[0-9]+)?)$" | sort -r | head -n 1)

# if no latest version tag exists
if [[ "$latestVersion" = "" ]]; then
  noLatestVersion=true
  latestVersion="v0.0.0"
fi

# extract semver parts from latest version
latestVersionMajor=$(echo "${latestVersion:1}" | cut -d . -f 1)
latestVersionMinor=$(echo "${latestVersion:1}" | cut -d . -f 2)
latestVersionPatch=$(echo "${latestVersion:1}" | cut -d . -f 3)

# build new semver version
case $semverUpdate in
  "major")
    newVersion="v$((latestVersionMajor+1)).0.0"
    ;;
  "minor")
    newVersion="v${latestVersionMajor}.$((latestVersionMinor+1)).0"
    ;;
  "patch")
    newVersion="v${latestVersionMajor}.${latestVersionMinor}.$((latestVersionPatch+1))"
    ;;
esac

# inform about changes and ask to continue
displayBanner
branchColor=$([[ "$currentBranch" = "main" || "$currentBranch" = "master" ]] && echo "$green" || echo "$red")
printf "\n\n   Current Branch:   ${branchColor}${bold}${currentBranch}${normal}"
printf "\n\n   Latest Version:   $([[ $noLatestVersion ]] && echo "${red}${bold}N/A${normal}" || echo "${bold}${latestVersion}${normal}")"
printf "\n\n   New Version:      ${yellow}${bold}${newVersion}${normal}"
printf "\n\nContinue to create the version tag and push it to the git remote."
[[ -f package.json ]] && printf "\nThe version field in the package.json will be updated and committed."
printf "\n${gray}(press ANY KEY to continue or CTRL-C to cancel)${normal}\n"
read -rs -n 1
printf "\n"

# message for tag and commit
message="Release ${newVersion}"

# exit on errors
set -e

# update, commit and push package.json if present
if [[ -f package.json ]]; then
  xsed "s/(\"version\":[[:space:]]*\")(.+)(\")/\1${newVersion}\3/g" package.json
  git add package.json
  git commit -m "$message"
fi

# create and push tag
git tag -a -m "$message" $newVersion
git push origin $currentBranch
git push origin $newVersion

# print success message
printf "\n✅ ${green}Done!${normal}\n"
