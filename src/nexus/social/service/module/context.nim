import nexus/core/data_access/db_conn
import social/types/context_type
import social/types/model_types


proc newNexusSocialContext*():
       NexusSocialContext =

  var nexusSocialContext = NexusSocialContext()

  nexusSocialContext.db =
    NexusSocialDbContext(dbConn: getDbConn())

  nexusSocialContext.nexusCoreContext =
    NexusCoreContext(
      NexusCoreDbContext(
        dbConn: nexusSocialContext.db.dbConn))

  return nexusSocialContext

