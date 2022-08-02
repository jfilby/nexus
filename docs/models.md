# Models

## Defining Models

Models are defined at the application level, but may be referenced across
applications in a project, or in other projects.

Models are defined by YAML and generate:
- SQL create object DDL files
- Nim cached and non-cached data access files
- Nim object types

Create a file called conf/*application*/models/models.yaml.

The module specified in model.yaml is the name of the application.

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


### Additional Notes on Defining Models

Models can have object or ref specified in the modelOptions array. This allow
you to define an object or ref type for the model's Nim object type.

Available field types are:

bool, char, char[], date, date[], datetime, datetime[], float, float[], int,
int[], int64, int64[], json, jsonb, string, string[]

Currently only BTree indexes are available, and are defined as unique or non-
unique.

YAML fields getFunctions, updateFunctions are not currently usable.

