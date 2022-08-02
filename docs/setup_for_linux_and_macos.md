# Nexus Linux/MacOS Setup

Nexus requires some minimal setup to:
- Setup the env script for Nexus
- Install compile scripts to a bin directory
- Compile the nexus CLI


# Nexus env script and bin directory

- Copy env.template.sh to env.sh.
- Set the NEXUS_BASE_PATH and NEXUS_BIN_PATH in the script appropriately
  according to where you have deployed the Nexus codebase.


## Nexus Bin

Add Nexus' bin directory to your PATH environment variable. This should be in
PATH before you proceed to the next step, but should also be in PATH whenever
you log in with your development user.


## Setup Nexus

Install the compile scripts:

```
cd src/nexus/cmd
scripts/dist.sh
```

Now compile the Nexus CLI:

```
compile.sh nexus
```

