#!/bin/bash

echo "Installing Homebrew: https://brew.sh"
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

echo "Installing Homebrew Cask: https://caskroom.github.io"
brew tap caskroom/cask

echo "Brew install bash-completion"
brew install bash-completion

echo "Brew install cask/completion"
brew install brew-cask-completion

echo "Brew install git: https://git-scm.com/downloads"
brew install git
