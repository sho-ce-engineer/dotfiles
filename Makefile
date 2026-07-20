SHELL=/bin/zsh
.SHELLFLAGS := -eu -o pipefail -c

STOW_PACKAGES := $(patsubst %/,%,$(wildcard */))

# ==============================================================================
# 📦 Target Management
# ==============================================================================
# Targets to exclude from the automatic setup execution (default `make` command)
EXCLUDE_TARGETS := all work brew-work defaults

# Convert the space-separated list into a regex pattern (e.g., all|work|brew-work)
EXCLUDE_REGEX := $(shell echo "$(EXCLUDE_TARGETS)" | sed 's/ /|/g')

# Automatically collect targets while ignoring those specified in the exclude list
SETUP_TARGETS := $(shell awk -F':' -v exclude="^($(EXCLUDE_REGEX))$$" '/^[a-z0-9_]+:/ && $$1 !~ exclude {print $$1}' $(MAKEFILE_LIST))
DEFAULTS_TARGETS := $(shell awk -F':' '/^defaults-[a-z0-9_-]+:/ {print $$1}' $(MAKEFILE_LIST))
# ==============================================================================

.ONESHELL:
.PHONY: $(shell cat $(MAKEFILE_LIST) | awk -F':' '/^[a-z0-9_-]+:/ {print $$1}')

# [Minimal Configuration] Executed when running `make` or `make all`
all: $(SETUP_TARGETS)

# [Work Configuration] Executed when running `make work`
work: brew-work dotfiles

# Install Homebrew and applications from the core Brewfile
brew:
	which brew > /dev/null || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	brew analytics off
	brew bundle install --file=./Brewfile --no-upgrade

# Install additional work applications from Brewfile.work
brew-work:
	which brew > /dev/null || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	brew analytics off
	brew bundle install --file=./Brewfile.work --no-upgrade

# Update Homebrew and all installed packages
brew-update: brew
	brew update
	brew upgrade
	brew bundle --file=./Brewfile
	brew cleanup

# Clean up unmanaged Homebrew packages
brew-cleanup:
	brew bundle cleanup --file=./Brewfile --force

# Deploy all dotfile packages with GNU Stow
dotfiles:
	mkdir -p ~/.config
	stow -v -t ~ -S $(STOW_PACKAGES)

$(addprefix stow-,$(STOW_PACKAGES)): stow-%:
	stow -v -t ~ -S $*

$(addprefix unstow-,$(STOW_PACKAGES)): unstow-%:
	stow -v -t ~ -D $*

mise: brew
	if command -v mise > /dev/null; then \
		echo "Installing tools via mise..."; \
		mise install -y; \
	else \
		echo "⚙️ mise is not installed. Please ensure 'mise' is in your Brewfile."; \
	fi

defaults:
	@echo "Configuring macOS Dock and Hot Corners..."
	defaults write NSGlobalDomain AppleMenuBarVisibleInFullscreen -int 1
	defaults write NSGlobalDomain AppleShowAllExtensions -bool true
	defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
	defaults write NSGlobalDomain InitialKeyRepeat -int 15
	defaults write NSGlobalDomain KeyRepeat -int 2
	defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
	defaults write NSGlobalDomain NSToolbarTitleViewRolloverDelay -float 0
	defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true
	defaults write NSGlobalDomain com.apple.mouse.scaling -float 3
	defaults write NSGlobalDomain com.apple.trackpad.scaling -int 3

	defaults write com.apple.ActivityMonitor IconType -int 5
	defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 0
	defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
	defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
	
	# Dock
	defaults write com.apple.dock orientation -string "left"
	defaults write com.apple.dock tilesize -int 41
	defaults write com.apple.dock autohide -bool false
	defaults write com.apple.dock magnification -bool true
	defaults write com.apple.dock show-recents -bool false
	defaults write com.apple.dock mineffect -string "suck"
	defaults write com.apple.dock mru-spaces -bool false
	defaults write com.apple.dock show-process-indicators -bool true
	defaults write com.apple.dock wvous-tl-corner -int 2 # Mission Control
	defaults write com.apple.dock wvous-tl-modifier -int 0
	defaults write com.apple.dock wvous-tr-corner -int 2 # Mission Control
	defaults write com.apple.dock wvous-tr-modifier -int 0
	defaults write com.apple.dock wvous-bl-corner -int 11 # Launchpad
	defaults write com.apple.dock wvous-bl-modifier -int 0
	defaults write com.apple.dock wvous-br-corner -int 4 #Desktop
	defaults write com.apple.dock wvous-br-modifier -int 0

	killall Dock
	@echo "macOS defaults applied successfully!"