# Setup a New Project

Use the nexus command, which is in Nexus' bin directory and should be in your
PATH. First go to the directory that will contain the project.

A project can contain many applications, but you will be prompted for the name
of the initial application for fast setup.

To generate a project with a web-app:

```
nexus gen web-app
```

To generate a project with a console application:

```
nexus gen console
```

The name of your project and initial application will be prompted for. These
names are critical as they define affect how directories, files and
environment variables are named. Keep them short and use spaces, e.g.: My Test

You can edit the environment scripts created for your project and applications
at any time.


## Compiling your Application

For console applications run compile.bat or compile.sh in your src directory.
The program you compile will expect to be found in the programs subdirectory
and the binary will be placed under the bin subdirectory.

For web applications run web_compile.bat or web_compile.sh in your src
directory. The script expects a single Nim source file in the view/web_app
directory. The compiled binary will be placed under the bin subdirectory.


## Updating Config Files

The conf directory contains configuration YAML files which are utilized by the
nexus CLI to create additional source files for your project. These source
files can provide your with web routes or data access (ORM) functionality.

If you update your conf files, you need to run `nexus gen` again and specify
the appropriate artifact(s).

If an application defines data objects and you run `nexus gen models`, then a
data directory will be generated in the application's path (the same path where
you find the conf directory). There you will find SQL files to create database
object.

It's up to you to create the database objects defined by the SQL files. If the
definition of data objects change, then you should first delete the files in
the data directory, run Nexus Gen again, and make the appropriate changes to
create/modify/drop the updated database objects. Only create SQL statements are
generated at present.

Running `nexus gen web-routes` won't update the view/web_app/web_app.nim file
if it already exists.

