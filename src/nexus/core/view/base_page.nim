import chronicles, jester, options, os, strformat, strutils
import karax / [karaxdsl, vdom, vstyles]
import nexus/core/data_access/account_user_token_data
import nexus/core/types/model_types
import nexus/core/types/view_types


# Templates required for server-side JS event handlers
# Used for onLoad()
template kxi(): int = 0
template addEventHandler(n: VNode; k: EventKind; action: string; kxi: int) =
  n.setAttr($k, action)


# Code
proc leftMenu*(webContext: WebContext): VNode =

  # Render left menu
  debug "newWebContext()",
    lenleftMenuEntries = len(webContext.leftMenuEntries)

  buildHtml(tdiv(class = "menu")):

    if webContext.loggedIn == true:

        # Mobile layout left menu
        if webContext.mobileDefault == true:

          for leftMenuEntry in webContext.leftMenuEntries:

            a(href = leftMenuEntry.url): text leftMenuEntry.text
            verbatim(" &nbsp; ")

        # Desktop layout left menu
        else:
          tdiv(style = style(StyleAttr.marginRight, "1em")):
            tdiv(class = "menu-list",
                 style = style(StyleAttr.textAlign, "right")):

              ul():

                for leftMenuEntry in webContext.leftMenuEntries:

                  li():
                    if webContext.leftMenuEntry == leftMenuEntry.text:
                      a(href = leftMenuEntry.url,
                        class = "is-size-7 has-text-weight-semibold has-text-black"): text leftMenuEntry.text

                    else:
                      a(href = leftMenuEntry.url,
                        class = "is-size-7"): text leftMenuEntry.text


proc redirectToLogin*(): string {.gcsafe.} =

  "<head>" &
  "<meta http-equiv=\"Refresh\" content=\"0; URL=/account/login\">" &
  "</head>"


proc redirectToURL*(url: string,
                    cookie: string = ""): string {.gcsafe.} =

  cookie &
  "<head>" &
  "<meta http-equiv=\"Refresh\" content=\"0; URL=" & url & "\">" &
  "</head>"


proc topBarMenu*(
       webContext: WebContext,
       pageContext: PageContext,
       nexusCoreModule: Option[NexusCoreModule] = none(NexusCoreModule)):
         VNode {.gcsafe.} =

  debug "topBarMenu()",
    webContextLoggedIn = $webContext.loggedIn

  # Get launchAppUrl
  var launchAppUrl =
        replace(
          getEnv("LAUNCH_APP_URL"),
          "\"",
          "")

  # LoginHash for auto-login of the app
  if webContext.request.cookies.hasKey("token") and
     nexusCoreModule != none(NexusCoreModule):

    let accountUserToken =
          getAccountUserTokenByToken(
            nexusCoreModule.get,
            webContext.request.cookies["token"])

    if accountUserToken != none(AccountUserToken):
      launchAppUrl &= "?launchHash=" & accountUserToken.get.uniqueHash

  # Menu HTML
  buildHtml(tdiv(class = "top_bar",
                 style = style(StyleAttr.width, "100%"))):

    a(# class = "mr-4",
      href = "/",
      class = "top_bar"): verbatim &"<b>Home</b>"

