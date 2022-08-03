import chronicles, strformat
import nexus/cmd/service/generate/modules/module_utils
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
       module: Module,
       webArtifact: WebArtifact)


# Code
proc appendLoginPostPageRouteTemplate(str: var string) =

  str &= "  # Login\n" &
         "  get \"/account/login\":\n" &
         "    let nexusContext = newNextContext(request)\n" &
         "\n" &
         "    # Set cookie (useful to store detected mobile setting)\n" &
         "    if nexusContext.web.token != \"\":\n" &
         "      setCookie(\"token\",\n" &
         "                nexusContext.web.token,\n" &
         "                daysForward(5),\n" &
         "                path = \"/\")\n" &
         "\n" &
         "    # Render page\n" &
         "    resp loginPage(nexusContext)\n" &
         "\n" &
         "\n" &
         "  post \"/account/login\":\n" &
         "    let nexusContext = newNextContext(request)\n" &
         "\n" &
         "    postLoginAction(nexusContext)\n" &
         "\n" &
         "\n"


proc generateRoute(
       str: var string,
       route: Route,
       module: Module,
       webArtifact: WebArtifact,
       generatorInfo: GeneratorInfo) =

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

    # Get module
    let module =
          getModuleByWebArtifact(
            webArtifact,
            generatorInfo)

    # Define procName
    var procName = route.nameInCamelCase

    if `method` == "post":
      procName &= "Post"

    procName &= "View"

    # Form URL
    debug "generateRoute()",
      lenRouteParamInfos = len(route.paramInfos)

    # Route and proc call
    str &= &"  {`method`} \"{route.jesterRoute}\":\n" &
           &"    var {module.nameInCamelCase}Context = new{module.nameInPascalCase}Context(request)\n" &
            "\n"

    responseCall(
      str,
      `method`,
      procName,
      route,
      module,
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
       module: Module,
       webArtifact: WebArtifact) =

  var procCallLine: string

  # Non-resp calls (e.g. some templates)
  if procName == "logoutAction":
    procCallLine = &"    {procName}({module.nameInCamelCase}Context)\n"

  # Resp calls (the default)
  elif webArtifact.artifact == WebServiceArtifact:

    str &= &"    resp Http200,\n" &
           &"         {{\"Access-Control-Allow-Origin\": \"*\"}},\n"

    procCallLine = &"         {procName}({module.nameInCamelCase}Context)\n"

  elif webArtifact.artifact == WebAppArtifact:
    procCallLine = &"    resp {procName}({module.nameInCamelCase}Context)\n"

  str &= procCallLine &
        "\n" &
        "\n"


proc generateRouteMethods*(
       str: var string,
       route: Route,
       module: Module,
       webArtifact: WebArtifact,
       generatorInfo: GeneratorInfo) =

  # Handle login routes with the built-in template
  if route.route == "/account/login" and
     webArtifact.artifact == WebAppArtifact:

    appendLoginPostPageRouteTemplate(str)

  else:
    # Get route
    generateRoute(str,
                  route,
                  module,
                  webArtifact,
                  generatorInfo)

