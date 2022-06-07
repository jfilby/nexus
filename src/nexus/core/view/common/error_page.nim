import karax / [karaxdsl, vdom, vstyles]
import nexus/core/types/view_types
import nexus/core/view/common/common_fields
import nexus/core/view/base_page


# Code
proc exceptionPage*(webContext: WebContext,
                    exceptionMsg: string): string =

  # Log the exception to stderr
  stderr.writeLine(exception_msg)

  # Set pageContext
  var pageContext = newPageContext(pageTitle = "")

  # Get form_div
  let formDiv = getFormFactorClass(webContext,
                                   desktopClass = "form_div")

  # Form
  let vnode = buildHtml(tdiv()):

    tdiv(style = style(StyleAttr.width,
                       webContext.formWidth)):

      tdiv(style = style(StyleAttr.width,
                         webContext.formWidthNarrow)):
        errorMessage("An unexpected error occurred")

  baseForContent(webContext,
                 pageContext,
                 vnode)

