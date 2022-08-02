import chronicles, os, sets, strformat
import nexus/cmd/service/generate/routes/gen_routes
import nexus/cmd/service/generate/routes/route_utils
import nexus/cmd/types/types


proc generateNewWebContext(webArtifact: WebArtifact) =

  var str = ""

  str &= "import db_postgres, jester, os\n" &
         "import nexus/core/service/common/globals\n" &
         "import nexus/core/types/model_types\n" &
         "import nexus/core/types/view_types\n" &
         "import nexus/core/view/nexus/new_web_context\n" &
         "\n" &
         "proc newWebContext*(\n" &
         "       request: Request,\n" &
         "       nexusCoreModule: NexusCoreModule): WebContext {.gcsafe.} =\n" &
         "\n" &
         "  # New WebContext\n" &
         "  var webContext = newBaseWebContext(request,\n" &
         "                                     nexusCoreModule)\n" &
         "\n" &
         "  # Site-specific settings\n" &
         "  webContext.bulmaPathName = \"bulma_0.9.3/bulma\"\n" &
         "  webContext.websiteTitle = \"My Site\"\n" &
         "  webContext.cssFilenames.add(\"nexus_bulma.css\")\n" &
         "\n" &
         "  # Left menu\n" &
         "  webContext.leftMenuEntries.add(LinkMenuEntry(url: \"/\",\n" &
         "                                               text: \"Home\"))\n" &
         "\n" &
         "  # Return\n" &
         "  return webContext\n" &
         "\n"

  # Write new_web_context.nim routes file
  let
    path = &"{webArtifact.srcPath}{DirSep}view{DirSep}web_app"
    filename = &"{path}{DirSep}new_web_context.nim"

  if not dirExists(path):

    echo ".. creating path: " & path
    createDir(path)

  echo ".. writing: " & filename

  writeFile(filename,
            str)


proc generateWebArtifactRoutesFile(webArtifact: WebArtifact) =

  # Imports
  var imports: OrderedSet[string]

  # Routes comment
  var str = &"  # Routes for: {webArtifact.routes.name}\n"

  # Initial imports
  imports.incl("chronicles, jester, os, strutils, uri")
  imports.incl("nexus/core/service/common/globals")
  imports.incl("nexus/core/types/module_globals as nexus_core_module_globals")

  # Process routes generated for the web app
  for route in webArtifact.routes.routes.mitems:

    debug "generateWebArtifactFile()",
      pagesImport = route.pagesImport

    # Add import
    imports.incl(route.pagesImport)

    # Parse the route
    parseRoute(route)

    # Generate routes
    generateRouteMethods(
      str,
      route,
      webArtifact)

  # Final imports
  # imports.incl(&"{webArtifact.srcRelativePath}/types/module_globals as " &
  #              &"{webArtifact.nameInSnakeCase}_module_globals")
  imports.incl("new_web_context")

  # Prepend imports and routes block start
  var startStr = ""

  for `import` in imports:
    startStr &= &"import {`import`}\n"

  startStr &= "\n" &
              "\n" &
              "settings:\n" &
              "  port = Port(parseInt(getEnv(\"WEB_APP_PORT\")))\n" &
              "\n" &
              "\n" &
              "routes:\n" &
              "\n"

  str = startStr & str

  # Create view dir
  if not dirExists(&"{webArtifact.srcPath}{DirSep}view{DirSep}web_app"):
    createDir(&"{webArtifact.srcPath}{DirSep}view{DirSep}web_app")

  # Write app.nim routes file
  let filename = &"{webArtifact.srcPath}{DirSep}view{DirSep}web_app{DirSep}" &
                 &"{webArtifact.nameInSnakeCase}.nim"

  echo ".. writing: " & filename

  writeFile(filename,
            str)


proc generateWebArtifactFiles*(webArtifact: WebArtifact) =

  debug "generateWebAppFiles()"

  # Validate webArtifact
  if webArtifact.srcPath == "":

    raise newException(
            ValueError,
            "webArtifact.srcPath is blank")

  # Generate WebArtifact
  if len(webArtifact.routes.routes) > 0:
    generateWebArtifactRoutesFile(webArtifact)

  # Generate newWebContext.nim
  generateNewWebContext(webArtifact)

