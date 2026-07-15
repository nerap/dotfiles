#!/usr/bin/env bash
# Shared helpers + OS detection for the dotfiles installer.
# Sourced by install.sh and the per-OS scripts.

log()  { printf '\n\033[1;36m▸ %s\033[0m\n' "$*"; }
warn() { printf '\033[33m! %s\033[0m\n' "$*" >&2; }
die()  { printf '\033[31m✗ %s\033[0m\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

# print_result <rc> <label> — kept for the legacy macOS steps that call it.
print_result() { [ "$1" -eq 0 ] && printf '  ✓ %s\n' "$2" || printf '  ✗ %s\n' "$2"; }

# OS -> "macos" | "linux"
detect_os() {
  case "$(uname -s)" in
    Darwin) OS=macos ;;
    Linux)  OS=linux ;;
    *) die "unsupported OS: $(uname -s)" ;;
  esac
  export OS
}

# On EC2? (used to auto-enable the devbox systemd units on Linux)
is_ec2() {
  [ -r /sys/hypervisor/uuid ] && grep -qi '^ec2' /sys/hypervisor/uuid 2>/dev/null && return 0
  [ -r /sys/class/dmi/id/board_vendor ] && grep -qi 'amazon' /sys/class/dmi/id/board_vendor 2>/dev/null && return 0
  return 1
}

# clone_or_pull <git-url> <dest> — idempotent
clone_or_pull() {
  local url="$1" dest="$2"
  if [ -d "$dest/.git" ]; then
    git -C "$dest" pull --ff-only -q 2>/dev/null || warn "could not fast-forward $dest"
  else
    git clone -q "$url" "$dest"
  fi
}

# require a working SSH agent for cloning private repos (git@github.com)
require_github_ssh() {
  if ! ssh -o BatchMode=yes -o ConnectTimeout=8 -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    die "GitHub SSH auth failed. On macOS: unlock 1Password. On Linux: ssh in with agent forwarding (devbox provision / ssh -A), or load a key."
  fi
}
