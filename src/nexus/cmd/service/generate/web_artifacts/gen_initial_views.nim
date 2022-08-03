import chronicles, os, strformat
import nexus/cmd/types/types


# Forward declarations
proc createGetViewProc(
       str: var string,
       module: Module,
       route: Route)
proc createPostViewProc(
       str: var string,
       module: Module,
       route: Route)


# Code
proc createGetViewProc(
       str: var string,
       module: Module,
       route: Route) =

  str &= &"proc {route.nameInCamelCase}View*(\n" &
         &"       {module.nameInCamelCase}Context: {module.nameInPascalCase}Context): string =\n" &
          "\n" &
         &"  return \"Starter GET view for: {route.name}\"\n" &
          "\n"


proc createInitialViewSourceFile(
       viewFilename: string,
       route: Route,
       module: Module,
       webArtifact: WebArtifact) =

  # Vars
  var
    first = true
    str = ""

  # Imports
  str =  "# import jester\n" &
         "# import nexus/core/types/view_types\n" &
        &"import {module.srcRelativePath}/types/context_type\n" &
         "\n" &
         "\n"

  # Get proc
  if route.methods.contains("get"):

    createGetViewProc(
      str,
      module,
      route)

  # Post proc
  if route.methods.contains("post"):

    if first == true:
      str &= "\n"
      first = false

    createPostViewProc(
      str,
      module,
      route)

  # Write file
  writeFile(
    viewFilename,
    str)


proc createPostViewProc(
       str: var string,
       module: Module,
       route: Route) =

  str &= &"proc {route.nameInCamelCase}PostView*(\n" &
         &"       {module.nameInSnakeCase}Context: {module.nameInPascalCase}Context): string =\n" &
          "\n" &
         &"  return \"Starter POST view for: {route.name}\"\n" &
          "\n"


proc generateInitialViews*(
       module: Module,
       webArtifact: WebArtifact) =

  debug "generateInitialViews()",
    lenRoutes = len(webArtifact.routes.routes)

  # Iterate through routes
  for route in webArtifact.routes.routes:

    # Formulate path and filename
    let
      viewPath =
        &"{webArtifact.srcPath}{DirSep}view{DirSep}{route.groupInSnakeCase}"

      viewFilename = &"{viewPath}{DirSep}{route.nameInSnakeCase}.nim"

    # Create viewPath if it doesn't exist
    if not dirExists(viewPath):
      createDir(viewPath)

    # Generate an initial view source file if viewFilename doesn't exist
    if not fileExists(viewFilename):

      echo ".. creating initial view source: " & viewFilename

      createInitialViewSourceFile(
        viewFilename,
        route,
        module,
        webArtifact)

