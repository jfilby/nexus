import os, strformat
import nexus/cmd/service/generate/migrations/postgresql/create_dml
import nexus/cmd/types/types


# Code
proc createMigrationsFile*(
       model: Model,
       migrationsPath: string) =

  # Verification
  if migrationsPath == "":

    raise newException(ValueError,
                       "migrationsPath is blank")

  if model.baseNameInSnakeCase == "":

    raise newException(ValueError,
                       "model.baseNameInSnakeCase is blank")

  # Start creating DML string
  var dmlStr =
    &"REM Nexus generated DML file\n" &
    &"\n"

  createPgTable(
    model,
    dmlStr)

  # Write create table file
  var dmlFilename =
        &"{migrationsPath}{DirSep}{model.baseNameInSnakeCase}_create_table_dml.sql"

  echo ".. writing: " & dmlFilename

  writeFile(filename = dmlFilename,
            dmlStr)

  # FKs
  if len(model.relationships) > 0:

    dmlStr =
      &"REM Nexus generated DML file\n" &
      &"\n"

    createPgForeignKeys(
      model,
      dmlStr)

    # Write migration file
    dmlFilename = &"{migrationsPath}{DirSep}{model.baseNameInSnakeCase}_fk_dml.sql"

    echo ".. writing: " & dmlFilename

    writeFile(filename = dmlFilename,
              dmlStr)

  # Constraints
  if len(model.uniqueFieldSets) > 0:

    dmlStr =
      &"REM Nexus generated DML file\n" &
      &"\n"

    createPgUniqueConstraints(
      model,
      dmlStr)

    # Write migration file
    dmlFilename = &"{migrationsPath}{DirSep}{model.baseNameInSnakeCase}_uq_dml.sql"

    echo ".. writing: " & dmlFilename

    writeFile(filename = dmlFilename,
              dmlStr)

  # Indexes
  if len(model.indexes) > 0:

    dmlStr =
      &"REM Nexus generated DML file\n" &
      &"\n"

    createPgIndexes(
      model,
      dmlStr)

    # Write migration file
    dmlFilename = &"{migrationsPath}{DirSep}{model.baseNameInSnakeCase}_ix_dml.sql"

    echo ".. writing: " & dmlFilename

    writeFile(filename = dmlFilename,
              dmlStr)

