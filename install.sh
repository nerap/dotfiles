#!/usr/bin/env zsh

# VARS
START_TIME=$SECONDS
MACHINE_NAME=nerap
DOTFILES_DIR="$( cd "$( dirname "${(%):-%x}" )" && pwd )"

echo ""
echo "---------- dotfiles --------"
echo ""
echo "This will install & setup all the system."

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

if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Homebrew is already installed."
fi

brew doctor
brew update
brew upgrade


echo ""
echo "----- brew: install -----"

# Must be done before installing packages
xargs brew install < "$DOTFILES_DIR/packages/brew"
brew cleanup


echo ""
echo "----- brew: cask -----"

export HOMEBREW_CASK_OPTS="--appdir=/Applications"
xargs brew install --cask < "$DOTFILES_DIR/packages/cask"


echo ""
echo "----- brew: fonts -----"

xargs brew install < "$DOTFILES_DIR/packages/fonts"


echo ""
echo "---- 1Password ----"
# For the sync to CLI then close
open -W /Applications/1Password.app
# Reopen for ssh cloning
open /Applications/1Password.app

echo "---- Verifying 1Password SSH agent ----"
# Ensure 1Password is fully initialized
sleep 3
# Test the SSH connection
ssh -T git@github.com || {
  echo "SSH connection to GitHub failed. Please ensure 1Password is properly set up."
  echo "You may need to manually approve the SSH key in 1Password and try again."
  read -p "Press Enter to continue after you've verified 1Password SSH access..."
}

# Check if 1Password CLI is installed, install if needed
if ! command -v op &> /dev/null; then
    echo "Installing 1Password CLI..."
    brew install 1password-cli
fi

# Create or update SSH config to use 1Password SSH agent
mkdir -p ~/.ssh
touch ~/.ssh/config

# Check if 1Password SSH agent config is already present
if ! grep -q "1Password SSH agent" ~/.ssh/config; then
    echo "Configuring SSH to use 1Password SSH agent..."
    cat << 'EOF' >> ~/.ssh/config

# 1Password SSH agent configuration
Host *
    IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
EOF
fi

# Configure shell to use 1Password SSH agent
if [[ "$SHELL" == *"zsh"* ]]; then
    # For zsh
    SHELL_RC="$HOME/.zshrc"
elif [[ "$SHELL" == *"bash"* ]]; then
    # For bash
    SHELL_RC="$HOME/.bashrc"
fi

if [ -n "$SHELL_RC" ]; then
    if ! grep -q "SSH_AUTH_SOCK" "$SHELL_RC"; then
        echo "Configuring shell to use 1Password SSH agent..."
        cat << 'EOF' >> "$SHELL_RC"

# 1Password SSH agent
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
EOF
    fi
fi

echo ""
echo "----- setup: zsh -----"
# Oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# Defer plugin
git clone https://github.com/romkatv/zsh-defer.git ~/tools/zsh-defer

echo "1Password SSH agent configuration complete!"


echo ""
echo "----- Preparing for stow -----"
[ -f ~/.zshrc ] && rm ~/.zshrc

# Pre-Stow
stow --dir="$HOME/personal" --target=$HOME -S tmux zsh

echo ""
echo "----- default dirs -----"

mkdir -p ~/personal ~/config ~/work ~/tools

echo ""
echo "----- setup: tmux -----"

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Personnal space git clone
git clone git@github.com:nerap/nvim.git ~/personal/nvim
git clone git@github.com:nerap/tmux.git ~/personal/tmux
git clone git@github.com:nerap/zsh.git ~/personal/zsh
git clone git@github.com:nerap/aerospace.git ~/personal/aerospace
git clone git@github.com:nerap/alacritty.git ~/personal/alacritty
git clone git@github.com:nerap/qmk_firmware.git ~/personal/qmk_firmware --depth 1

