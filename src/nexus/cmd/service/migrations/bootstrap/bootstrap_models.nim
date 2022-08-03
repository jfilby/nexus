import chronicles, db_postgres, os, strformat, strutils


proc bootstrapMigrationTables*(
       nexusCoreDbContext: NexusCoreDbContext,
       migrationsPath: string,
       refresh: bool) =

  debug "bootstrapMigrationTables",
    migrationsPath = migrationsPath

  for kind, path in walkDir(migrationsPath):

    if find(path, ".sql") > 0 and
       find(path, "_create_table_dml") > 0:

      debug "bootstrapMigrationTables()",
        kind = kind,
        path = path

      var str = readFile(path)

      while str[0 .. 1] == "# ":

        let eol = find(str, &"\n")

        str = str[eol + 2 .. len(str) - 1]

      debug "bootstrapMigrationTables",
        str = str

      exec(nexusCoreDbContext.dbConn,
           sql(str))

