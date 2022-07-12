Installing Nexus
===

Pre-requisites
====

Nexus requires Nim v1.6.0 or later.


Install the Nimble Package
====

Install Nexus Nimble package with:

```
nimble install nexus
```

If you prefer to install Nexus via source, you can still use the above Nimble
command to install dependencies and then uninstall the nexus package. If you
wish to install those depedencies manually, then please refer to the
nexus.nimble file for a list of required packages.

Next you need to setup Nexus.


Linux/MacOS Setup
====

Copy nexus_env.template.sh to nexus_env.sh. Set the NEXUS_BASE_PATH and
NEXUS_BIN_PATH in the script appropriately according to where you have deployed
the Nexus codebase.


**Nexus Bin**

Add Nexus' bin directory to your PATH environment variable. This should be in
PATH before you proceed to the next step, but should also be in PATH whenever
you log in with your development user.


**Setup Nexus**

Install the compile scripts:

```
cd src/nexus/cmd
scripts/dist.sh
```

Now compile the Nexus CLI:

```
compile.sh nexus
```


Windows Setup
====

Copy nexus_env.template.bat to nexus_env.bat. Set the NEXUS_BASE_PATH and
NEXUS_BIN_PATH in the script appropriately according to where you have deployed
the Nexus codebase.


**Nexus Bin**

Add Nexus' bin directory to your PATH environment variable. In Windows 10:
Start -> Settings -> System. Type "env" and click "Edit the environment
variables for your account". Edit the PATH environment variable and add the
NEXUS_BIN_PATH, which is the directory you just created in this section.


**Setup Nexus**

Install the compile scripts:

```
cd src\nexus\cmd
scripts\dist
```

Now compile the Nexus CLI:

```
compile nexus
```


Setting up your application
====

Use the nexus command, which is in Nexus' bin directory and should be in your
PATH. First go to the directory that will contain the application.

To generate a web-app:

```
nexus gen web-app
```

To generate a console application:

```
nexus gen console
```

The name of your application will be prompted for. This name is critical as it
defines naming for directories, files and environment variables. Keep it short
and use spaces, e.g.: My Test

You can edit the environment scripts created for your application at any time.

