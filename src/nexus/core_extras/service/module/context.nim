import nexus/core/data_access/db_conn
import nexus/core/types/context_type as nexus_core_context_type
import nexus/core/types/model_types as nexus_core_model_types
import core_extras/types/context_type
import core_extras/types/model_types


proc newNexusCoreExtrasContext*():
       NexusCoreExtrasContext =

  var nexusCoreExtrasContext = NexusCoreExtrasContext()

  nexusCoreExtrasContext.db =
    NexusCoreExtrasDbContext(dbConn: getDbConn())

  nexusCoreExtrasContext.nexusCoreContext =
    NexusCoreContext(
      db: NexusCoreDbContext(
        dbConn: nexusCoreExtrasContext.db.dbConn))

  return nexusCoreExtrasContext

