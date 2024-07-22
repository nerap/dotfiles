#!/usr/bin/env zsh

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Default dir
mdkir -p ~/personal ~/work

# Install Homebrew packages
brew install \
   autoconf \
   automake \
   bash \
   bash-completion \
   bat \
   cmake \
   coreutils \
   ctags \
   curl \
   diff-so-fancy \
   docker \
   fd \
   font-hack-nerd-font \
   fzf \
   gcc \
   git \
   git-delta \
   gnu-sed \
   gnu-tar \
   gnu-which \
   gpg \
   grep \
   htop \
   jq \
   less \
   libtool \
   lsd \
   luarocks \
   luv \
   make \
   nvm \
   neovim \
   node \
   openssh \
   openssl \
   p7zip \
   pandoc \
   python \
   python@3.9 \
   ripgrep \
   ruby \
   stripe-cli \
   supabase \
   sqlite \
   tmux \
   tree-sitter \
   tree-sitter-lua \
   tree-sitter-python \
   tree-sitter-typescript \
   tree-sitter-yaml \
   unibilium \
   unzip \
   wget \
   xz \
   yarn \
   zsh

# Install Homebrew casks
brew install --cask \
  arc \
  discord \
  docker \
  dbeaver-community
  obsidian \
  iterm2 \
  notion \
  redis \
  slack \
  spotify

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install Node
nvm install v18.19.0
nvm alias default v18.19.0

# Install miniconda
mkdir -p ~/personal/miniconda3
curl https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh -o ~/personal/miniconda3/miniconda.sh
bash ~/personal/miniconda3/miniconda.sh -b -u -p ~/personal/miniconda3
rm -rf ~/personal/miniconda3/miniconda.sh
export PATH=$PATH:~/personal/miniconda3/bin

## Symbolic links
# ZSH
ln -sf ~/.dotfiles/zsh/.zshrc ~/.zshrc
ln -sf ~/.dotfiles/.zsh/.zsh_profile ~/.zsh_profile

# TMUX
ln -sf ~/.dotfiles/tmux/.tmux-cht-command ~/.tmux-cht-command
ln -sf ~/.dotfiles/tmux/.tmux-cht-languages ~/.tmux-cht-languages
ln -sf ~/.dotfiles/tmux/.tmux.conf ~/.tmux.conf

# Git
ln -sf ~/.dotfiles/git/.gitconfig ~/.gitconfig

# Neovim
git clone https://github.com/nerap/nvim ~/.dotfiles/nvim
git clone https://github.com/ThePrimeagen/harpoon.git ~/personal/harpoon -b harpoon2
git clone https://github.com/nerap/gitmoji.nvim.git ~/personal/gitmoji
ln -sf ./nvim ~/.config

# Local
chmod +x ~/.dotfiles/bin/.local/scripts/*
ln -sf ~/.dotfiles/bin  ~
