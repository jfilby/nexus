import nexus/core/data_access/db_conn
import nexus/core/types/context_type as nexus_core_context_type
import nexus/core/types/model_types as nexus_core_model_types
import crm/types/context_type
import crm/types/model_types


proc newNexusCRMContext*():
       NexusCRMContext =

  var nexusCRMContext =
        NexusCRMContext(db: NexusCRMDbContext())

  nexusCRMContext.nexusCoreContext =
    NexusCoreContext(db: NexusCoreDbContext())

  nexusCRMContext.db.dbConn = getDbConn()

  return nexusCRMContext

