#!/bin/zsh -x

# Emulate BASH to make scripting easier
emulate -LR bash

####################
# Helper Functions #
####################
function brewInstallIfNotInstalled() {
    brew list $1 &>/dev/null || brew install $1
}
function caskInstallIfNotInstalled() {
    brew cask list $1 &>/dev/null || brew cask install $1
}


############
# Homebrew #
############
HOMEBREW_ROOT=~/homebrew
export PATH="${HOMEBREW_ROOT}/bin:${HOMEBREW_ROOT}/sbin:$PATH"
if [ ! -d ${HOMEBREW_ROOT} ]; then
    # Extract Homebrew locally i.e. does not require an administrative account
    mkdir -pv $HOMEBREW_ROOT
    curl -L https://github.com/Homebrew/brew/tarball/master --output - | tar xz --strip 1 -C $HOMEBREW_ROOT

    # Create Missing Homebrew Folders
    mkdir -pv ${HOMEBREW_ROOT}/Cellar \
        ${HOMEBREW_ROOT}/Frameworks \
        ${HOMEBREW_ROOT}/etc \
        ${HOMEBREW_ROOT}/include \
        ${HOMEBREW_ROOT}/lib \
        ${HOMEBREW_ROOT}/opt \
        ${HOMEBREW_ROOT}/sbin \
        ${HOMEBREW_ROOT}/share \
        ${HOMEBREW_ROOT}/var/homebrew/linked

    # Initialize empty git repository
    brew update

    # Verify brew install
    brew doctor
fi


#####################
# Homebrew Packages #
#####################
brewInstallIfNotInstalled gnupg # https://gnupg.org


#############
# Oh My Zsh #
#############
ZSHRC=~/.zshrc
ZSHRC_BACKUP=~/.zshrc-dev-env-macos-backup
OHMYZSH_ROOT=~/.oh-my-zsh
if [ ! -d $OHMYZSH_ROOT ]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    mv -v $ZSHRC $ZSHRC_BACKUP
fi


#######################
# Oh My Zsh Locations #
#######################
OHMYZSH_CUSTOM_ROOT=$OHMYZSH_ROOT/custom
OHMYZSH_CUSTOM_PLUGINS=$OHMYZSH_CUSTOM_ROOT/plugins
OHMYZSH_CUSTOM_THEMES=$OHMYZSH_CUSTOM_ROOT/themes


############################
# Oh My Zsh Custom Plugins #
############################
ZSH_SYNTAX_HIGHLIGHTING=$OHMYZSH_CUSTOM_PLUGINS/zsh-syntax-highlighting
if [ ! -d ${ZSH_SYNTAX_HIGHLIGHTING} ];then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_SYNTAX_HIGHLIGHTING}
fi
ZSH_AUTOSUGGESTIONS=$OHMYZSH_CUSTOM_PLUGINS/zsh-autosuggestions
if [ ! -d ${ZSH_AUTOSUGGESTIONS} ];then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_AUTOSUGGESTIONS}
fi


###########################
# Set .zshrc prefereneces #
###########################
sed \
    -e 's/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"agnoster\"/' \
    -e 's/# HIST_STAMPS=/HIST_STAMPS=/' \
    -e 's/HIST_STAMPS=\"mm\/dd\/yyyy\"/HIST_STAMPS=\"yyyy-mm-dd\"/' \
    -e 's/\(git\)/zsh-syntax-highlighting zsh-autosuggestions/' \
    $ZSHRC_BACKUP > $ZSHRC
