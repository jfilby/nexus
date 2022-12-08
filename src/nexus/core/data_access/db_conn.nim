import chronicles, db_postgres, locks, options, os, strformat, strutils


# DB open connection lock
var dbConnLock: Lock

initLock(dbConnLock)


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

  # Acquire lock, as opening DB connections isn't thread-safe
  # https://github.com/nim-lang/Nim/issues/20231
  acquire(dbConnLock)

  # If no port is specified then just pass basic DB parameters
  var dbConn: DbConn

  if dbPort == "":
    dbString = dbHost

    info "getDbConn(): connecting to main db:",
      dbName = dbName

    dbConn = open(dbHost,
                  username,
                  password,
                  dbName)

  # If a port is specified then a connection string must be specified
  else:
    let dbShowString = &"postgresql://{username}:***@{dbHost}:{dbPort}/{dbName}"

    dbString = &"postgresql://{username}:{password}@{dbHost}:{dbPort}/{dbName}"

    info "getDbConn(): connecting to main db:",
      dbShowString = dbShowString

    dbConn = open("",
                  "",
                  "",
                  dbString)

  # Release DB connection lock
  release(dbConnLock)

  # Return
  return dbConn

