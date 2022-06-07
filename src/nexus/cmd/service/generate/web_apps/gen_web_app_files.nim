import chronicles, os, sets, strformat
import nexus/cmd/service/generate/routes/gen_routes
import nexus/cmd/types/types


proc generateNewWebContext(webApp: WebApp) =

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

  # Write app.nim routes file
  let
    path = &"{webApp.srcPath}{DirSep}view{DirSep}web_app"
    filename = &"{path}{DirSep}new_web_context.nim"

  if not dirExists(path):

    echo ".. creating path: " & path
    createDir(path)

  echo ".. writing: " & filename

  writeFile(filename,
            str)


proc generateWebAppFile(webApp: WebApp) =

  # Imports
  var imports: OrderedSet[string]

  # Routes comment
  var str = &"  # Routes for: {webApp.routes.name}"

  # Process routes generated for the web app
  for route in webApp.routes.routes:

    debug "generateWebAppFile()",
      name = model.name

    # Add import
    imports.incl(route.pagesImport)

    # Generate routes
    generateRouteMethods(
      str,
      route,
      webApp)

  # Add additional imports
  imports.incl("chronicles, jester, os, strutils, uri")
  imports.incl("nexus_core/service/common/globals")
  imports.incl("nexus_core/types/module_globals as nexusCoreModule_globals")
  imports.incl(&"{webApp.srcRelativePath}/types/module_globals as " &
               &"{webApp.snakeCaseName}_module_globals")
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
  if not dirExists(&"{webApp.srcPath}{DirSep}view{DirSep}web_app"):
    createDir(&"{webApp.srcPath}{DirSep}view{DirSep}web_app")

  # Write app.nim routes file
  let filename = &"{webApp.srcPath}{DirSep}view{DirSep}web_app{DirSep}" &
                 "web_app.nim"

  if not fileExists(filename):

    echo ".. writing: " & filename

    writeFile(filename,
              str)


proc generateWebAppFiles*(webApp: WebApp) =

  debug "generateWebAppFiles()"

  if len(webApp.routes.routes) > 0:
    generateWebAppFile(webApp)

  generateNewWebContext(webApp)

