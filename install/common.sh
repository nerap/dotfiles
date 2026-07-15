#!/usr/bin/env bash
# Cross-platform bootstrap: clone the config repos and link everything into place.
# Runs AFTER os_prep (which makes git + SSH work) and BEFORE os_finish.
# Assumes lib.sh is already sourced.

common_setup() {
  log "Directories"
  mkdir -p ~/personal ~/config ~/work ~/tools ~/.config/nvim ~/.claude

  log "Config repos (need GitHub SSH)"
  require_github_ssh
  # dotfiles is already here (we're running from it); the rest are separate repos.
  clone_or_pull git@github.com:nerap/dotfiles.git "$HOME/personal/dotfiles"
  clone_or_pull git@github.com:nerap/nvim.git     "$HOME/config/nvim"
  clone_or_pull git@github.com:nerap/tmux.git     "$HOME/config/tmux"
  clone_or_pull git@github.com:nerap/zsh.git      "$HOME/config/zsh"

  log "tmux plugin manager"
  [ -d ~/.tmux/plugins/tpm ] || git clone -q --depth 1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

  log "oh-my-zsh + zsh-defer (the shared .zshrc expects them)"
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi
  [ -d ~/tools/zsh-defer ] || git clone -q https://github.com/romkatv/zsh-defer.git ~/tools/zsh-defer

  log "Link configs into place"
  chmod +x ~/personal/dotfiles/etc/bin/.local/scripts/* 2>/dev/null || true
  # ~/bin -> the scripts dir (switch-workspace, clone-workspace, fleet-*, devbox…)
  [ -e ~/bin ] || ln -s personal/dotfiles/etc/bin ~/bin
  ln -sfn ~/config/tmux/.tmux.conf "$HOME/.tmux.conf"
  ln -sfn ~/config/zsh/.zshrc      "$HOME/.zshrc"
  # nvim + claude are stow packages (per-file symlinks)
  stow --dir="$HOME/config"            --target="$HOME/.config/nvim" -R nvim
  stow --dir="$HOME/personal/dotfiles" --target="$HOME/.claude"      -R dotclaude

  log "Rust (rustup)"
  if ! have rustc; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  fi
}
