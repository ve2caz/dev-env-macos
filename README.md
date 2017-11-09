# dev-env-osx

> Instructions and scripts allowing for the management of development environments on OSX

## Install XCode

> *[Xcode is an integrated development environment (IDE) for macOS containing a suite of software development tools developed by Apple for developing software for macOS, iOS, watchOS, and tvOS.](https://en.wikipedia.org/wiki/Xcode)*

- ⌘ Space + *App Store* + ⏎
- Search for XCode in the search box
- Install XCode
- Go for coffee...

## Install XCode Command Line Tools

> XCode doesn't install it's command line unilities by default...

```bash
xcode-select --install
```

## Install bootstrap tooling

- ⌘ Space + *Terminal* + ⏎
- In Terminal's shell type ```cd /tmp```
- Copy and paste the following command into Terminal's shell and hit ⏎

```bash
/usr/bin/curl -O https://raw.githubusercontent.com/ve2caz/dev-env-osx/master/scripts/bootstrap.sh && chmod +x ./bootstrap.sh && ./bootstrap.sh
```
