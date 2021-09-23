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
    blankLine
    brew list $1 &>/dev/null || brew install $1
}

function caskInstallIfNot() {
    message "install $1 if not present"
    blankLine
    if isCurrentUserAdmn; then
        brew list --cask $1 &>/dev/null || brew install --cask $1
    else
        brew list --cask $1 &>/dev/null || brew install --cask $1 --appdir=~/Applications
    fi
}

function installBrewFormulas() {
    message "installing brew formulas..."
    brewInstallIfNot coreutils # https://formulae.brew.sh/formula/coreutils
    brewInstallIfNot gnupg # https://gnupg.org
}

function installBrewCasks() {
    message "installing brew casks..."
    caskInstallIfNot altair-graphql-client # https://altair.sirmuel.design
    caskInstallIfNot github # https://docs.github.com/en/desktop
    caskInstallIfNot graphql-playground # https://github.com/graphql/graphql-playground
    caskInstallIfNot iterm2 # https://www.iterm2.com
    caskInstallIfNot visual-studio-code # https://code.visualstudio.com
}

function deployBrew() {
    installHomebrewLocally
    message "brew doctor" && blankLine
    brew doctor
    message "brew update" && blankLine
    brew update
    message "brew upgrade" && blankLine
    brew upgrade
    message "brew upgrade --cask" && blankLine
    brew upgrade --cask
    message "brew cleanup" && blankLine
    brew cleanup
    installBrewFormulas
    installBrewCasks
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
    blankLine
    . $ASDF_ROOT/asdf.sh
    asdf update
}


function installAsdfPlugin() {
    message "install $1 asdf plugin if not present"
    blankLine
    asdf plugin list $1 | grep $1 &>/dev/null || asdf plugin add $1
}

function installNodeJsAsdfPluginCerts() {
    message "installing asdf nodejs plugin GPG certs"
    blankLine
    $HOME/.asdf/plugins/nodejs/bin/import-release-team-keyring
}


function deployAsdf() {
    installAsdf
    installAsdfPlugin golang
    installAsdfPlugin java
    installAsdfPlugin kotlin
    installAsdfPlugin nodejs
    installAsdfPlugin python
    installNodeJsAsdfPluginCerts
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
        message "skiping $1 installed"
    fi
}

function installOhMyZshBrewLocalPlugin() {
    OHMYZSH_BREW_LOCAL=$OHMYZSH_CUSTOM_PLUGINS/zsh-brew-local
    if [ ! -d ${OHMYZSH_BREW_LOCAL} ];then
        message "installing zsh-brew-local"
        cp -fpR $SCRIPT_PATH/../.oh-my-zsh/custom/plugins/zsh-brew-local $OHMYZSH_BREW_LOCAL
    else
        message "skiping zsh-brew-local installed"
    fi
}

function deployOhMyZsh() {
    installOhMyZsh
    installOhMyZshCustomPlugin zsh-syntax-highlighting
    installOhMyZshCustomPlugin zsh-autosuggestions
    installOhMyZshBrewLocalPlugin
}


###############
# Preferences #
###############
function setZshrcPreferences() {
    message "setting .zshrc preferences"
    # sed \
    #     -e 's/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"agnoster\"/' \
    sed \
        -e 's/# HIST_STAMPS=/HIST_STAMPS=/' \
        -e 's/HIST_STAMPS=\"mm\/dd\/yyyy\"/HIST_STAMPS=\"yyyy-mm-dd\"/' \
        -e 's/\(git\)/zsh-syntax-highlighting zsh-autosuggestions zsh-brew-local brew asdf docker git golang gradle history iterm2 kubectl kubectx node npm vscode/' \
        $ZSHRC_BACKUP > $ZSHRC
}


########
# MAIN #
########
deployBrew
deployAsdf
deployOhMyZsh
setZshrcPreferences
