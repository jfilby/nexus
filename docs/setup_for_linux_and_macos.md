# Nexus Linux/MacOS Setup

Nexus requires some minimal setup to:
- Setup the env script for Nexus
- Install compile scripts to a bin directory
- Compile the nexus CLI


# Nexus env script and bin directory

Copy env.template.sh to env.sh.

Edit env.sh:
- Set NEXUS_BASE_PATH to where the Nexus code is deployed.
- Set NEXUS_BIN_PATH to where the bin scripts will be installed, e.g. a bin
  directory within NEXUS_BASE_PATH.


## Add bin directory to PATH

Add Nexus' bin directory to your PATH environment variable. This should be in
PATH before you proceed to the next step, but should also be in PATH whenever
you log in with your development user.


## Copy the compile scripts

Install the compile scripts, which will be copied to NEXUS_BIN_PATH:

```
cd src/nexus/cmd
scripts/dist.sh
```

## Compile the CLI

In the same directory run:

```
compile.sh nexus
```

Install to NEXUS_BIN_PATH:

```
scripts\dist
```