#[
    if webContext.loggedIn == true:

      verbatim(" &nbsp; | &nbsp; ")
      a(href = "/invite/send",
        class = "top_bar"): text "Send an invite"
      a(href = &"{launchAppUrl}?token={token}",
]#

    if webContext.topMenuBarLaunchApp == true:

      verbatim(" &nbsp; | &nbsp; ")
      a(href = launchAppUrl,
        class = "top_bar"): text "Launch App"

    if webContext.loggedIn == true:

      verbatim(" &nbsp; ")
      a(href = "/account/my-account",
        class = "top_bar"): text "My Account"

    else:
      verbatim(" &nbsp; ")

      a(href = "/account/sign-up",
        class = "top_bar"): text "Sign up"

      verbatim(" &nbsp; ")
      a(href = "/account/login",
        class = "top_bar"): text "Login"

    if webContext.topMenuBarSubscription == true:

      verbatim(" &nbsp; ")
      a(href = "/account/subscription",
        class = "top_bar"): text "Subscription"

    if webContext.loggedIn == true:

      verbatim(" &nbsp; ")
      a(href = "/account/logout",
        class = "top_bar"): text "Logout"

    if webContext.topMenuBarAbout == true:

      verbatim(" &nbsp; ")
      a(href = "/about",
        class = "top_bar"): text "About"

    if webContext.topMenuBarBlog == true:

      verbatim(" &nbsp; ")
      a(href = "/blog",
        class = "top_bar"): text "Blog"


proc baseForDesktopContent*(
       webContext: WebContext,
       pageContext: PageContext,
       content: VNode,
       scripts: string = "",
       nexusCoreModule: Option[NexusCoreModule]): string {.gcsafe.} =

  var
    onloadScript = ""
    pageContentsClass = "column is-three-fifth"
    sideMarginsClass = "column is-one-fifth"
    contentsMargin = ""

  if pageContext.auto_login == true:
    onloadScript = "document.getElementById('login').click()"

  if pageContext.wide_side_margins == false:
    pageContentsClass = ""
    sideMarginsClass = ""
    contentsMargin = "auto"

  let vnode = buildHtml(html()):
    head:
      title: text webContext.websiteTitle & ": " & pageContext.pageTitle

      if webContext.metaDescription != none(string):
        verbatim("<meta description=\"" & webContext.metaDescription.get & "\">")

      verbatim("<meta name=\"viewport\" content=\"width=device-width, " &
               "initial-scale=1, maximum-scale=1, user-scalable=0\">")

      # If the mobile setting is not known then determine it was JS
      if webContext.mobile == none(bool):

        script(src = "/js/utility.js")

        script(): verbatim "var append_char = '?';" &
                           "if (window.location.href.indexOf(\"?\") > -1) { append_char = '&' }" &
                           "if (window.location.href.indexOf(\"m=\") == -1) {" &
                           "  let m = isMobile(); window.location.href += append_char + 'm=' + m;" &
                           "}"

      for headEntry in webContext.headEntries:
        verbatim(headEntry)

      link(rel = "icon",
           type = "image/x-icon",
           href = "/favicon/favicon.ico")

      link(rel = "stylesheet",
           href = "/" & webContext.bulmaPathName & "/css/bulma.min.css")

      for cssFilename in webContext.cssFilenames:
        link(rel = "stylesheet",
             `defer` = "",
             href = "/css/" & cssFilename)

      for cssFilename in pageContext.cssFilenames:
        link(rel = "stylesheet",
             `defer` = "",
             href = "/css/" & cssFilename)

      if scripts != "":
        verbatim(scripts)

    body(onload = onloadScript):

      # Workaround for FOUC browser issue from: https://stackoverflow.com/a/57888310
      verbatim("<script>0</script>")

      if pageContext.backgroundImage != none(string):
        tdiv(style = style((StyleAttr.backgroundColor, "#ffffff"),
                           (StyleAttr.position, "absolute"),
                           (StyleAttr.top, "0px"),
                           (StyleAttr.left, "0px"),
                           (StyleAttr.width, "100%"),
                           (StyleAttr.height, "100%"),
                           (StyleAttr.zIndex, "-1"))):
          img(src = pageContext.backgroundImage.get,
              loading = "lazy")

      topBarMenu(webContext,
                 pageContext,
                 nexusCoreModule)

      if pageContext.backgroundImage != none(string):
        pageContentsClass &= " form_div"

      tdiv(class = "section"):
        tdiv(class = "container"):
          tdiv(class = "columns"):
            tdiv(class = sideMarginsClass):
              leftMenu(webContext)
            tdiv(style = style((StyleAttr.backgroundColor, "#fafafa"),
                               (StyleAttr.margin, contentsMargin)),
                 class = pageContentsClass):

              if pageContext.displayPageHeading == true:

                tdiv(class = "title_div"):

                  if pageContext.pageTitle != "":
                      h1(class = "title"): text pageContext.pageTitle

                  if pageContext.pageSubtitle != "":
                    h2(class = "subtitle",
                       style = style(StyleAttr.marginTop, "0.5em")): text pageContext.pageSubtitle

              content

            tdiv(class = sideMarginsClass)

  return $vnode


