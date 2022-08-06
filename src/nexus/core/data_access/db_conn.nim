import chronicles, db_postgres, os, strformat, strutils


proc closeDbConn*(dbConn: var DbConn) =

  close(dbConn)


proc getDbConn*(): DbConn =

  # If a DEFAULT_DB_PREFIX env is specified then use it
  var defaultDbPrefix = getEnv("DEFAULT_DB_PREFIX")

  if defaultDbPrefix != "":
    defaultDbPrefix &= "_"

  # Get env variables
  var
    dbHost = getEnv(defaultDbPrefix & "DB_HOST")
    dbPort = getEnv(defaultDbPrefix & "DB_PORT")
    dbName = getEnv(defaultDbPrefix & "DB_NAME")
    username = getEnv(defaultDbPrefix & "USERNAME")
    password = getEnv(defaultDbPrefix & "PASSWORD")
    dbString = ""

  # Encode forward slashes in host (for socket paths)
  dbHost = replace(dbHost,
                   "/",
                   "%2F")

  # If no port is specified then just pass basic DB parameters
  if dbPort == "":
    dbString = dbHost

    info "getDbConn(): connecting to main db:",
      dbName = dbName

    return open(dbHost,
                username,
                password,
                dbName)

  # If a port is specified then a connection string must be specified
  else:
    let dbShowString = &"postgresql://{username}:***@{dbHost}:{dbPort}/{dbName}"

    dbString = &"postgresql://{username}:{password}@{dbHost}:{dbPort}/{dbName}"

    info "getDbConn(): connecting to main db:",
      dbShowString = dbShowString

    return open("",
                "",
                "",
                dbString)

