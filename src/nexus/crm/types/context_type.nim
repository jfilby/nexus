import nexus/core/types/context_type as nexus_core_context_type
import model_types


type
  NexusCRMContext* = object
    db*: NexusCRMDbContext
    nexusCoreContext*: NexusCoreContext

    # Add your own context vars below this comment

