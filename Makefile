SHELL=/bin/zsh
.SHELLFLAGS := -eu -o pipefail -c

STOW_PACKAGES := $(patsubst %/,%,$(wildcard */))

# ==============================================================================
# 📦 Target Management
# ==============================================================================
# Targets to exclude from the automatic setup execution (default `make` command)
EXCLUDE_TARGETS := all work brew-work setup-signing defaults

# Convert the space-separated list into a regex pattern (e.g., all|work|brew-work)
EXCLUDE_REGEX := $(shell echo "$(EXCLUDE_TARGETS)" | sed 's/ /|/g')

# Automatically collect targets while ignoring those specified in the exclude list
SETUP_TARGETS := $(shell awk -F':' -v exclude="^($(EXCLUDE_REGEX))$$" '/^[a-z0-9_]+:/ && $$1 !~ exclude {print $$1}' $(MAKEFILE_LIST))
DEFAULTS_TARGETS := $(shell awk -F':' '/^defaults-[a-z0-9_-]+:/ {print $$1}' $(MAKEFILE_LIST))
# ==============================================================================

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

# GitHub Verified Settings.
setup-signing:
	@STATUS=$$(gh auth status -h github.com 2>&1 || true); \
	if echo "$$STATUS" | grep -q "write:ssh_signing_key" && echo "$$STATUS" | grep -q "write:public_key"; then \
		: ; \
	elif echo "$$STATUS" | grep -q "Logged in to"; then \
		gh auth refresh -h github.com -s write:ssh_signing_key,write:public_key; \
	else \
		gh auth login -h github.com -s write:ssh_signing_key,write:public_key; \
	fi
	@if [ ! -f ~/.ssh/github_sign ]; then \
		echo "🔑 Generating new SSH signing key..."; \
		mkdir -p ~/.ssh && chmod 700 ~/.ssh; \
		ssh-keygen -t ed25519 -C "293084588+sho-ce-engineer@users.noreply.github.com" -f ~/.ssh/github_sign -N ""; \
		echo "🚀 Adding key to GitHub..."; \
		gh ssh-key add ~/.ssh/github_sign.pub --type signing -t "Mac-Signing-Key"; \
		echo "✅ 署名鍵の生成とGitHubへの登録が完了しました！"; \
	else \
		echo "✅ Signing key already exists in local."; \
		echo "🚀 Ensuring key is added to GitHub..."; \
		set +e; \
		ADD_OUTPUT=$$(gh ssh-key add ~/.ssh/github_sign.pub --type signing -t "Mac-Signing-Key" 2>&1); \
		ADD_STATUS=$$?; \
		set -e; \
		if [ $$ADD_STATUS -ne 0 ]; then \
			if echo "$$ADD_OUTPUT" | grep -qi "already in use"; then \
				echo "✅ Already registered on GitHub. Skipping."; \
			else \
				echo "$$ADD_OUTPUT" >&2; \
				exit 1; \
			fi; \
		else \
			echo "$$ADD_OUTPUT"; \
		fi; \
	fi
	@echo "⚙️ Gitの署名設定を行います..."
	@git config --global gpg.format ssh
	@git config --global user.signingkey "~/.ssh/github_sign.pub"
	@git config --global commit.gpgsign true
	@mkdir -p ~/.config/git
	@echo "$$(git config user.email) $$(cat ~/.ssh/github_sign.pub)" > ~/.config/git/allowed_signers
	@git config --global gpg.ssh.allowedSignersFile "~/.config/git/allowed_signers"
	@echo "🎉 すべての設定が完了しました！"

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