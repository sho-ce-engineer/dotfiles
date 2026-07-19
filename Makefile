SHELL=/bin/zsh
.SHELLFLAGS := -eu -o pipefail -c

STOW_PACKAGES := $(patsubst %/,%,$(wildcard */))
SETUP_TARGETS := $(shell awk -F':' '/^[a-z0-9_]+:/ && $$1 != "all" {print $$1}' $(MAKEFILE_LIST))
DEFAULTS_TARGETS := $(shell awk -F':' '/^defaults-[a-z0-9_-]+:/ {print $$1}' $(MAKEFILE_LIST))

.ONESHELL:
.PHONY: $(shell cat $(MAKEFILE_LIST) | awk -F':' '/^[a-z0-9_-]+:/ {print $$1}')

# Run all setup tasks.
all: $(SETUP_TARGETS)

# Install Homebrew and packages from the Brewfile.
brew:
	which brew > /dev/null || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	brew analytics off
	brew bundle install --file=./Brewfile --no-upgrade

# Update Homebrew and installed packages.
brew-update: brew
	brew update
	brew upgrade
	brew bundle --file=./Brewfile
	brew cleanup

brew-cleanup:
	brew bundle cleanup --file=./Brewfile --force

# Deploy all dotfile packages with Stow.
dotfiles: brew
	mkdir -p ~/.config
	stow -v -t ~ -S $(STOW_PACKAGES)

$(addprefix stow-,$(STOW_PACKAGES)): stow-%:
	stow -v -t ~ -S $*

$(addprefix unstow-,$(STOW_PACKAGES)): unstow-%:
	stow -v -t ~ -D $*
