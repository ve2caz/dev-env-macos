# dev-env-osx

> Instructions and scripts allowing for the management of development environments on OSX

## Before you begin

- Installing, updating or removing software is an administrative task and as such should be performed using an account with elevated privileges i.e. a member of the admin group
- Development is NOT an administrative task and as such should be performed using and account with lowered privileges i.e. a member of the staff group

## Install XCode

> *[Xcode is an integrated development environment (IDE) for macOS containing a suite of software development tools developed by Apple for developing software for macOS, iOS, watchOS, and tvOS.](https://en.wikipedia.org/wiki/Xcode)*

- ⌘ Space + *App Store* + ⏎
- Search for XCode in the search box
- Install XCode
- Go for coffee...

## Install XCode command line tools

> XCode doesn't install it's command line unilities by default

- ⌘ Space + *Terminal* + ⏎
- Copy and paste the following command into Terminal's shell and hit ⏎

```bash
xcode-select --install \
&& sudo xcodebuild -license accept
```

## Install bootstrap tooling

- ⌘ Space + *Terminal* + ⏎
- In Terminal's shell type ```cd /tmp```
- Copy and paste the following command into Terminal's shell and hit ⏎

```bash
cd /tmp \
&& /usr/bin/curl -O https://raw.githubusercontent.com/ve2caz/dev-env-osx/master/scripts/bootstrap.sh \
&& chmod +x ./bootstrap.sh \
&& ./bootstrap.sh
```

## Install this repository locally

> Let's clone the repository to manage the development environments

- ⌘ Space + *Terminal* + ⏎
- In Terminal's shell execute the following commands

```bash
mkdir -p ~/Documents/dev/github \
&& cd ~/Documents/dev/github \
&& git clone https://github.com/ve2caz/dev-env-osx.git \
&& cd dev-env-osx
```