# Giving execution rights to scripts
chmod +x ~/personal/dotfiles/etc/.local/scripts/*

# Create nvim dir if not exists
mkdir -p ~/.config/nvim
mkdir -p ~/.config/aerospace
mkdir -p ~/.config/alacritty

# Stow everything else
stow --dir="$HOME/config" --target="$HOME/.config/nvim" -S nvim
stow --dir="$HOME/config" --target="$HOME/.config/aerospace" -S aerospace
stow --dir="$HOME/config" --target="$HOME/.config/alacritty" -S alacritty


echo ""
echo "----- install colima -----"

brew install colima
brew services start colima
colima start

echo ""
echo "----- rust -----"

if ! command -v rustc &> /dev/null; then
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
else
    echo "Rust is already installed."
    rustc --version
fi

echo ""
echo "----- configure DBeaver -----"
# On open import all file from prefereces/dbeaver
# No cli available for this behavior :(
open -W /Applications/DBeaver.app

echo ""
echo "----- default browser -----"
if ! command -v defaultbrowser &> /dev/null; then
    echo "Installing defaultbrowser..."
    brew install defaultbrowser
fi
# Remove default browser pop-up in the future
defaultbrowser browser


echo ""
echo "----- conf nightlight -----"
if ! command -v nightlight &> /dev/null; then
    echo "Installing nightlight..."
    brew install smudge/smudge/nightlight
fi
nightlight temp 100
nightlight schedule 00:00 23:59

echo ""
echo "----- nvm -----"
if [ ! -d "$HOME/.nvm" ]; then
    echo "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

    # Load NVM for the current script
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
else
    echo "NVM is already installed."
    # Load NVM for the current script
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

# Now install Node
if ! nvm ls | grep -q "v22"; then
    nvm install v22
    nvm alias default v22
else
    echo "Node v22 is already installed."
fi

echo ""
echo "----- lua magick -----"
if ! command -v luarocks &> /dev/null; then
    echo "Installing LuaRocks..."
    brew install luarocks
fi

# Check if magick is already installed for Lua 5.1
if ! luarocks --lua-version=5.1 list | grep -q "magick"; then
    echo "Installing magick for Lua 5.1..."
    luarocks --local --lua-version=5.1 install magick
else
    echo "Magick is already installed for Lua 5.1."
fi

echo ""
echo "----- setup mac system -----"

sudo -v
# Need to be in recovery mode
#csrutil disable
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

###############################################################################

########## General UI/UX

# Set computer name (as done via System Preferences → Sharing)
sudo scutil --set ComputerName "${MACHINE_NAME}"
sudo scutil --set HostName "${MACHINE_NAME}"
sudo scutil --set LocalHostName "${MACHINE_NAME}"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "${MACHINE_NAME}"

# Enable dark mode
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
defaults write NSGlobalDomain AppleAccentColor -string "-1"

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "

# Disable opening and closing window animations
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Disable the crash reporter
defaults write com.apple.CrashReporter DialogType -string "none"

# Disable smart quotes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable smart dashes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Set language and text formats
defaults write NSGlobalDomain AppleLanguages -array "en"
defaults write NSGlobalDomain AppleLocale -string "fr_FR@currency=EUR"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
defaults write NSGlobalDomain AppleMetricUnits -bool true

# Set the timezone; see `sudo systemsetup -listtimezones` for other values
sudo systemsetup -settimezone "Europe/Paris" > /dev/null

# Remove animation ;)
# cf https://www.reddit.com/r/MacOS/comments/11p10ho/comment/ke0ikp0
defaults write -g NSAutomaticWindowAnimationsEnabled -bool false
defaults write -g NSScrollAnimationEnabled -bool false
defaults write -g NSWindowResizeTime -float 0.001
defaults write -g QLPanelAnimationDuration -float 0
defaults write -g NSScrollViewRubberbanding -bool false
defaults write -g NSDocumentRevisionsWindowTransformAnimation -bool false
defaults write -g NSToolbarFullScreenAnimationDuration -float 0
defaults write -g NSBrowserColumnAnimationSpeedMultiplier -float 0
defaults write com.apple.finder DisableAllAnimations -bool true
defaults write com.apple.Mail DisableSendAnimations -bool true
defaults write com.apple.Mail DisableReplyAnimations -bool true
defaults write NSGlobalDomain NSWindowResizeTime .001

######### Preferences

######### Login

# Disable password hints
defaults write com.apple.loginwindow RetriesUntilHint -int 0

######### Terminal & iTerm 2

# Only use UTF-8 in Terminal.app
defaults write com.apple.terminal StringEncodings -array 4

########## Trackpad, mouse, keyboard, Bluetooth accessories, and input

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

########## Screen

# Save screenshots to the desktop
defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

######### Findepple.screensaver askForPasswordDelay -int 0r

#pple.screensaver askForPasswordDelay -int 0 Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Avoid creating .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Avoid creating .DS_Store files on USBStores
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Disable disk image verification
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

# Always open everything in Finder's list view.
# Use list view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Disable the warning before emptying the Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Empty Trash securely by default
defaults write com.apple.finder EmptyTrashSecurely -bool true

# Show the ~/Library folder
chflags nohidden ~/Library

# Remove Dropbox’s green checkmark icons in Finder
file=/Applications/Dropbox.app/Contents/Resources/emblem-dropbox-uptodate.icns
[ -e "${file}" ] && mv -f "${file}" "${file}.bak"

# Expand the following File Info panes:
# “General”, “Open with”, and “Sharing & Permissions”
defaults write com.apple.finder FXInfoPanesExpanded -dict General -bool true OpenWith -bool true Privileges -bool true

########## Dock, Dashboard, and hot corners

# Hide menu bar
defaults write NSGlobalDomain _HIHideMenuBar -bool true

# Hide Dock
defaults write com.apple.dock autohide -bool true && killall Dock
defaults write com.apple.dock autohide-delay -float 1000 && killall Dock
defaults write com.apple.dock no-bouncing -bool TRUE && killall Dock

# Disable bouncing
defaults write com.apple.dock no-bouncing -bool true

# Show indicator lights for open applications in the Dock
#defaults write com.apple.dock show-process-indicators -bool true

# Don’t animate opening applications from the Dock
defaults write com.apple.dock launchanim -bool false

# Minimize windows into their application’s icon
defaults write com.apple.dock minimize-to-application -bool true

# Speed up Mission Control animations
defaults write com.apple.dock expose-animation-duration -float 0.1

# Don’t group windows by application in Mission Control (i.e. use the old Exposé behavior instead)
defaults write com.apple.dock expose-group-by-app -bool false

# Disable Dashboard
defaults write com.apple.dashboard mcx-disabled -bool true

# Don’t show Dashboard as a Space
defaults write com.apple.dock dashboard-in-overlay -bool true

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Make Dock icons of hidden applications translucent
defaults write com.apple.dock showhidden -bool true

# Set the icon size of Dock items to 18 pixels
defaults write com.apple.dock tilesize -int 18

# Dock: disable magnification
defaults write com.apple.dock magnification -bool false

# Show only open applications in the Dock
defaults write com.apple.dock static-only -bool true

# Set magnification icon size to 18 pixels
defaults write com.apple.dock largesize -float 18

# Don’t automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# Remove hot corners
defaults write com.apple.dock wvous-tl-corner -int 0

# Remove widget in Notification Center
defaults write com.apple.WindowManager StandardHideWidgets -int 0

# Using state management for the dock
defaults write com.apple.WindowManager StageManagerHideWidgets -int 0

########## Miscellaneouss

# Disable Siri
defaults write com.apple.Siri StatusMenuVisible -bool false
defaults write com.apple.assistant.support "Assistant Enabled" -bool false

########## Activity Monitor

# Show the main window when launching Activity Monitor
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

# Visualize CPU usage in the Activity Monitor Dock icon
defaults write com.apple.ActivityMonitor IconType -int 5

# Show all processes in Activity Monitor
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# Sort Activity Monitor results by CPU usage
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

#################################################################

ELAPSED_TIME=$(($SECONDS - $START_TIME))

echo ""
echo ""
echo ""
echo "-----------------------------"
echo "----- dotfiles ended -----"
echo "-----------------------------"
echo "Duration : $(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec"
echo "-------------------------"
echo "Done. All these changes require a logout/restart to take effect."
echo "-------------------------"

