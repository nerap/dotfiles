#!/usr/bin/env bash
# Linux (Debian/Ubuntu) setup. Two phases called by install.sh:
#   os_prep   — package manager + base tools + SSH, so common_setup can clone
#   os_finish — editor/runtime tooling + shell + (on EC2) the devbox services
# Assumes lib.sh is sourced. Skips macOS-only pieces (aerospace, alacritty, brew).

os_prep() {
  have apt-get || die "Linux path currently supports Debian/Ubuntu (apt) only."
  log "apt: base packages"
  sudo apt-get update -y
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential git curl wget unzip ca-certificates \
    zsh tmux stow fzf ripgrep fd-find jq gh \
    python3 python3-pip pkg-config libssl-dev \
    htop ncdu tree rsync
}

os_finish() {
  log "Neovim (official build; apt's is too old)"
  if ! have nvim; then
    local arch tgz
    case "$(uname -m)" in
      aarch64|arm64) arch=arm64 ;;
      x86_64|amd64)  arch=x86_64 ;;
      *) die "unsupported arch $(uname -m) for nvim" ;;
    esac
    tgz=/tmp/nvim-linux-$arch.tar.gz
    if curl -fsSL -o "$tgz" "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-$arch.tar.gz"; then
      sudo rm -rf /opt/nvim && sudo mkdir -p /opt/nvim
      sudo tar -xzf "$tgz" -C /opt/nvim --strip-components=1
      sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
    else
      warn "nvim release download failed; falling back to apt"; sudo apt-get install -y neovim
    fi
  fi

  log "Node (NodeSource 22) + Bun"
  have node || { curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -; sudo apt-get install -y nodejs; }
  have bun  || curl -fsSL https://bun.sh/install | bash
  export PATH="$HOME/.bun/bin:$PATH"

  log "Claude Code"
  have claude || sudo npm install -g @anthropic-ai/claude-code

  log "Docker (per-worktree dev stacks: compose + local supabase)"
  if ! have docker; then
    curl -fsSL https://get.docker.com | sudo sh
    sudo usermod -aG docker "$USER"          # re-login (or fleet-boot) picks up the group
    sudo systemctl enable --now docker
  fi

  log "Stable SSH agent socket (forwarded agent → git@github works in tmux panes)"
  mkdir -p ~/.ssh && chmod 700 ~/.ssh
  cat > ~/.ssh/rc <<'RC'
#!/bin/sh
# sshd runs this on every incoming connection. Point a stable path at the current
# forwarded SSH agent so tmux panes (which outlive any single SSH connection) keep
# authenticating to git@github after reconnects.
[ -n "$SSH_AUTH_SOCK" ] && ln -sf "$SSH_AUTH_SOCK" "$HOME/.ssh/ssh_auth_sock"
RC
  chmod 644 ~/.ssh/rc

  log "1Password CLI (op) — for 'op run' secret injection"
  if ! have op; then
    curl -fsSL https://downloads.1password.com/linux/keys/1password.asc \
      | sudo gpg --dearmor --yes -o /usr/share/keyrings/1password-archive-keyring.gpg 2>/dev/null || true
    local arch; arch=$(dpkg --print-architecture)
    echo "deb [arch=$arch signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$arch stable main" \
      | sudo tee /etc/apt/sources.list.d/1password.list >/dev/null
    sudo apt-get update -y && sudo apt-get install -y 1password-cli || warn "op install failed (non-fatal)"
  fi

  log "PATH for login shells"
  grep -q 'dotfiles/etc/bin/.local/scripts' ~/.profile 2>/dev/null || \
    echo 'export PATH="$HOME/bin/.local/scripts:$HOME/.bun/bin:$PATH"' >> ~/.profile

  log "Default shell -> zsh"
  [ "$(getent passwd "$USER" | cut -d: -f7)" = "$(command -v zsh)" ] || sudo chsh -s "$(command -v zsh)" "$USER"

  # On EC2 (or with DEVBOX=1) wire the boot-time session rebuild + idle auto-stop.
  if is_ec2 || [ "${DEVBOX:-0}" = 1 ]; then
    log "Devbox services (fleet-boot + idle auto-stop)"
    local units="$HOME/personal/dotfiles/infra/ec2-devbox/systemd"
    local idle="${DEVBOX_IDLE_MINUTES:-30}"
    sudo cp "$units/fleet-boot.service" "$units/devbox-idle-stop.service" "$units/devbox-idle-stop.timer" /etc/systemd/system/
    sudo sed -i "s|@USER@|$USER|g; s|@IDLE_MINUTES@|$idle|g" \
      /etc/systemd/system/fleet-boot.service /etc/systemd/system/devbox-idle-stop.service
    sudo systemctl daemon-reload
    sudo systemctl enable fleet-boot.service
    sudo systemctl enable --now devbox-idle-stop.timer
    echo "$USER ALL=(ALL) NOPASSWD: /sbin/shutdown, /usr/sbin/shutdown" | sudo tee /etc/sudoers.d/devbox-shutdown >/dev/null
    sudo chmod 440 /etc/sudoers.d/devbox-shutdown
    loginctl enable-linger "$USER" 2>/dev/null || true
  fi

  log "Linux setup complete"
  echo "  Next: clone-workspace -w git@github.com:<org>/<repo>.git"
}
