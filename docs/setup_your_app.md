Setup a New Application
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


Compiling your Application
====

For console applications run compile.bat or compile.sh in your src directory.
The program you compile will expect to be found in the programs subdirectory
and the binary will be placed under the bin subdirectory.

For web applications run web_compile.bat or web_compile.sh in your src
directory. The script expects a single Nim source file in the view/web_app
directory. The compiled binary will be placed under the bin subdirectory.


Updating a Module by Configuration
====

Most modules contain a conf directory which contains configuration YAML files
which are utilized by Nexus Gen to create additional source files for your
project. These source files can provide your with web routes or data access
(ORM) functionality.

If you update your conf files, you need to run "nexus gen" again and specify
the appropriate artifact(s).

If a module defines data objects and you run "nexus gen models", then a data
directory will be generated in the module's path (the same path where you find
the conf directory). There you will find SQL files to create database object.

It's up to you to create the database objects defined by the SQL files. If the
definition of data objects change, then you should first delete the files in
the data directory, run Nexus Gen again, and make the appropriate changes to
create/modify/drop the updated database objects. Only create SQL statements are
generated at present.

Running "nexus gen web-routes" won't update the view/web_app/web_app.nim file
if it already exists.

