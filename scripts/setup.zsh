#!/bin/zsh -x

# Emulate BASH to make scripting easier
emulate -LR bash

# Install Homebrew locally i.e. does not require an administrative account
HOMEBREW_DIR=~/homebrew
mkdir -pv $HOMEBREW_DIR
curl -L https://github.com/Homebrew/brew/tarball/master --output - | tar xz --strip 1 -C $HOMEBREW_DIR
export PATH="${HOMEBREW_DIR}/bin:$PATH"

# Create Local Homebrew Folders
mkdir -pv ${HOMEBREW_DIR}/Cellar \
    ${HOMEBREW_DIR}/Frameworks \
    ${HOMEBREW_DIR}/etc \
    ${HOMEBREW_DIR}/include \
    ${HOMEBREW_DIR}/lib \
    ${HOMEBREW_DIR}/opt \
    ${HOMEBREW_DIR}/sbin \
    ${HOMEBREW_DIR}/share \
    ${HOMEBREW_DIR}/var/homebrew/linked

# Verify brew install
brew doctor

# Initialize empty git repository
brew update

# Install GnuPG (https://gnupg.org) to validate downloaded software using proper certs
brew install gnupg
