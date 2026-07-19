SHELL=/bin/zsh
.SHELLFLAGS := -eu -o pipefail -c

STOW_PACKAGES := $(patsubst %/,%,$(wildcard */))

# ==============================================================================
# 📦 Target Management
# ==============================================================================
# Targets to exclude from the automatic setup execution (default `make` command)
EXCLUDE_TARGETS := all work brew-work

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