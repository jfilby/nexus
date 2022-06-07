import chronicles, jester, options
import karax / [karaxdsl, vdom, vstyles]
import nexus/core/data_access/session_data
import nexus/core/types/view_types
import nexus/core/view/account/account_fields
import nexus/core/view/account/login_page
import nexus/core/view/base_page


# Code
proc homePage*(request: Request,
               webContext: WebContext,
               first_homepage: string = "",
               redirect: string = ""): string {.gcsafe.} =

  var pageContext = newPageContext(pageTitle = "Nexus",
                                    pageSubtitle = "Nexus is a web framework",
                                    verticalAlign = true)

  let vnode = buildHtml(tdiv(style = style(StyleAttr.textAlign, "center"))):

    tdiv():
      p(): text "This is a placeholder for a Nexus site."

  baseForContent(webContext,
                 pageContext,
                 vnode)

