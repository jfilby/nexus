import locks, options, os, strformat, strutils
import db_connector/db_postgres


# DB open connection lock
var dbConnLock: Lock

initLock(dbConnLock)


proc closeDbConn*(dbConn: var DbConn) =

  # close() is pqfinish, which frees the connection but leaves the caller's
  # pointer dangling. Clearing it makes a double close a no-op instead of a
  # double free: the extras/CRM/social contexts share one connection with their
  # nested core context, so both cleanup hooks can run for a single request.
  if dbConn != nil:

    close(dbConn)
    dbConn = nil


proc getDbConn*(printInfo: bool = true): DbConn =

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

  # Acquire lock, as opening DB connections isn't thread-safe
  # https://github.com/nim-lang/Nim/issues/20231
  #
  # The open has to happen inside a try/finally: open() raises when the
  # connection fails, and without the finally the lock was never released, so a
  # single failed connect (DB restart, bad password, exhausted connections)
  # wedged every later request in acquire() with no way to recover.
  acquire(dbConnLock)

  try:

    # If no port is specified then just pass basic DB parameters
    var dbConn: DbConn

    if dbPort == "":

      if printInfo == true:
        echo "getDbConn(): connecting to main db:",
             &"dbHost: {dbHost}, dbName: {dbName}"

      dbConn = open(dbHost,
                    username,
                    password,
                    dbName)

    # If a port is specified then a connection string must be specified
    else:

      # Only encode slashes here, and only for a socket path. libpq does not
      # percent-decode the plain `host` parameter, so encoding it in the branch
      # below made a socket path unconnectable.
      let encodedHost =
        if dbHost.startsWith("/"):
          dbHost.replace("/",
                         "%2F")
        else:
          dbHost

      let dbShowString =
        &"postgresql://{username}:***@{encodedHost}:{dbPort}/{dbName}"

      let dbString =
        &"postgresql://{username}:{password}@{encodedHost}:{dbPort}/{dbName}"

      if printInfo == true:
        echo "getDbConn(): connecting to main db:",
             &"dbShowString: {dbShowString}"

      dbConn = open("",
                    "",
                    "",
                    dbString)

    # Return
    return dbConn

  finally:

    # Release DB connection lock
    release(dbConnLock)

