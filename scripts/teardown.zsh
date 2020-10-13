#!/bin/zsh -x

# Emulate BASH to make scripting easier
emulate -LR bash

# Oh My Zsh
OHMYZSH_ROOT=~/.oh-my-zsh
rm -rf $OHMYZSH_ROOT

# Homebrew
HOMEBREW_ROOT=~/homebrew
rm -rf $HOMEBREW_ROOT
