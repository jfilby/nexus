import nexus/core/types/model_types as nexus_core_model_types
import model_types


type
  NexusCoreExtrasContext* = object
    db*: NexusCoreExtrasDbContext
    nexusCoreDbContext*: NexusCoreDbContext

    # Add your own context vars below this comment

