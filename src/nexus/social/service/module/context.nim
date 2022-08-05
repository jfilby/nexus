import nexus/core/data_access/db_conn
import nexus/core/types/context_type as nexus_core_context_type
import nexus/core/types/model_types as nexus_core_model_types
import social/types/context_type
import social/types/model_types


proc newNexusSocialContext*():
       NexusSocialContext =

  var nexusSocialContext = NexusSocialContext()

  nexusSocialContext.db =
    NexusSocialDbContext(dbConn: getDbConn())

  nexusSocialContext.nexusCoreContext =
    NexusCoreContext(
      db: NexusCoreDbContext(
        dbConn: nexusSocialContext.db.dbConn))

  return nexusSocialContext

