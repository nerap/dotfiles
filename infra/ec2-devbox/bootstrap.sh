#!/usr/bin/env bash
# Thin bootstrap for `devbox provision`. Runs FROM YOUR LAPTOP over SSH with agent
# forwarding (ssh -A), so it can clone your private repos with your 1Password key
# without any credential ever living on the box.
#
# It only needs to get git + the dotfiles repo, then hand off to the real, OS-aware
# installer (install.sh), which does everything else and enables the devbox services.
# Idempotent: safe to re-run after you change dotfiles.
set -euo pipefail

command -v git >/dev/null 2>&1 || { sudo apt-get update -y && sudo apt-get install -y git; }

mkdir -p "$HOME/personal"
if [ -d "$HOME/personal/dotfiles/.git" ]; then
  git -C "$HOME/personal/dotfiles" pull --ff-only -q || true
else
  git clone git@github.com:nerap/dotfiles.git "$HOME/personal/dotfiles"
fi

# DEVBOX=1 turns on the fleet-boot + idle-stop systemd units in install/linux.sh.
exec env DEVBOX=1 DEVBOX_IDLE_MINUTES="${IDLE_MINUTES:-30}" \
  bash "$HOME/personal/dotfiles/install.sh"
