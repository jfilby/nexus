Installing Nexus
===

Pre-requisites
====

Nexus requires Nim v1.6.4 or later.

Run the following Nimble commands to install the required Nim modules:

```
nimble install argon2
nimble install chronicles
nimble install jester
nimble install karax
nimble install quickjwt
nimble install yaml
```


Linux/MacOS Install
====

Copy nexus_env.template.sh to nexus_env.sh. Set the NEXUS_BASE_PATH and
NEXUS_BIN_PATH in the script appropriately according to where you have deployed
the Nexus codebase.

Go to each module's path and run:

```
nimble install
nimble develop
```


**Nexus Bin**

Add Nexus' bin directory to your PATH environment variable. This should be in
PATH before you proceed to the next step, but should also be in PATH whenever
you log in with your development user.


**Setup Nexus**

Go to src/nexus and run:

```
scripts/dist.sh
```


Windows Install
====

Copy nexus_env.template.bat to nexus_env.bat. Set the NEXUS_BASE_PATH and
NEXUS_BIN_PATH in the script appropriately according to where you have deployed
the Nexus codebase.

Go to each module's path and run:

```
nimble install
nimble develop
```


**Nexus Bin**

Add Nexus' bin directory to your PATH environment variable. In Windows 10:
Start -> Settings -> System. Type "env" and click "Edit the environment
variables for your account". Edit the PATH environment variable and add the
NEXUS_BIN_PATH, which is the directory you just created in this section.


**Setup Nexus**

Go to src\nexus and run:

```
scripts\dist
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

