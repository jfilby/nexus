import crm/types/context_type
import crm/types/model_types
import new_web_context


proc newNexusCRMContext*():
       NexusCRMContext =

  var nexusCRMContext = NexusCRMContext()

  nexusCRMContext.db = NexusCRMDbContext()

  nexusCRMContext.nexusCoreDbContext =
    NexusCoreDbContext(dbConn: nexusCRMContext.db.dbConn)
                  nexusCRM.nexusCoreDbContext)

  return nexusCRMContext

