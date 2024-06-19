#!/usr/bin/env zsh


# Install Homebrew
#/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Homebrew packages
# brew install \
#    autoconf \
#    automake \
#    bash \
#    bash-completion \
#    bat \
#    cmake \
#    coreutils \
#    ctags \
#    curl \
#    diff-so-fancy \
#    docker \
#    fd \
#    font-hack-nerd-font \
#    fzf \
#    gcc \
#    git \
#    git-delta \
#    gnu-sed \
#    gnu-tar \
#    gnu-which \
#    gpg \
#    grep \
#    htop \
#    jq \
#    less \
#    libtool \
#    lsd \
#    luarocks \
#    luv \
#    make \
#    neovim \
#    node \
#    openssh \
#    openssl \
#    p7zip \
#    pandoc \
#    python \
#    python@3.9 \
#    ripgrep \
#    ruby \
#    stripe-cli \
#    supabase \
#    sqlite \
#    tmux \
#    tree-sitter \
#    tree-sitter-lua \
#    tree-sitter-python \
#    tree-sitter-typescript \
#    tree-sitter-yaml \
#    unibilium \
#    unzip \
#    wget \
#    xz \
#    yarn \
#    zsh


# Install Homebrew casks

# brew install --cask \
#   discord \
#   docker \
#   dbeaver-community
#   google-chrome \
#   iterm2 \
#   notion \
#   slack \
#   spotify \
#   visual-studio-code \

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
#git clone https://github.com/nerap/nvim ~/.dotfiles/nvim
#git clone https://github.com/ThePrimeagen/harpoon.git ~/personal/harpoon -b harpoon2
#ln -sf ./nvim ~/.config

# Local
chmod +x ~/.dotfiles/bin/.local/scripts/*
ln -sf ~/.dotfiles/bin  ~
