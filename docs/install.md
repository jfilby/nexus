# Installing Nexus

## Pre-requisites

Nexus requires Nim v1.6.0 or later. See the
[install instructions](https://nim-lang.org/install.html) and preferably
use the choosenim install tool to install Nim.


## Install the Nimble Package

Nim comes with the Nimble package manager.

Install the Nexus package with:

```
nimble install nexus
```

If you prefer to install Nexus via source, you can still use the above Nimble
command to install dependencies and then uninstall the nexus package. If you
wish to install those depedencies manually, then please refer to the
nexus.nimble file for a list of required packages.

Next you need to setup Nexus.


## Setup

- [Linux or MacOS](setup_for_linux_and_macos.md)
- [Windows](setup_for_windows.md)

