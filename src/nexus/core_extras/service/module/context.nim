import nexus/core/data_access/db_conn
import core_extras/types/context_type
import core_extras/types/model_types


proc newNexusCoreExtrasContext*():
       NexusCoreExtrasContext =

  var nexusCoreExtrasContext = NexusCoreExtrasContext()

  nexusCoreExtrasContext.db =
    NexusCoreExtrasDbContext(dbConn: getDbConn())

  nexusCoreExtrasContext.nexusCoreContext =
    NexusCoreContext(
      NexusCoreDbContext(
        dbConn: nexusCoreExtrasContext.db.dbConn))

  return nexusCoreExtrasContext

