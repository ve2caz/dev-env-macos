# dev-env-macos

> Instructions and scripts allowing for the management of development environments on MacOS

## Before you begin

- Installing, updating or removing software is an administrative task and as such should be performed using an account with elevated privileges i.e. a member of the admin group
- Development is NOT an administrative task and as such should be performed using and account with lowered privileges i.e. a member of the staff group
- Unless otherwise specified all terminal commands are based on the new default zsh shell.
- Apple macOS Catalina 10.15.7

## Install XCode

> *[Xcode is an integrated development environment (IDE) for macOS containing a suite of software development tools developed by Apple for developing software for macOS, iOS, watchOS, and tvOS.](https://en.wikipedia.org/wiki/Xcode)*

- ⌘ Space + *App Store* + ⏎
- Search for XCode in the search box
- Install XCode
- Go for coffee...
- Launch XCode and accept the license agreement
- Quit XCode

## Install XCode command line tools

> XCode doesn't install it's command line unilities by default

- ⌘ Space + *Terminal* + ⏎
- Execute the following commands in Terminal's shell

```zsh
% xcode-select --install
% xcode-select -p
```

- If the developer directory is `/Applications/Xcode.app/Contents/Developer` you can skip the next steps
- Execute the following commands in Terminal's shell (don't forget to change `<admin account>`)

```zsh
% sudo - <admin account>
% sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
% exit
```

## Install this repository locally

> Let's clone the repository to manage the development environments

- ⌘ Space + *Terminal* + ⏎
- In Terminal's shell execute the following commands

```zsh
% export GITHUB_ROOT=~/Documents/dev/github
% mkdir -p ${GITHUB_ROOT}
% cd ${GITHUB_ROOT}
% git clone https://github.com/ve2caz/dev-env-macos.git
% cd dev-env-macos
```

## Setup the development environment

```zsh
% ./scripts/setup.zsh
```

## Uninstall the development environment

```zsh
% ./scripts/teardown.zsh
```
