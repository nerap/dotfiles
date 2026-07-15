#!/usr/bin/env bash
# macOS setup — the original install.sh logic, unchanged in behavior, split into:
#   os_prep   — Xcode CLT, Homebrew + packages, 1Password SSH agent (so cloning works)
#   os_finish — Mac-only configs (aerospace, alacritty), node/lua, GUI apps, `defaults`
# Shared bootstrap (config repos, stow, oh-my-zsh, rust) lives in common.sh.
# Assumes lib.sh is sourced. MACHINE_NAME + DOTFILES_DIR come from install.sh.

os_prep() {
  log "Xcode Command Line Tools"
  if ! xcode-select --print-path &>/dev/null; then
    xcode-select --install &>/dev/null
    until xcode-select --print-path &>/dev/null; do sleep 5; done
    sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer 2>/dev/null || true
    sudo xcodebuild -license 2>/dev/null || true
  fi

  log "Homebrew"
  if ! have brew; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  brew doctor || true
  brew update && brew upgrade || true

  log "brew: packages / casks / fonts"
  xargs brew install < "$DOTFILES_DIR/packages/brew"; brew cleanup
  export HOMEBREW_CASK_OPTS="--appdir=/Applications"
  xargs brew install --cask < "$DOTFILES_DIR/packages/cask"
  xargs brew install < "$DOTFILES_DIR/packages/fonts"

  log "1Password + SSH agent"
  open -W /Applications/1Password.app
  open /Applications/1Password.app
  sleep 3
  ssh -T git@github.com || {
    echo "SSH to GitHub failed — approve the key in 1Password, then:"
    read -p "Press Enter to continue..."
  }
  have op || brew install 1password-cli
  mkdir -p ~/.ssh; touch ~/.ssh/config
  if ! grep -q "1Password SSH agent" ~/.ssh/config; then
    cat <<'EOF' >> ~/.ssh/config

# 1Password SSH agent configuration
Host *
    IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
EOF
  fi
}

os_finish() {
  log "Mac-only config repos (aerospace + alacritty)"
  clone_or_pull git@github.com:nerap/aerospace.git ~/config/aerospace
  clone_or_pull git@github.com:nerap/alacritty.git ~/config/alacritty
  mkdir -p ~/.config/aerospace ~/.config/alacritty
  stow --dir="$HOME/config" --target="$HOME/.config/aerospace" -R aerospace
  stow --dir="$HOME/config" --target="$HOME/.config/alacritty" -R alacritty

  log "Node (nvm) + Lua magick"
  if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
  fi
  export NVM_DIR="$HOME/.nvm"; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  nvm ls | grep -q "v22" || { nvm install v22; nvm alias default v22; }
  have luarocks || brew install luarocks
  luarocks --lua-version=5.1 list | grep -q magick || luarocks --local --lua-version=5.1 install magick

  log "GUI apps + defaults"
  open -W /Applications/DBeaver.app || true
  have defaultbrowser || brew install defaultbrowser
  defaultbrowser browser || true
  have nightlight || brew install smudge/smudge/nightlight
  nightlight temp 100; nightlight schedule 00:00 23:59

  macos_defaults
  log "macOS setup complete — logout/restart to apply everything"
}

# The full `defaults write` system-tuning block, verbatim from the original script.
macos_defaults() {
  sudo -v
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

  sudo scutil --set ComputerName "${MACHINE_NAME}"
  sudo scutil --set HostName "${MACHINE_NAME}"
  sudo scutil --set LocalHostName "${MACHINE_NAME}"
  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "${MACHINE_NAME}"

  defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
  defaults write NSGlobalDomain AppleAccentColor -string "-1"
  sudo nvram SystemAudioVolume=" "
  defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
  defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
  defaults write com.apple.LaunchServices LSQuarantine -bool false
  defaults write com.apple.CrashReporter DialogType -string "none"
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
  defaults write NSGlobalDomain AppleLanguages -array "en"
  defaults write NSGlobalDomain AppleLocale -string "fr_FR@currency=EUR"
  defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
  defaults write NSGlobalDomain AppleMetricUnits -bool true
  sudo systemsetup -settimezone "Europe/Paris" >/dev/null

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

  defaults write com.apple.loginwindow RetriesUntilHint -int 0
  defaults write com.apple.terminal StringEncodings -array 4
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

  defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"
  defaults write com.apple.screencapture type -string "png"
  defaults write com.apple.screencapture disable-shadow -bool true
  defaults write com.apple.screensaver askForPassword -int 1
  defaults write com.apple.screensaver askForPasswordDelay -int 0

  defaults write com.apple.finder ShowStatusBar -bool true
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
  defaults write com.apple.frameworks.diskimages skip-verify -bool true
  defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
  defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true
  defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
  defaults write com.apple.finder WarnOnEmptyTrash -bool false
  defaults write com.apple.finder EmptyTrashSecurely -bool true
  chflags nohidden ~/Library
  file=/Applications/Dropbox.app/Contents/Resources/emblem-dropbox-uptodate.icns
  [ -e "${file}" ] && mv -f "${file}" "${file}.bak"
  defaults write com.apple.finder FXInfoPanesExpanded -dict General -bool true OpenWith -bool true Privileges -bool true

  defaults write NSGlobalDomain _HIHideMenuBar -bool true
  defaults write com.apple.dock autohide -bool true && killall Dock
  defaults write com.apple.dock autohide-delay -float 1000 && killall Dock
  defaults write com.apple.dock no-bouncing -bool TRUE && killall Dock
  defaults write com.apple.dock no-bouncing -bool true
  defaults write com.apple.dock launchanim -bool false
  defaults write com.apple.dock minimize-to-application -bool true
  defaults write com.apple.dock expose-animation-duration -float 0.1
  defaults write com.apple.dock expose-group-by-app -bool false
  defaults write com.apple.dashboard mcx-disabled -bool true
  defaults write com.apple.dock dashboard-in-overlay -bool true
  defaults write com.apple.dock autohide -bool true
  defaults write com.apple.dock showhidden -bool true
  defaults write com.apple.dock tilesize -int 18
  defaults write com.apple.dock magnification -bool false
  defaults write com.apple.dock static-only -bool true
  defaults write com.apple.dock largesize -float 18
  defaults write com.apple.dock mru-spaces -bool false
  defaults write com.apple.dock wvous-tl-corner -int 0
  defaults write com.apple.WindowManager StandardHideWidgets -int 0
  defaults write com.apple.WindowManager StageManagerHideWidgets -int 0

  defaults write com.apple.Siri StatusMenuVisible -bool false
  defaults write com.apple.assistant.support "Assistant Enabled" -bool false
  defaults write com.apple.ActivityMonitor OpenMainWindow -bool true
  defaults write com.apple.ActivityMonitor IconType -int 5
  defaults write com.apple.ActivityMonitor ShowCategory -int 0
  defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
  defaults write com.apple.ActivityMonitor SortDirection -int 0
}
