Nexus: Nim Development Framework
===

Nexus provides a high-level [Nim](https://nim-lang.org) development framework.
You can create web apps, web-services and console applications. The framework
includes a web server, an ORM (which currently supports PostgreSQL only) and
additional modules which aim to provide some basic CRM and Blogging
functionality (these are still in early development).

Nexus utilizes [Jester](https://github.com/dom96/jester) for serving web pages
and web-services. Much of the built-in web content is created using
[Karax](https://github.com/karaxnim/karax) which defines HTML at compile-time
using Nim macros. Your own content can be generated using any available method,
including the use of Karax or
[Nimja](https://github.com/enthus1ast/nimja) to render HTML.

The framework can integrate
with [DocUI](https://github.com/jfilby/DocUI) which is a Flutter front-end
which render UIs that can be defined at the back-end. This works by defining
UIs using the DocUI SDK in a web-service which communicates with your Flutter
app using JSON-encoded information.

Nexus Gen is an ORM that generates data object SQL and data access Nim source
files. There's an option to generate cached data access files in addition to
the regular data access files.


Example Application
====

An example application with documented steps to create it is available, but is
still a work-in-progress:

https://github.com/jfilby/online_store_example


Modules
====

- Nexus Core provides the core web application framework.
- Nexus Gen creates web app and ORM source files.
- Nexus Core Extras provides additional utility functionality.
- Nexus CRM provides mailing list functionality.
- Nexus Social provides social media functionality.

Note that Nexus CRM and Nexus Social are both very minimal at this point.


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


Defining Models
====

Models are defined by YAML and generate:
- SQL create object DDL files
- Nim cached and non-cached data access files
- Nim object types

Create a file called conf/*module*/models/models.yaml.

Here's an example of a models.yaml file:

```
%YAML 1.2
---

- name: User
  description: A list of users.
  module: Users
  modelOptions: [ cacheable,
                  ref ]
  tableOptions: [ generate ]
  fields:
  - name: User Id
    type: int64
    constraints: [ auto-value, not null ]
  - name: Name
    type: string
    constraints: [ not null ]
  - name: Created
    type: datetime
    constraints: [ not null ]
  - name: Updated
    type: datetime
    constraints: []
  defaults: []
  pkFields: [ User Id ]
  uniqueFieldSets:
  - fields: [ Name ]
  relationships: []
  indexes:
  - unique: True
    fields: [ Name ]
  getFunctions: []
  updateFunctions: []


- name: User Role
  description: Roles assigned per user.
  module: Users
  modelOptions: [ object ]
  tableOptions: [ generate ]
  fields:
  - name: User Role Id
    type: int64
    constraints: [ auto-value, not null ]
  - name: User Id
    type: int64
    constraints: [ not null ]
  - name: Role
    type: string
    constraints: [ not null ]
  defaults: []
  pkFields: [ User Id ]
  uniqueFieldSets:
  - fields: [ User Id ]
  relationships:
  - type: many to 1
    from: User Id
    to: User.User Id
  indexes:
  - unique: False
    fields: [ User Id ]
  getFunctions: []
  updateFunctions: []
```

To generate the model artifacts run:

```
nexus gen models
```

This command must be run from your base directory (where the conf directory is
located).


Additional Notes on Defining Models
=====

Models can have object or ref specified in the modelOptions array. This allow
you to define an object or ref type for the model's Nim object type.

Available field types are:

bool, char, char[], date, date[], datetime, datetime[], float, float[], int,
int[], int64, int64[], json, jsonb, string, string[]

Currently only BTree indexes are available, and are defined as unique or non-
unique.

YAML fields getFunctions, updateFunctions are not currently usable.


Defining Web Routes
====

Web routes are defined by YAML and generate:
- The web-app or web-service routing source file
- Starter page files

It's important to generate starter page files because the directories,
filenames and procedures all have generated names that can't be altered.

Routes can be placed in the same file, see the generated routes.yaml file, or
be placed in multiple files by group name. Naming for routes is:
conf/*module*/web-apps/routes/*route-group*.yaml. The web-apps directory can
be named web-services depending on the type of module.

Here's an example of a routes.yaml file:

```
%YAML 1.2
---

- name: Orders
  description: Orders home
  group: Orders
  methods: [ get, post ]
  options: 
  route: /orders
  parameters: []
  defaults: []
  modelFields: []


- name: Order
  description: View an order
  group: Orders
  methods: [ get, post ]
  options: 
  route: /order/{Order Id}
  parameters:
  - name: Order Id
    type: int64
    constraints: [ not null ]
    description:
  defaults: []
  modelFields: []
```

Route parameters are defined in detail. Any named parameter in the route (e.g.
Order Id) must be listed in the parameters spec.


Logging
====

Nexus uses [Chronicles](https://github.com/status-im/nim-chronicles) for
logging. The environment scripts are setup to create log files in the current
directory by default. Look for program.log where program is the name of the
binary you have run.

