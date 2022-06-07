import os, strformat
import nexus/cmd/service/migrations/bootstrap/bootstrap_models


proc migrate*(basePath: string,
              refresh: bool) =

  let migrationsPath =
        &"{basePath}{DirSep}data{DirSep}db{DirSep}create_objects" &
        &"{DirSep}nexus_core"

  bootstrapMigrationTables(migrationsPath,
                           refresh)

