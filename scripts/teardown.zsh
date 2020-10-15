#!/bin/zsh -x

# Emulate BASH to make scripting easier
emulate -LR bash

# Oh My Zsh
ZSHRC=~/.zshrc
ZSHRC_BACKUP=~/.zshrc-dev-env-macos-backup
OHMYZSH_ROOT=~/.oh-my-zsh
rm -rf $ZSHRC $ZSHRC_BACKUP $OHMYZSH_ROOT

# Homebrew
HOMEBREW_ROOT=~/homebrew
rm -rf $HOMEBREW_ROOT

# Self
echo "Please remove the dev-env-macos repo"
