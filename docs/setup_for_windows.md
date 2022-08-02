# Nexus Windows Setup

Nexus requires some minimal setup to:
- Setup the env script for Nexus
- Install compile scripts to a bin directory
- Compile the nexus CLI


# Nexus env script and bin directory

- Copy env.template.bat to env.bat.
- Set the NEXUS_BASE_PATH and NEXUS_BIN_PATH in the script appropriately
  according to where you have deployed the Nexus codebase.


## Nexus Bin

Add Nexus' bin directory to your PATH environment variable. In Windows 10:
Start -> Settings -> System. Type "env" and click "Edit the environment
variables for your account". Edit the PATH environment variable and add the
NEXUS_BIN_PATH, which is the directory you just created in this section.


## Setup Nexus

Install the compile scripts:

```
cd src\nexus\cmd
scripts\dist
```

Now compile the Nexus CLI:

```
compile nexus
```

