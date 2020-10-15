#!/bin/zsh

# Emulate BASH to make scripting easier
emulate -LR bash

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

function isCurrentUserAdmn() {
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

function isHomebrewInstalledLocally() {
    if [ -d ${HOMEBREW_LOCAL_ROOT} ]; then
        message "homebrew is installed locally"
        return 0
    fi
    message "homebrew is not installed locally"
    return 1
}

function installHomebrewLocally() {
    if ! isBrewCommandFound; then
        if ! isHomebrewInstalledLocally; then
            message "installing homebrew locally"
            # Extract Homebrew locally i.e. does not require an administrative account
            mkdir -pv $HOMEBREW_LOCAL_ROOT
            curl -L https://github.com/Homebrew/brew/tarball/master --output - | tar xz --strip 1 -C $HOMEBREW_LOCAL_ROOT

            # Create Missing Homebrew Folders
            message "creating homebrew folders"
            mkdir -pv ${HOMEBREW_LOCAL_ROOT}/Cellar \
                ${HOMEBREW_LOCAL_ROOT}/Frameworks \
                ${HOMEBREW_LOCAL_ROOT}/etc \
                ${HOMEBREW_LOCAL_ROOT}/include \
                ${HOMEBREW_LOCAL_ROOT}/lib \
                ${HOMEBREW_LOCAL_ROOT}/opt \
                ${HOMEBREW_LOCAL_ROOT}/sbin \
                ${HOMEBREW_LOCAL_ROOT}/share \
                ${HOMEBREW_LOCAL_ROOT}/var/homebrew/linked
        else
            message "skiping homebrew install"
        fi
        export PATH="${HOMEBREW_LOCAL_ROOT}/bin:${HOMEBREW_LOCAL_ROOT}/sbin:$PATH"
        message "prepending homebrew to path"
    fi
}

function brewInstallIfNot() {
    message "install $1 if not present"
    brew list $1 &>/dev/null || brew install $1
}

function caskInstallIfNot() {
    message "install $1 if not present"
    if isCurrentUserAdmn; then
        blankLine
        brew list --cask $1 &>/dev/null || brew cask install $1
    else
        blankLine
        brew list --cask $1 &>/dev/null || brew cask install $1 --appdir=~/Applications
    fi
}

function installBrewFormulas() {
    message "installing brew formulas..." && blankLine
    brewInstallIfNot coreutils && blankLine # https://formulae.brew.sh/formula/coreutils
    brewInstallIfNot gnupg && blankLine # https://gnupg.org
}

function installBrewCasks() {
    message "installing brew casks..." && blankLine
    caskInstallIfNot iterm2 && blankLine # https://www.iterm2.com
}

function deployBrew() {
    installHomebrewLocally
    message "brew doctor" && blankLine
    brew doctor
    message "brew update" && blankLine
    brew update
    installBrewFormulas
    installBrewCasks
}


#######################
# oh-my-zsh Functions #
#######################
function installOhMyZsh() {
    if [ ! -d $OHMYZSH_ROOT ]; then
        message "installing oh-my-zsh"
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        mv -v $ZSHRC $ZSHRC_BACKUP
    else
        message "skiping oh-my-zsh install"
    fi
}

function installOhMyZshCustomPlugin() {
    OHMYZSH_CUSTOM_PLUGIN=$OHMYZSH_CUSTOM_PLUGINS/$1
    if [ ! -d ${OHMYZSH_CUSTOM_PLUGIN} ];then
        message "installing $1"
        git clone $ZSH_USERS/zsh-syntax-highlighting ${ZSH_CUSTOM_PLUGIN}
    else
        message "$1 is already installed"
    fi
}

function installOhMyZshBrewLocalPlugin() {
    OHMYZSH_BREW_LOCAL=$OHMYZSH_CUSTOM_PLUGINS/zsh-brew-local
    if [ ! -d ${OHMYZSH_BREW_LOCAL} ];then
        message "installing zsh-brew-local"
        cp -fpR $SCRIPT_PATH/../.oh-my-zsh/custom/plugins/zsh-brew-local $OHMYZSH_BREW_LOCAL
    else
        message "zsh-brew-local is already installed"
    fi
}

function deployOhMyZsh() {
    installOhMyZsh
    installOhMyZshCustomPlugin zsh-syntax-highlighting
    installOhMyZshCustomPlugin zsh-autosuggestions
    installOhMyZshBrewLocalPlugin
}


##################################################################
# ASDF - Manage multiple runtime versions with a single CLI tool #
##################################################################
function installAsdf() {
    if [ ! -d $ASDF_ROOT ]; then
        message "installing asdf"
        git clone https://github.com/asdf-vm/asdf.git $ASDF_ROOT
        pushd $ASDF_ROOT
        git checkout "$(git describe --abbrev=0 --tags)"
        popd
    else
        message "asdf is already installed"
    fi
    message "adding asdf to the path"
    . $ASDF_ROOT/asdf.sh
    asdf update
}


function installAsdfPlugin() {
    message "install $1 if not present"
    # asdf plugin add $1
}


function deployAsdf() {
    installAsdf
    installAsdfPlugin nodejs
}


###############
# Preferences #
###############
function setZshrcPreferences() {
    message "setting .zshrc preferences"
    # sed \
    #     -e 's/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"agnoster\"/' \
    #     -e 's/# HIST_STAMPS=/HIST_STAMPS=/' \
    #     -e 's/HIST_STAMPS=\"mm\/dd\/yyyy\"/HIST_STAMPS=\"yyyy-mm-dd\"/' \
    #     -e 's/\(git\)/zsh-syntax-highlighting zsh-autosuggestions asdf zsh-brew-local brew git history node/' \
    #     $ZSHRC_BACKUP > $ZSHRC
    sed \
        -e 's/# HIST_STAMPS=/HIST_STAMPS=/' \
        -e 's/HIST_STAMPS=\"mm\/dd\/yyyy\"/HIST_STAMPS=\"yyyy-mm-dd\"/' \
        -e 's/\(git\)/zsh-syntax-highlighting zsh-autosuggestions asdf zsh-brew-local brew git history/' \
        $ZSHRC_BACKUP > $ZSHRC
}


########
# MAIN #
########
deployBrew
deployOhMyZsh
deployAsdf
setZshrcPreferences