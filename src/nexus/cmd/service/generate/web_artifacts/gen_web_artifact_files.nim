import chronicles, os, sets, strformat
import nexus/cmd/service/generate/modules/module_utils
import nexus/cmd/service/generate/routes/gen_routes
import nexus/cmd/service/generate/routes/route_utils
import nexus/cmd/types/types


proc generateNewWebContext(webArtifact: WebArtifact) =

  var str = ""

  str &= "import jester\n" &
         "import nexus/core/types/model_types\n" &
         "import nexus/core/types/view_types\n" &
         "\n" &
         "\n" &
         "proc newWebContext*(\n" &
         "       request: Request,\n" &
         "       nexusCoreDbContext: NexusCoreDbContext): WebContext {.gcsafe.} =\n" &
         "\n" &
         "  # New WebContext\n" &
         "  var webContext =\n" &
         "        newBaseWebContext(request,\n" &
         "                          nexusCoreDbContext)\n" &
         "\n" &
         "  # Site-specific settings\n" &
         "  webContext.bulmaPathName = \"bulma_0.9.3/bulma\"\n" &
         "  webContext.websiteTitle = \"My Site\"\n" &
         "  webContext.cssFilenames.add(\"nexus_bulma.css\")\n" &
         "\n" &
         "  # Left menu\n" &
         "  webContext.leftMenuEntries.add(\n" &
         "    LinkMenuEntry(url: \"/\",\n" &
         "    text: \"Home\"))\n" &
         "\n" &
         "  # Return\n" &
         "  return webContext\n" &
         "\n"

  # Write new_web_context.nim routes file
  let
    path = &"{webArtifact.srcPath}{DirSep}service{DirSep}module"
    filename = &"{path}{DirSep}new_web_context.nim"

  if not dirExists(path):

    echo ".. creating path: " & path
    createDir(path)

  echo ".. writing: " & filename

  writeFile(filename,
            str)


proc generateWebArtifactRoutesFile(
       webArtifact: WebArtifact,
       generatorInfo: GeneratorInfo) =

  # Get module
  let module =
        getModuleByWebArtifact(
          webArtifact,
          generatorInfo)

  # Imports
  var imports: OrderedSet[string]

  # Routes comment
  var str = &"  # Routes for: {webArtifact.routes.name}\n"

  # Initial imports
  imports.incl("jester, os, strutils")
  # imports.incl("nexus/core/service/common/globals")
  # imports.incl("nexus/core/types/module_globals as nexus_core_module_globals")

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
      module,
      webArtifact,
      generatorInfo)

  # Final imports
  imports.incl(&"{webArtifact.srcRelativePath}/service/module/context")

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


proc generateWebArtifactFiles*(
       webArtifact: WebArtifact,
       generatorInfo: GeneratorInfo) =

  debug "generateWebAppFiles()"

  # Validate webArtifact
  if webArtifact.srcPath == "":

    raise newException(
            ValueError,
            "webArtifact.srcPath is blank")

  # Generate WebArtifact
  if len(webArtifact.routes.routes) > 0:

    generateWebArtifactRoutesFile(
      webArtifact,
      generatorInfo)

  # Generate newWebContext.nim
  generateNewWebContext(webArtifact)

