import options
import nexus/core/types/view_types
import model_types


type
  NexusCoreContext* = object
    db*: NexusCoreDbContext
    web*: Option[WebContext]

    # Add your own context vars below this comment