proc baseForMobileContent*(webContext: WebContext,
                           pageContext: PageContext,
                           content: VNode,
                           scripts: string = ""): string {.gcsafe.} =

  var onloadScript = ""

  if pageContext.auto_login == true:
    onloadScript = "document.getElementById('login').click()"

  let vnode = buildHtml(html()):
    head:
      title: text webContext.websiteTitle & ": " & pageContext.pageTitle

      if webContext.metaDescription != none(string):
        verbatim("<meta description=\"" & webContext.metaDescription.get & "\">")

      verbatim("<meta name=\"viewport\" content=\"width=device-width, " &
               "initial-scale=1, maximum-scale=1, user-scalable=0\">")

      link(rel = "icon",
           type = "image/x-icon",
           href = "/favicon/favicon.ico")

      link(rel = "stylesheet",
           href = "/" & webContext.bulmaPathName & "/css/bulma.min.css")

      for cssFilename in webContext.cssFilenames:
        link(rel = "stylesheet",
             `defer` = "",
             href = "/css/" & cssFilename)

      for cssFilename in pageContext.cssFilenames:
        link(rel = "stylesheet",
             `defer` = "",
             href = "/css/" & cssFilename)

      if scripts != "":
        verbatim(scripts)

    body(onload = onloadScript):

      # Workaround for FOUC browser issue from: https://stackoverflow.com/a/57888310
      verbatim("<script>0</script>")

      topBarMenu(webContext,
                 pageContext)
      tdiv(style = style(StyleAttr.margin, "0.1em")):
        tdiv():
          tdiv(style = style(StyleAttr.width, "100%")):
            span():
              leftMenu(webContext)
          tdiv():
            br()

            if pageContext.displayPageHeading == true:

              if pageContext.pageTitle != "":
                tdiv(class = "title_div"):
                  h1(class = "title mb-4"): text pageContext.pageTitle

              if pageContext.pageSubtitle != "":
                h2(class = "subtitle",
                   style = style(StyleAttr.marginTop, "0.25em")): text pageContext.pageSubtitle

            content

  return $vnode


proc baseForContent*(
       webContext: WebContext,
       pageContext: PageContext,
       content: VNode,
       scripts: string = "",
       mobile: string = "f",
       nexusCoreModule: Option[NexusCoreModule] = none(NexusCoreModule)):
         string {.gcsafe.} =

  debug "baseForContent()"

  debug "baseForContent(): pageContext",
    pageTitle = pageContext.pageTitle

  debug "baseForContent(): webContext:",
    websiteTitle = webContext.websiteTitle

  if webContext.mobileDefault == true:
    baseForMobileContent(webContext,
                         pageContext,
                         content,
                         scripts)
  else:
    baseForDesktopContent(webContext,
                          pageContext,
                          content,
                          scripts,
                          nexusCoreModule)


proc templatePage*(
       webContext: WebContext,
       pageContext: PageContext,
       htmlStart: string,
       content: string,
       htmlEnd: string,
       nexusCoreModule: Option[NexusCoreModule] = none(NexusCoreModule)):
         string =

  let nexusLandingUserAccess = getEnv("NEXUS_CONTENT_LAUNCHED")
  var str = htmlStart

  if nexusLandingUserAccess == "Y":

    str &= $topBarMenu(webContext,
                       pageContext,
                       nexusCoreModule)

  str &= content &
         htmlEnd

  return str

