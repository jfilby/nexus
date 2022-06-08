import chronicles, os, strformat
import cmd/types/types


# Forward declarations
proc createGetViewProc(
       str: var string,
       route: Route)
proc createPostViewProc(
       str: var string,
       route: Route)


# Code
proc createGetViewProc(
       str: var string,
       route: Route) =

  str &= &"proc {route.nameCamelCaseName}View*(\n" &
          "       request: Request,\n" &
          "       webContext: WebContext): string =\n" &
          "\n" &
         &"  return \"Starter GET view for: {route.name}\"\n" &
          "\n"


proc createInitialViewSourceFile(
       viewFilename: string,
       route: Route,
       webArtifact: WebArtifact) =

  # Vars
  var
    first = true
    str = ""

  # Imports
  str =  "import jester\n" &
        &"import {webArtifact.snakeCaseName}/view/new_web_context\n" &
         "\n" &
         "\n"

  # Get proc
  if route.methods.contains("get"):

    createGetViewProc(
      str,
      route)

  # Post proc
  if route.methods.contains("post"):

    if first == true:
      str &= "\n"
      first = false

    createPostViewProc(
      str,
      route)

  # Write file
  writeFile(
    viewFilename,
    str)


proc createPostViewProc(
       str: var string,
       route: Route) =

  str &= &"proc {route.nameCamelCaseName}PostView*(\n" &
          "       request: Request,\n" &
          "       webContext: WebContext): string =\n" &
          "\n" &
         &"  return \"Starter POST view for: {route.name}\"\n" &
          "\n"


proc generateInitialViews*(webArtifact: WebArtifact) =

  debug "generateInitialViews()",
    lenRoutes = len(webArtifact.routes.routes)

  # Iterate through routes
  for route in webArtifact.routes.routes:

    # Formulate path and filename
    let
      viewPath =
        &"{webArtifact.srcPath}{DirSep}view{DirSep}{route.groupSnakeCaseName}"

      viewFilename = &"{viewPath}{DirSep}{route.nameSnakeCaseName}.nim"

    # Create viewPath if it doesn't exist
    if not dirExists(viewPath):
      createDir(viewPath)

    # Generate an initial view source file if viewFilename doesn't exist
    if not fileExists(viewFilename):

      echo ".. creating initial view source: " & viewFilename

      createInitialViewSourceFile(
        viewFilename,
        route,
        webArtifact)

