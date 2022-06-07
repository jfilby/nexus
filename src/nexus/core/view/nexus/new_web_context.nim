import db_postgres, jester
import nexus/core/types/model_types
import nexus/core/types/view_types


proc newWebContext*(
       request: Request,
       nexusCoreModule: NexusCoreModule): WebContext {.gcsafe.} =

  # New WebContext
  var webContext = newBaseWebContext(
                     request,
                     nexusCoreModule)

  # Site-specific settings
  webContext.bulmaPathName = "bulma-0.9.3"
  webContext.websiteTitle = "Nexus"
  webContext.leftMenuEntry = "Home"

  # Return
  return webContext

