#!/bin/bash

t="${TERM:-"dumb"}"
r=$(tput -T$t setaf 1)
g=$(tput -T$t setaf 2)
y=$(tput -T$t setaf 3)
m=$(tput -T$t setaf 5)
b=$(tput -T$t setaf 12)
u=$(tput -T$t smul)
x=$(tput -T$t sgr0)

script="release.sh"

if [[ -f $script ]] && ! grep -q "simbo/release-version-script" $script; then
  printf "\n${r}ERROR: file '${script}' already exists\n"
  exit 1
fi

cat <<'EOF' > $script
#!/bin/bash
# ╔═══════════════════════════════════════════════════════╗
# ║                                                       ║
# ║  RELEASE VERSION SCRIPT                               ║
# ║  https://github.com/simbo/release-version-script      ║
# ║                                                       ║
# ╟───────────────────────────────────────────────────────╢
# ║                                                       ║
# ║  Author: Simon Lepel (https://simbo.de/)              ║
# ║  License: MIT (http://simbo.mit-license.org/)         ║
# ║                                                       ║
# ║  A simple yet convenient bash script to create a      ║
# ║  semantic version tag and push it to the git remote.  ║
# ║                                                       ║
# ╚═══════════════════════════════════════════════════════╝

# script version tag to use (available versions: https://github.com/simbo/release-version-script/tags)
VERSION=v1

script=$(curl -so- https://raw.githubusercontent.com/simbo/release-version-script/${VERSION}/release.sh)
if [[ "${script:0:3}" = "404" ]]; then
  t="${TERM:-"dumb"}"
  printf "\n$(tput -T$t setaf 1)ERROR: could not find version '${VERSION}'$(tput -T$t sgr0)"
  printf "\nSee ${b}${u}https://github.com/simbo/release-version-script/tags${x} for available versions.\n"
  exit 1
fi
bash -c "$script" -s $1
EOF
chmod +x $script

printf "\n${m}┌───────────────────────────────────────────────────┐${x}"
printf "\n${m}│  ${y}RELEASE VERSION SCRIPT${m}                           │${x}"
printf "\n${m}│  ${b}${u}https://github.com/simbo/release-version-script${x}${m}  │${x}"
printf "\n${m}└───────────────────────────────────────────────────┘${x}"
printf "\n\n✅ ${g}Release Script successfully installed!${x}"
printf "\n\nUsage:\n\n  ./$script UPDATE"
printf "\n\nAllowed values for UPDATE are \"major\", \"minor\" or \"patch\".\n"
