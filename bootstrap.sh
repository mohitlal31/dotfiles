#!/usr/bin/env bash
# One-time setup: takes this machine (or a fresh Mac) to a built nix-darwin
# config. Run once. After it succeeds, use ./rebuild.sh for every later change.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

echo "==> Step 1: Determinate Nix"
if command -v nix >/dev/null 2>&1; then
  echo "    nix already installed, skipping"
else
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

echo "==> Step 2: symlink this repo to ~/.dotfiles"
# home.nix resolves its mkOutOfStoreSymlink paths through ~/.dotfiles, so this
# must exist before the first switch.
ln -sfn "$DIR" ~/.dotfiles

echo "==> Step 3: check the configured username"
REAL_USER="$(whoami)"
FLAKE_USER="$(sed -nE 's/^[[:space:]]*user = "([^"]+)";.*/\1/p' "$DIR/flake.nix" | head -n1)"
if [ "$FLAKE_USER" != "$REAL_USER" ]; then
  echo "    flake.nix is set to \"$FLAKE_USER\" but you are \"$REAL_USER\"."
  echo "    Edit the single 'user =' line in flake.nix, then re-run this script."
  exit 1
fi
echo "    ok ($REAL_USER)"

echo "==> Step 4: first darwin-rebuild switch"
# Your existing ~/.zshrc / ~/.zprofile / ~/.tmux.conf Stow symlinks and your
# real ~/.p10k.zsh are backed up to <name>.before-nix, not deleted.
# darwin-rebuild doesn't exist on PATH yet, so run it straight from the flake
# this once. sudo scrubs PATH, so resolve nix's absolute path first.
NIX_BIN="$(command -v nix)"
sudo "$NIX_BIN" run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- \
  switch --flake ~/.dotfiles#mac

echo ""
echo "==> Done. Open a NEW terminal and sanity-check your shell + nvim + tmux."
echo "    Future changes:  ./rebuild.sh"
echo "    Roll back a bad build:  sudo darwin-rebuild --rollback"
