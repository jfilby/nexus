import nexus/core/types/context_type as nexus_core_context_type
import model_types


type
  NexusCoreExtrasContext* = object
    db*: NexusCoreExtrasDbContext
    nexusCoreContext*: NexusCoreContext

    # Add your own context vars below this comment

