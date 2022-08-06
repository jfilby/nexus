import chronicles, jester, random
import nexus/core/types/model_types
import nexus/core/types/view_types

proc newWebContext*(
       request: Request,
       nexusCoreDbContext: NexusCoreDbContext): WebContext {.gcsafe.} =

  debug "newWebContext",
    request = $request

  # Init random number generator
  randomize()

  # New WebContext
  var webContext =
        newBaseWebContext(
          request,
          nexusCoreDbContext)

  debug "newWebContext",
    webContext = $webContext

  # Site-specific settings
  webContext.bulmaPathName = "bulma_0.9.3/bulma"
  webContext.websiteTitle = "My Account"
  webContext.cssFilenames.add("nexus_bulma.css")

  # Left menu
  webContext.leftMenuEntries.add(
    LinkMenuEntry(url: "/",
                  text: "Home"))

  # Return
  return webContext

