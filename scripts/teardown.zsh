#!/bin/zsh

# Emulate BASH to make scripting easier
emulate -LR bash


####################
# Helper Functions #
####################
function blankLine() {
    echo
}

function message() {
    STAMP=`date +%Y-%m-%dT%H:%M:%S`
    blankLine
    echo "$STAMP --- $SCRIPT >>> $1"
}


######################
# Homebrew Functions #
######################
function caskUninstallIfNot() {
    message "uninstall $1 if present"
    blankLine
    brew uninstall --cask $1
}


######################
# GLOBAL DEFINITIONS #
######################
ASDF_ROOT=~/.asdf
HOMEBREW_LOCAL_ROOT=~/homebrew
OHMYZSH_ROOT=~/.oh-my-zsh
OHMYZSH_CUSTOM_ROOT=$OHMYZSH_ROOT/custom
OHMYZSH_CUSTOM_PLUGINS=$OHMYZSH_CUSTOM_ROOT/plugins
OHMYZSH_CUSTOM_THEMES=$OHMYZSH_CUSTOM_ROOT/themes
SCRIPT_PATH=${0:a:h}
SCRIPT=${0:t}
ZSH_USERS=https://github.com/zsh-users
ZSHRC=~/.zshrc
ZSHRC_BACKUP=~/.zshrc-dev-env-macos-backup


# Homebrew Cask
# caskUninstallIfNot altair-graphql-client
# caskUninstallIfNot github
# caskUninstallIfNot graphql-playground
# caskUninstallIfNot intellij-idea-ce
# caskUninstallIfNot iterm2
# caskUninstallIfNot visual-studio-code


# ASDF
rm -rf $ASDF_ROOT


# Homebrew
rm -rf $HOMEBREW_LOCAL_ROOT


# Oh My Zsh
rm -rf $ZSHRC $ZSHRC_BACKUP $OHMYZSH_ROOT


# Self
echo "Please remove the dev-env-macos repo"
