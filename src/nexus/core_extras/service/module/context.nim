import nexus/core/data_access/db_conn
import nexus/core/types/context_type as nexus_core_context_type
import nexus/core/types/model_types as nexus_core_model_types
import nexus/core_extras/types/context_type
import nexus/core_extras/types/model_types


proc deleteTraderEngineContext*(
       nexusCoreExtrasContext: var NexusCoreExtrasContext) =

  closeDbConn(nexusCoreExtrasContext.db.dbConn)


proc newNexusCoreExtrasContext*():
       NexusCoreExtrasContext =

  var nexusCoreExtrasContext =
        NexusCoreExtrasContext(db: NexusCoreExtrasDbContext())

  nexusCoreExtrasContext.nexusCoreContext =
    NexusCoreContext(db: NexusCoreDbContext())

  nexusCoreExtrasContext.db.dbConn = getDbConn()
  nexusCoreExtrasContext.nexusCoreContext.db.dbConn = nexusCoreExtrasContext.db.dbConn

  return nexusCoreExtrasContext

