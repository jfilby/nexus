import crm/types/context_type
import crm/types/model_types


proc newNexusCRMContext*():
       NexusCRMContext =

  var nexusCRMContext = NexusCRMContext()

  nexusCRMContext.db =
    NexusCRMDbContext()

  nexusCRMContext.nexusCoreDbContext =
    NexusCoreDbContext(dbConn: nexusCRMContext.db.dbConn)

  return nexusCRMContext

