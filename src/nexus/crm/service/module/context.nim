import nexus/core/data_access/db_conn
import crm/types/context_type
import crm/types/model_types


proc newNexusCRMContext*():
       NexusCRMContext =

  var nexusCRMContext = NexusCRMContext()

  nexusCRMContext.db =
    NexusCRMDbContext(dbConn: getDbConn())

  nexusCRMContext.nexusCoreContext =
    NexusCoreContext(
      NexusCoreDbContext(
        dbConn: nexusCRMContext.db.dbConn))

  return nexusCRMContext

