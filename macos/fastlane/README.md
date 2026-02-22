fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Mac

### mac beta

```sh
[bundle exec] fastlane mac beta
```

Push a new beta build to TestFlight

### mac release

```sh
[bundle exec] fastlane mac release
```

Push a new release build to App Store Connect

### mac init_match

```sh
[bundle exec] fastlane mac init_match
```

Initialize Match: generate certificates and profiles (run locally once)

### mac nuke_match

```sh
[bundle exec] fastlane mac nuke_match
```

Nuke existing Match certificates (run locally to start over)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
