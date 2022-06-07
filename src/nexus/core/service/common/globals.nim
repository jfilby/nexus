import nexus/core/service/common/get_env
import nexus/core/data_access/db_conn


let
  # DB open connection must be at the global level in Jester web apps
  db* = getDbConn()

  # OS env vars
  serverIsProduction* = getServerIsProduction()

