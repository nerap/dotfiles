#!/usr/bin/env bash
# dotfiles installer — works on macOS and Debian/Ubuntu Linux.
#
#   ./install.sh            # auto-detects the OS and sets everything up
#   DEVBOX=1 ./install.sh   # Linux: also wire the EC2 devbox services (auto on EC2)
#
# Flow:  os_prep  (package manager + SSH so cloning works)
#     ->  common_setup  (clone config repos, stow, link, oh-my-zsh, rust)
#     ->  os_finish  (OS-specific tooling + system config)
#
# macOS logic is unchanged from the original script, just relocated to install/macos.sh.
set -uo pipefail

START_TIME=$SECONDS
MACHINE_NAME=nerap
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export MACHINE_NAME DOTFILES_DIR

# shellcheck source=install/lib.sh
source "$DOTFILES_DIR/install/lib.sh"
detect_os

echo
echo "---------- dotfiles ($OS) ----------"
echo

source "$DOTFILES_DIR/install/$OS.sh"     # defines os_prep + os_finish
source "$DOTFILES_DIR/install/common.sh"  # defines common_setup

os_prep
common_setup
os_finish

ELAPSED=$((SECONDS - START_TIME))
echo
echo "-----------------------------"
echo "----- dotfiles done ($OS) -----"
echo "Duration: $((ELAPSED / 60)) min $((ELAPSED % 60)) sec"
echo "-----------------------------"
