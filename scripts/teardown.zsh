#!/bin/zsh -x

# Emulate BASH to make scripting easier
emulate -LR bash

# Remove local Homebrew i.e. does not require an administrative account
HOMEBREW_DIR=~/homebrew
rm -rf $HOMEBREW_DIR
