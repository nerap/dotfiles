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
echo "----- default dirs -----"

mdkir -p ~/personal ~/work ~/vaults ~/tools


echo ""
echo "----- install homebrew -----"

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew doctor
brew update
brew upgrade


echo ""
echo "----- brew: install -----"

xargs brew install < "$DOTFILES_DIR/packages/brew"
brew cleanup


echo ""
echo "----- brew: cask -----"

brew tap homebrew/cask
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
xargs brew install --cask < "$DOTFILES_DIR/packages/cask"


echo ""
echo "----- brew: fonts -----"

xargs brew install --cask < "$DOTFILES_DIR/packages/fonts"


echo ""
echo "----- default browser -----"
# Remove default browser pop-up in the future
defaultbrowser arc

echo ""
echo "----- setup: zsh -----"
# Oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# Defer plugin
git clone https://github.com/romkatv/zsh-defer.git ~/tools/zsh-defer


echo ""
echo "----- conf nightlight -----"
nightlight temp 100
nightlight schedule 00:00 23:59


echo ""
echo "----- setup: htop -----"

if [[ "$(type -P $binroot/htop)" ]] && [[ "$(stat -L -f "%Su:%Sg" "$binroot/htop")" != "root:wheel" || ! "$(($(stat -L -f "%DMp" "$binroot/htop") & 4))" ]]; then
    echo "- Updating htop permissions"
    sudo chown root:wheel "$binroot/htop"
    sudo chmod u+s "$binroot/htop"
fi


echo ""
echo "----- rust -----"

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh


echo ""
echo "----- nvm -----"

nvm install v18.20.0
nvm alias default v18.20.0


echo ""
echo "----- miniconde3 -----"

mkdir -p ~/personal/miniconda3
curl https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh -o ~/personal/miniconda3/miniconda.sh
bash ~/personal/miniconda3/miniconda.sh -b -u -p ~/personal/miniconda3
rm -rf ~/personal/miniconda3/miniconda.sh
export PATH=$PATH:~/personal/miniconda3/bin


echo ""
echo "----- lua magick -----"

luarocks --local --lua-version=5.1 install magick


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

## Import iTerm2 settings
defaults import com.googlecode.iterm2 "$DOTFILES_DIR/preferences/com.googlecode.iterm2.plist"

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
defaults write com.apple.screencapture location -string "$HOME/Desktop"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

#i######## Findepple.screensaver askForPasswordDelay -int 0r

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

# nvim personal repo must have
git clone https://github.com/ThePrimeagen/harpoon.git -b harpoon2 ~/personal/harpoon
git clone https://github.com/nerap/gitmoji.nvim.git ~/personal/gitmoji

# Personnal space git clone
git clone https://github.com/nerap/nvim.git ~/personal/nvim
git clone https://github.com/nerap/tmux.git ~/personal/tmux
git clone https://github.com/nerap/zsh.git ~/personal/zsh
git clone https://github.com/nerap/yabai.git ~/personal/yabai
git clone https://github.com/nerap/skhd.git ~/personal/skhd

# Giving execution rights to scripts
chmod +x ~/personal/dotfiles/etc/.local/scripts/*

# Create nvim dir if not exists
mkdir -p ~/.config/nvim
mkdir -p ~/.config/yabai
mkdir -p ~/.config/skhd

# Stow
stow --dir="etc" --target=$HOME -S .
stow --dir="$HOME/personal" --target=$HOME -S tmux zsh
stow --dir="$HOME/personal" --target="$HOME/.config" -S yabai skhd
stow --dir="$HOME/personal" --target="$HOME/.config/nvim" -S nvim

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

read -n 1 -r -p "Ready? [y/N]" response
case $response in
    [yY]) echo ""; osascript -e 'tell app "System Events" to restart';;
    *) echo "ok."; exit 0;;
esac
