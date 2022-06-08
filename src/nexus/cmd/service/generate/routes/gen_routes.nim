import chronicles, strformat, strutils
import nexus/core/service/format/type_utils
import nexus/cmd/types/types


# Forward declarations
proc optionsRoute(
       route: Route,
       str: var string)
proc responseCall(
       str: var string,
       `method`: string,
       procName: string,
       route: Route,
       webArtifact: WebArtifact)


# Code
proc appendLoginPostPageRouteTemplate(str: var string) =

  str &= "  # Login\n" &
         "  get \"/account/login\":\n" &
         "    let webContext = newWebContext(request,\n" &
         "                                   nexusCoreModule)\n" &
         "\n" &
         "    # Set cookie (useful to store detected mobile setting)\n" &
         "    if webContext.token != \"\":\n" &
         "      setCookie(\"token\",\n" &
         "                webContext.token,\n" &
         "                daysForward(5),\n" &
         "                path = \"/\")\n" &
         "\n" &
         "    # Render page\n" &
         "    resp loginPage(webContext)\n" &
         "\n" &
         "\n" &
         "  post \"/account/login\":\n" &
         "    let webContext = newWebContext(request,\n" &
         "                                   nexusCoreModule)\n" &
         "\n" &
         "    postLoginAction(request,\n" &
         "                    webContext)\n" &
         "\n" &
         "\n"


proc generateRoute(
       str: var string,
       route: Route,
       webArtifact: WebArtifact) =

  debug "generateRoute(): route:",
    methods = route.methods,
    url = route.url

  # const optionRoutes = @[ "/account/login",
  #                         "/account/sign-up" ]

  # Generate option methods
  if route.options != "":

    optionsRoute(
      route,
      str)

  # Generate given methods
  for `method` in route.methods:

    var procName = route.nameCamelCaseName

    if `method` == "post":
      procName &= "Post"

    procName &= "View"

    # Form URL
    debug "generateRoute()",
      lenRouteParamInfos = len(route.paramInfos)

    # Start route string
    var webContextAssign = "let"

    if `method` == "post":
      webContextAssign = "var"

    str &= &"  {`method`} \"{route.route}\":\n" &
            "\n" &
           &"    {webContextAssign} webContext = newWebContext(request,\n" &
            "                                   nexusCoreModule)\n" &
            "\n"

    responseCall(
      str,
      `method`,
      procName,
      route,
      webArtifact)


proc optionsRoute(
       route: Route,
       str: var string) =

  if route.options == "Allow All":

    str &= &"  options \"{route.name}\":\n" &
            "    resp(Http200, {\"Allow\": \"GET, OPTIONS, POST\",\n" &
            "                   \"Access-Control-Allow-Origin\": \"*\",\n" &
            "                   \"Access-Control-Allow-Methods\": \"GET,HEAD,OPTIONS,POST,PUT\",\n" &
            "                   \"Access-Control-Allow-Headers\": \"Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale\"},\n" &
            "         \"success\")\n" &
            "\n" &
            "\n"

  else:
    raise newException(
            ValueError,
            &"Unhandled options: {route.options}")


proc responseCall(
       str: var string,
       `method`: string,
       procName: string,
       route: Route,
       webArtifact: WebArtifact) =

  var procCallLine: string

  # Non-resp calls (e.g. some templates)
  if procName == "logoutAction":
    procCallLine = &"    {procName}(request,\n"

  # Resp calls (the default)
  elif webArtifact.artifact == WebServiceArtifact:

    str &= &"    resp Http200,\n" &
           &"         {{\"Access-Control-Allow-Origin\": \"*\"}},\n"

    procCallLine = &"         {procName}(request,\n"


  elif webArtifact.artifact == WebAppArtifact:
    procCallLine = &"    resp {procName}(request,\n"

  let
    indentStart = find(procCallLine,
                        "(") + 1
    indent = getIndentByLen(indentStart)

  str &= procCallLine &
         &"{indent}webContext"

  str &= ")\n" &
         "\n" &
         "\n"


proc generateRouteMethods*(
       str: var string,
       route: Route,
       webArtifact: WebArtifact) =

  # Handle login routes with the built-in template
  if route.route == "/account/login" and
     webArtifact.artifact == WebAppArtifact:

    appendLoginPostPageRouteTemplate(str)

  else:
    # Get route
    generateRoute(str,
                  route,
                  webArtifact)

