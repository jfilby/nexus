import chronicles, db_postgres, jester, json, options, os, strutils
import karax / [karaxdsl, vdom, vstyles]
import docui/service/sdk/docui_types
import nexus/core/data_access/db_conn
import nexus/core/service/account/jwt_utils
import nexus/core/service/account/utils
import nexus/core/types/model_types


# Types
type
  LinkMenuEntry* = ref object of RootObj
    url*: string
    text*: string

  LinkMenuEntries* = seq[LinkMenuEntry]


  WebContext* = ref object of RootObj
    request*: Request
    contentType*: ContentType
    json*: JsonNode
    postRedirect*: string

    bulmaPathName*: string
    headEntries*: seq[string]
    cssFilenames*: seq[string]
    websiteTitle*: string
    metaDescription*: Option[string]

    token*: string
    accountUserId*: int64
    accountUserIdStr*: string
    loggedIn*: bool

    mobile*: Option[bool]
    mobileDefault*: bool
    serverIsProduction*: bool

    leftMenuEntry*: string
    leftMenuEntries*: LinkMenuEntries
    leftMenu*: VNode

    topMenuBarLaunchApp*: bool
    topMenuBarAbout*: bool
    topMenuBarBlog*: bool
    topMenuBarSubscription*: bool

    formWidth*: string
    formWidthNarrow*: string
    formWideWidth*: string


  PageContext* = ref object of RootObj
    autoLogin*: bool
    backgroundImage*: Option[string]
    cssFilenames*: seq[string]
    pageTitle*: string
    pageSubtitle*: string

    wideSideMargins*: bool
    displayPageHeading*: bool
    horizontalCenter*: bool
    verticalAlign*: bool


# Type initialization
proc newPageContext*(
       auto_login: bool = false,
       backgroundImage: string = "",
       pageTitle: string,
       pageSubtitle: string = "",
       displayPageHeading: bool = true,
       horizontalCenter: bool = false,
       verticalAlign: bool = false): PageContext =

  var pageContext = PageContext()

  pageContext.autoLogin = autoLogin

  if backgroundImage != "":
    pageContext.backgroundImage = some(backgroundImage)

  pageContext.pageTitle = pageTitle
  pageContext.pageSubtitle = pageSubtitle

  pageContext.wideSideMargins = true
  pageContext.displayPageHeading = displayPageHeading
  pageContext.horizontalCenter = horizontalCenter
  pageContext.verticalAlign = verticalAlign

  return pageContext


proc newBaseWebContext*(
       request: Request,
       nexusCoreDbContext: NexusCoreDbContext): WebContext =

  debug "newBaseWebContext()",
    requestParams = $request.params,
    body = request.body

  # Create WebContext object
  var
    webContext = WebContext()
    inToken = ""

  webContext.request = request
  webContext.contentType = getContentType(request)

  # If JSON then skip empty strings, or those less than 1 in length
  if webContext.contentType == ContentType.JSON and
     len(request.body) > 1:

    webContext.json = parseJson(request.body)

    if webContext.json.hasKey(DocUI_Token):
      inToken = webContext.json[DocUI_Token].getStr()

  # Set serverIsProduction
  webContext.serverIsProduction = false

  if getEnv("SERVER_IS_PRODUCTION") == "Y":
    webContext.serverIsProduction = true

  webContext.loggedIn = false
  webContext.mobile = none(bool)

  # Set mobile setting (request param)
  if request.params.hasKey("m"):

    if request.params["m"] == "t":
      webContext.mobile = some(true)

    elif request.params["m"] == "f":
      webContext.mobile = some(false)

  debug "newBaseWebContext()",
    inToken = inToken

  #  Default settings
  webContext.bulmaPathName = "bulma"

  # Connect with JWT
  var
    foundToken: bool
    errorMessage: string
    secret: string
    accountUserId: string
    mobileFromToken: string

  (foundToken,
   errorMessage,
   secret,
   accountUserId,
   mobileFromToken) = connectWithJWT(
                        request,
                        nexusCoreDbContext,
                        inToken,
                        useCookie = true,
                        verifyUserIsActive = true)

  debug "newBaseWebContext()",
    foundToken = foundToken,
    errorMessage = errorMessage,
    secret = secret,
    accountUserId = accountUserId,
    mobileFromToken = mobileFromToken

  # Check if logged in
  if foundToken == true:

    # Check logged in from token
    if accountUserId != "":
      webContext.loggedIn = true

    # Check mobile from token
    if mobileFromToken != "":
      if mobileFromToken == "true":
        webContext.mobile = some(true)
      else:
        webContext.mobile = some(false)

  # Set mobile default (if a true/false value must be decided on)
  if webContext.mobile != none(bool):
    webContext.mobileDefault = webContext.mobile.get

  else:
    webContext.mobileDefault = false

  # If no token found then create one, or of the mobile value is now known
  debug "newBaseWebContext()",
    mobile = webContext.mobile

  var createToken = false

  if foundToken == true:
#    if @[ "", "false" ].contains(mobileFromToken) and
    if mobileFromToken == "" and
       webContext.mobile != none(bool):

      debug "newBaseWebContext(): createToken case 1"

      createToken = true

  elif webContext.mobile != none(bool):

    debug "newBaseWebContext(): createToken case 2"

    createToken = true

  debug "newBaseWebContext()",
    createToken = createToken

  if createToken == true and
     accountUserId != "":

    # Don't set mobile if it's not known
    var mobileInToken = ""

    if webContext.mobile != none(bool):
      mobileInToken = $webContext.mobile.get

    # Create a JWT connection (token)
    webContext.token =
      createJWT(nexusCoreDbContext,
                accountUserId,
                secret,
                mobile = mobileInToken)

  else:
    webContext.token = ""

  # Set accountUserId
  debug "newBaseWebContext(): set final accountUserId",
    accountUserId = $accountUserId,
    loggedIn = $webContext.loggedIn

  if accountUserId != "":
    webContext.accountUserId = parseBiggestInt(accountUserId)
  else:
    webContext.accountUserId = -1

  webContext.accountUserIdStr = accountUserId

  # Set form widths based on layout
  if webContext.mobileDefault == true:
    webContext.formWidth = "100%"
    webContext.formWideWidth = "100%"

  else:
    webContext.formWidth = "30em"
    webContext.formWideWidth = "60em"

  webContext.formWidthNarrow = webContext.formWidth

  if webContext.mobileDefault == false:
    webContext.formWidth = webContext.formWideWidth

  # Return
  return webContext

