import nexus/core/data_access/db_conn
import nexus/core/types/context_type as nexus_core_context_type
import nexus/core/types/model_types as nexus_core_model_types
import nexus/social/types/context_type
import nexus/social/types/model_types


proc deleteNexusCoreContext*(
       nexusSocialContext: var NexusSocialContext) =

  closeDbConn(nexusSocialContext.db.dbConn)


proc newNexusSocialContext*():
       NexusSocialContext =

  var nexusSocialContext =
        NexusSocialContext(db: NexusSocialDbContext())

  nexusSocialContext.nexusCoreContext =
    NexusCoreContext(db: NexusCoreDbContext())

  nexusSocialContext.db.dbConn = getDbConn()
  nexusSocialContext.nexusCoreContext.db.dbConn = nexusSocialContext.db.dbConn

  return nexusSocialContext

