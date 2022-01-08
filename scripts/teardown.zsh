#!/bin/zsh

# Emulate BASH to make scripting easier
emulate -LR bash

######################
# GLOBAL DEFINITIONS #
######################
ASDF_ROOT=~/.asdf
HOMEBREW_INTEL_ROOT=/usr/local/Homebrew
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

function isCurrentUserAdmin() {
    WHOAMI=`whoami`
    if groups $WHOAMI | grep -q -w admin; then
        message "$WHOAMI is administrator"
        return 0
    fi
    message "$WHOAMI is not administrator"
    return 1
}


######################
# Homebrew Functions #
######################
function isBrewCommandFound() {
    if type brew &>/dev/null; then
        message "brew command found"
        return 0
    fi
    message "brew command not found"
    return 1
}

function isHomebrewInstalledNormally() {
    if [ -d ${HOMEBREW_INTEL_ROOT} ]; then
        message "homebrew is installed"
        return 0
    fi
    message "homebrew is not installed"
    return 1
}

function uninstallHomebrewNormally() {
    if isHomebrewInstalledNormally; then
        message "uninstalling homebrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
        sudo /bin/rm -rf /usr/local/Homebrew
    else
        message "skiping homebrew uninstall"
    fi
}

function isHomebrewInstalledLocally() {
    if [ -d ${HOMEBREW_LOCAL_ROOT} ]; then
        message "homebrew is installed locally"
        return 0
    fi
    message "homebrew is not installed locally"
    return 1
}

function uninstallHomebrewLocally() {
    if isHomebrewInstalledLocally; then
        message "uninstalling local homebrew"
        rm -rf $HOMEBREW_LOCAL_ROOT
    else
        message "skiping homebrew local uninstall"
    fi
}

function uninstallHomebrew() {
    if isCurrentUserAdmin; then
        uninstallHomebrewNormally
    else
        uninstallHomebrewLocally
    fi
}

function caskUninstallIfNot() {
    message "uninstall $1 if present"
    blankLine
    brew uninstall --cask $1
}

function uninstallCask() {
    if isBrewCommandFound; then
        message "uninstalling homebrew casks"
        caskUninstallIfNot altair-graphql-client
        caskUninstallIfNot dbeaver-community
        caskUninstallIfNot drawio
        caskUninstallIfNot github
        caskUninstallIfNot graphql-playground
        caskUninstallIfNot inkscape
        caskUninstallIfNot intellij-idea-ce
        caskUninstallIfNot iterm2
        caskUninstallIfNot macsvg
        caskUninstallIfNot visual-studio-code
    fi
}


# Homebrew Cask
uninstallCask


# Homebrew
uninstallHomebrew


# ASDF
rm -rf $ASDF_ROOT


# Oh My Zsh
rm -rf $ZSHRC $ZSHRC_BACKUP $OHMYZSH_ROOT
rm -f ~/.p10k.zsh


# Self
echo "Please remove the dev-env-macos repo"
