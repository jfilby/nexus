import os, parseopt, strformat, strutils
# import nexus/core/service/format/filename_utils
import nexus/cmd/service/generate/generate


proc runMain() =

  var
    invalidParamCount = true
    command = ""
    artifact = ""
    basePath = "."
    refresh = "refresh-modified"

  # Parse parameters
  let paramCount = paramCount()

  var
    options: seq[string]
    args: seq[string]

  for i in 1 .. paramCount:

    let arg = paramStr(i)

    if arg[0] == '-':
      options.add(arg)

    else:
      args.add(arg)

  # Optional flags
  var
    opts = initOptParser(
             join(options, " "))

    overwrite = false

  for kind, key, val in getopt(opts):

    if (kind == cmdShortOption and
        key == "o") or
       (kind == cmdLongOption and
        key == "overwrite"):

      overwrite = true

  # Get command
  if len(args) >= 1:
    command = args[0]

  if command == "gen":
    if len(args) >= 2:

      invalidParamCount = false
      artifact = args[1]

  else:
    echo "Unknown command"
    echo ""
    echo "Available commands: gen"

    quit(QuitFailure)

  # Incorrect number of parameters
  if invalidParamCount == true:
    echo "Incorrect number of parameters."
    echo ""
    echo "Run: nexus [options] gen <artifact>" # [base-path refresh]"
    echo ""
    echo "The artifact to generate: web-app | web-service | console-app | " &
         "library | models | web-routes"
    echo ""
    echo "Options:"
    echo "--overwrite or -o: Overwrite generated context files if they exist"

    quit(QuitFailure)

  # Validate artifact
  if not @[ "web-app",
            "console-app",
            "library",
            "models",
            "web-routes" ].contains(artifact):

    echo "Invalid artifact specified, must be one of:"
    echo ""
    echo "web-app: generates initial directories and files for a web-app or " &
         "web-service"
    echo "console-app: generates initial directories and files for a " &
         "console app"
    echo "models: generates data object create SQL and data access files " &
         "from conf/models/models.yaml"
    echo "web-routes: generates a view/web_app/web_app.nim file with Nexus " &
         "Core routes"

    quit(QuitFailure)

  # Notice
  echo &". basePath: {basePath} (expects conf/*.yaml files and project directories)"

  generate(artifact,
           basePath,
           refresh,
           overwrite)


# Main
when isMainModule:
  runMain()

