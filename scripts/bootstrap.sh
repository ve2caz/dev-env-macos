#!/bin/bash

echo "Installing Homebrew: ~/homebrew"
ch ~ && mkdir homebrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew

# echo "Installing Homebrew Cask: https://caskroom.github.io"
# brew tap caskroom/cask-cask

# echo "Brew install cask/completion"
# brew install brew-cask-completion

# echo "Brew install git: https://git-scm.com/downloads"
# brew install git
