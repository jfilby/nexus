# Nexus Windows Setup

Copy nexus_env.template.bat to nexus_env.bat. Set the NEXUS_BASE_PATH and
NEXUS_BIN_PATH in the script appropriately according to where you have deployed
the Nexus codebase.


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

