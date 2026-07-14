#!/usr/bin/env bash
# devbox provisioning — run FROM YOUR LAPTOP via `devbox provision`, which SSHes in
# with agent forwarding (ssh -A). That means this script can `git clone` your private
# repos using your 1Password SSH key without any credential ever living on the box.
#
# Idempotent: safe to re-run after you change dotfiles.
set -euo pipefail

log() { printf '\n\033[1;36m▸ %s\033[0m\n' "$*"; }

USERNAME="$(whoami)"
IDLE_MINUTES="${IDLE_MINUTES:-30}"

log "Verifying SSH agent forwarding (needed to clone private repos)"
if ! ssh-add -l >/dev/null 2>&1; then
  echo "✗ No SSH agent forwarded. Re-run with: devbox provision   (it uses ssh -A)" >&2
  exit 1
fi
ssh-keyscan -H github.com >> ~/.ssh/known_hosts 2>/dev/null || true
git config --global --add safe.directory '*'

log "Base packages"
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  build-essential git curl wget unzip ca-certificates \
  zsh tmux stow fzf ripgrep fd-find jq gh \
  python3 python3-pip pkg-config libssl-dev \
  htop ncdu tree rsync

log "Neovim (apt's is too old; use the official arm64 build)"
if ! command -v nvim >/dev/null 2>&1; then
  NVIM_TGZ=/tmp/nvim-linux-arm64.tar.gz
  if curl -fsSL -o "$NVIM_TGZ" https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.tar.gz; then
    sudo rm -rf /opt/nvim && sudo mkdir -p /opt/nvim
    sudo tar -xzf "$NVIM_TGZ" -C /opt/nvim --strip-components=1
    sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
  else
    sudo apt-get install -y neovim   # fallback
  fi
fi

log "Node (NodeSource 22) + Bun"
if ! command -v node >/dev/null 2>&1; then
  curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
  sudo apt-get install -y nodejs
fi
if ! command -v bun >/dev/null 2>&1; then
  curl -fsSL https://bun.sh/install | bash
fi
export PATH="$HOME/.bun/bin:$PATH"

log "Claude Code"
if ! command -v claude >/dev/null 2>&1; then
  sudo npm install -g @anthropic-ai/claude-code
fi

log "Cloning dotfiles + config repos (via your forwarded key)"
mkdir -p ~/personal ~/config ~/work ~/tools
clone_or_pull() {
  local repo="$1" dest="$2"
  if [ -d "$dest/.git" ]; then git -C "$dest" pull --ff-only || true
  else git clone "$repo" "$dest"; fi
}
clone_or_pull git@github.com:nerap/dotfiles.git ~/personal/dotfiles
clone_or_pull git@github.com:nerap/tmux.git     ~/config/tmux
clone_or_pull git@github.com:nerap/nvim.git     ~/config/nvim
clone_or_pull git@github.com:nerap/zsh.git      ~/config/zsh
# alacritty + aerospace are macOS-side only (terminal emulator / window manager) — skipped.

log "tmux plugin manager"
[ -d ~/.tmux/plugins/tpm ] || git clone --depth 1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

log "Linking configs (same layout as the Mac)"
chmod +x ~/personal/dotfiles/etc/bin/.local/scripts/* || true
# ~/bin -> dotfiles/etc/bin  (this is what puts switch-workspace/fleet-* on PATH)
[ -e ~/bin ] || ln -s personal/dotfiles/etc/bin ~/bin
ln -sfn ~/config/tmux/.tmux.conf ~/.tmux.conf
ln -sfn ~/config/zsh/.zshrc      ~/.zshrc
mkdir -p ~/.config/nvim ~/.claude
stow --dir="$HOME/config"           --target="$HOME/.config/nvim" -R nvim
stow --dir="$HOME/personal/dotfiles" --target="$HOME/.claude"      -R dotclaude

grep -q 'dotfiles/etc/bin/.local/scripts' ~/.profile 2>/dev/null || \
  echo 'export PATH="$HOME/bin/.local/scripts:$HOME/.bun/bin:$PATH"' >> ~/.profile

log "Default shell -> zsh"
[ "$SHELL" = "$(command -v zsh)" ] || sudo chsh -s "$(command -v zsh)" "$USERNAME"

log "Installing systemd units (boot-time sessions + idle auto-stop)"
UNITS=~/personal/dotfiles/infra/ec2-devbox/systemd
sudo cp "$UNITS/fleet-boot.service" /etc/systemd/system/
sudo cp "$UNITS/devbox-idle-stop.service" /etc/systemd/system/
sudo cp "$UNITS/devbox-idle-stop.timer" /etc/systemd/system/
# bake the login user + idle threshold into the units
sudo sed -i "s|@USER@|$USERNAME|g; s|@IDLE_MINUTES@|$IDLE_MINUTES|g" \
  /etc/systemd/system/fleet-boot.service /etc/systemd/system/devbox-idle-stop.service
sudo systemctl daemon-reload
sudo systemctl enable fleet-boot.service
sudo systemctl enable --now devbox-idle-stop.timer

# The idle-stop runs `shutdown`, so let it do that without a password.
echo "$USERNAME ALL=(ALL) NOPASSWD: /sbin/shutdown, /usr/sbin/shutdown" \
  | sudo tee /etc/sudoers.d/devbox-shutdown >/dev/null
sudo chmod 440 /etc/sudoers.d/devbox-shutdown

cat <<EOF

✅ devbox provisioned.

   Next: clone your workspaces (this creates the 8 worktrees + tmux sessions):

     clone-workspace -w git@github.com:<org>/prsnl_app.git

   Then from your laptop:  devbox up

   Auto-stop: after ${IDLE_MINUTES}m idle (no tmux client, no Claude WORKING, low load).
   Disable it any time with:  touch ~/.devbox-nostop

EOF
