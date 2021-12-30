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

function installHomebrewNormally() {
    if ! isBrewCommandFound; then
        if ! isHomebrewInstalledNormally; then
            message "installing homebrew"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            message "skiping homebrew install"
        fi
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

function installHomebrew() {
    if isCurrentUserAdmin; then
        installHomebrewNormally
    else
        installHomebrewLocally
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
    if isCurrentUserAdmin; then
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
    caskInstallIfNot intellij-idea-ce # https://www.jetbrains.com/idea
    caskInstallIfNot iterm2 # https://www.iterm2.com
    caskInstallIfNot visual-studio-code # https://code.visualstudio.com
}

function deployBrew() {
    installHomebrew
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
    installAsdfPlugin jq
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
        git clone $ZSH_USERS/$1 $OHMYZSH_CUSTOM_PLUGIN
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

function installOhMyZshBrewPlugin() {
    blankLine
    if isCurrentUserAdmin; then
        message "skiping zsh-brew-local plugin"
    else
        installOhMyZshBrewLocalPlugin
    fi
}

function deployOhMyZsh() {
    installOhMyZsh
    installOhMyZshCustomPlugin zsh-syntax-highlighting
    installOhMyZshCustomPlugin zsh-autosuggestions
    installOhMyZshBrewPlugin
}


###############
# Preferences #
###############
function setZshrcPreferences() {
    emulate zsh
    local ZSHRC_PREFERENCES=$(<<- "EOF"
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(zsh-syntax-highlighting zsh-autosuggestions zsh-brew-local brew asdf docker git golang gradle history iterm2 kubectl kubectx macos node npm vscode)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias cls="clear"
EOF
)
    emulate -LR bash
    message "setting .zshrc preferences"
    blankLine
    if isCurrentUserAdmin; then
        echo "$ZSHRC_PREFERENCES" | sed -e 's/zsh-brew-local //' > $ZSHRC
    else
        echo "$ZSHRC_PREFERENCES" > $ZSHRC
    fi
}


########
# MAIN #
########
deployBrew
deployAsdf
deployOhMyZsh
setZshrcPreferences
