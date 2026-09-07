#!/bin/sh
# Bootstrap a fresh macOS machine from these dotfiles.
#
# Prereqs (do these first — see README "SSH keys"):
#   1. Sign in to your Apple ID / restore basics.
#   2. Generate a new SSH key and add it to GitHub (github.com/settings/keys).
#      ssh -T git@github.com  should greet you as drasewkit.
#
# Then run:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/drasewkit/dotfiles/main/bootstrap.sh)"
# (or just: sh bootstrap.sh  from a manual clone)
set -eu

REPO="git@github.com:drasewkit/dotfiles.git"
DEST="$HOME/src/github.com/drasewkit/dotfiles"

echo "==> Xcode Command Line Tools"
xcode-select -p >/dev/null 2>&1 || { xcode-select --install; echo "Re-run after the install finishes."; exit 1; }

echo "==> Homebrew"
if ! command -v brew >/dev/null 2>&1; then
    NONINTERACTIVE=1 /bin/bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

echo "==> chezmoi"
command -v chezmoi >/dev/null 2>&1 || brew install chezmoi

echo "==> Clone dotfiles into the ghq tree"
if [ ! -d "$DEST/.git" ]; then
    mkdir -p "${DEST%/*}"
    git clone "$REPO" "$DEST"
fi

echo "==> chezmoi init --apply"
chezmoi init --source "$DEST" --apply

cat <<'DONE'

Done. Remaining manual steps:
  - Restart the shell (or open a new terminal) for zsh/starship/sheldon.
  - Grant Karabiner-Elements its Input Monitoring permission.
  - Sign in to apps: Claude Code (claude), gh (gh auth login), Slack, etc.
  - Re-add machine-specific Claude Code auto-mode rules via /permissions
    if you work in a repo that needs them (they are never stored in this repo).
DONE
