Views
===

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

- name: Users
  description: Users home
  group: Users
  methods: [ get, post ]
  options: 
  route: /users
  parameters: []
  defaults: []
  modelFields: []


- name: User
  description: View a user
  group: Users
  methods: [ get, post ]
  options: 
  route: /user/{User Id}
  parameters:
  - name: User Id
    type: int64
    constraints: [ not null ]
    description:
  defaults: []
  modelFields: []
```

Route parameters are defined in detail. Any named parameter in the route (e.g.
User Id) must be listed in the parameters spec.

To generate the web routes and pages source run:

```
nexus gen web-routes
```

This command must be run from your base directory (where the conf directory is
located).

