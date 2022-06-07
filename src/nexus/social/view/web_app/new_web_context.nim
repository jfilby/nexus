import db_postgres, jester, os
import nexus/core/service/common/globals
import nexus/core/types/model_types
import nexus/core/types/view_types
import nexus/core/view/nexus/new_web_context

proc newWebContext*(
       request: Request,
       nexusCoreModule: NexusCoreModule): WebContext {.gcsafe.} =

  # New WebContext
  var webContext = newBaseWebContext(request,
                                      nexusCoreModule)

  # Site-specific settings
  webContext.bulmaPathName = "bulma_0.9.3/bulma"
  webContext.websiteTitle = "My Site"
  webContext.cssFilenames.add("nexus_bulma.css")

  # Left menu
  webContext.leftMenuEntries.add(LinkMenuEntry(url: "/",
                                               text: "Home"))

  # Return
  return webContext

