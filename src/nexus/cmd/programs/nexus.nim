import os, strformat
# import nexus/core/service/format/filename_utils
import nexus/cmd/service/generate/generate


proc runMain() =

  var
    invalidParamCount = true
    command = ""
    artifact = ""
    basePath = "."
    refresh = "refresh-modified"

  let paramCount = paramCount()
  # echo &"paramCount: {paramCount}"

  # Get command
  if paramCount >= 1:
    command = paramStr(1)

  if command == "gen":
    if paramCount >= 2:

      invalidParamCount = false
      artifact = paramStr(2)
      # basePath = resolveCrossPlatformPath(getEnv("NEXUS_SRC_PATH"))

      # echo "Defaulting basePath to: $NEXUS_SRC_PATH"

    # elif paramCount() == 4:
    #   invalidParamCount = false
    #   artifact = paramStr(2)
    #   basePath = paramStr(3)
    #   refresh = paramStr(4)

  else:
    echo "Unknown command"
    echo ""
    echo "Available commands: gen"

    quit(QuitFailure)

  # Incorrect number of parameters
  if invalidParamCount == true:
    echo "Incorrect number of parameters."
    echo ""
    echo "Run: nexus gen <artifact>" # [base-path refresh]"
    echo ""
    echo "The artifact to generate: web-app | web-service | console-app | " &
         "library | models | web-routes"

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
           refresh)


when isMainModule:
  runMain()

