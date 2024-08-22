#!/usr/bin/env zsh

# VARS
START_TIME=$SECONDS
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo ""
echo "---------- dotfiles --------"
echo ""
echo "This will install & setup all the system."
read -n 1 -r -p "Ready? [y/N]" response
case $response in
    [yY]) echo "";;
    *) exit 1;;
esac

read -e -p "Please enter machine name: " machine_name
MACHINE_NAME=${machine_name:-nerap}

echo ""
echo "----- XCode Command Line Tools -----"

# cf. https://github.com/paulirish/dotfiles/blob/master/setup-a-new-machine.sh#L87

if ! xcode-select --print-path &> /dev/null; then
    xcode-select --install &> /dev/null
    until xcode-select --print-path &> /dev/null; do
        sleep 5
    done
    print_result $? 'Install XCode Command Line Tools'
    sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer
    print_result $? 'Make "xcode-select" developer directory point to Xcode'
    sudo xcodebuild -license
    print_result $? 'Agree with the XCode Command Line Tools licence'
fi

echo ""
echo "----- install homebrew -----"

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew doctor
brew update
brew upgrade

echo "----- brew: install formulas -----"
xargs brew install < "$DOTFILES_DIR/packages/brew"
brew cleanup

echo ""
echo "----- configure neovim -----"

brew install neovim

## Default dir
#mdkir -p ~/personal ~/work ~/vaults
#
## Install Homebrew packages
#brew install \
#   autoconf \
#   automake \
#   bash \
#   bash-completion \
#   bat \
#   cmake \
#   coreutils \
#   ctags \
#   curl \
#   diff-so-fancy \
#   docker \
#   fd \
#   font-hack-nerd-font \
#   fzf \
#   gcc \
#   git \
#   git-delta \
#   gnu-sed \
#   gnu-tar \
#   gnu-which \
#   gpg \
#   grep \
#   htop \
#   jq \
#   less \
#   libtool \
#   lsd \
#   luarocks \
#   luv \
#   make \
#   nvm \
#   neovim \
#   node \
#   openssh \
#   openssl \
#   p7zip \
#   pandoc \
#   python \
#   python@3.9 \
#   ripgrep \
#   ruby \
#  stripe-cli \
#   freetype \
#   ImageMagick \
#   supabase \
#   sqlite \
#   tmux \
#   tree-sitter \
#   tree-sitter-lua \
#   tree-sitter-python \
#   tree-sitter-typescript \
#   tree-sitter-yaml \
#   unibilium \
#   unzip \
#   wget \
#   xz \
#   yarn \
#   zsh
#
## Install Homebrew casks
#brew install --cask \
#  arc \
#  discord \
#  docker \
#  dbeaver-community
#  obsidian \
#  iterm2 \
#  notion \
#  redis \
#  slack \
#  spotify
#
## Install Rust
#curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
#
## Install Node
#nvm install v18.20.0
#nvm alias default v18.20.0
#
## Install miniconda
#mkdir -p ~/personal/miniconda3
#curl https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh -o ~/personal/miniconda3/miniconda.sh
#bash ~/personal/miniconda3/miniconda.sh -b -u -p ~/personal/miniconda3
#rm -rf ~/personal/miniconda3/miniconda.sh
#export PATH=$PATH:~/personal/miniconda3/bin
#
## Install Magick
#luarocks --local --lua-version=5.1 install magick

## Symbolic links
# ZSH
git clone https://github.com/nerap/zsh.git ~/personal/zsh
ln -sf ~/personal/zsh/.zshrc ~/.zshrc
ln -sf ~/personal/zsh/.zsh_profile ~/.zsh_profile

# TMUX
mkdir -p ~/.config/tmux-plugins
git clone https://github.com/tmux-plugins/tmux-resurrect ~/.config/tmux-plugins/tmux-resurrect
git clone https://github.com/nerap/tmux.git ~/personal/tmux
ln -sf ~/personal/tmux/.tmux-cht-command ~/.tmux-cht-command
ln -sf ~/personal/tmux/.tmux-cht-languages ~/.tmux-cht-languages
ln -sf ~/personal/tmux/.tmux.conf ~/.tmux.conf

# Git
ln -sf ~/personal/dotfiles/git/.gitconfig ~/.gitconfig

# Neovim
git clone https://github.com/ThePrimeagen/harpoon.git -b harpoon2 ~/personal/harpoon
git clone https://github.com/nerap/gitmoji.nvim.git ~/personal/gitmoji
git clone https://github.com/nerap/nvim.git ~/personal/nvim
ln -sf ~/personal/nvim ~/.config

# Local
chmod +x ~/personal/dotfiles/bin/.local/scripts/*
ln -sf ~/personal/dotfiles/bin  ~
