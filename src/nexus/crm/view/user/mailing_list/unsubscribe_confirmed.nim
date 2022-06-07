import jester
import karax / [karaxdsl, vdom, vstyles]
import nexus/core/types/model_types as nexus_core_model_types
import nexus/core/types/module_globals
import nexus/core/types/view_types
import nexus/core/view/base_page


proc mailingListUnsubscribeConfirmedPage*(
       request: Request,
       webContext: WebContext): string =

  # Subscription view page
  var pageContext = newPageContext(pageTitle = "Unsubscribed from Mailing List")

  let vnode = buildHtml(tdiv()):
    p(): text "You have been unsubscribed."

  baseForContent(webContext,
                 pageContext,
                 vnode)

