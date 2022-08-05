import chronicles, os, strformat
import nexus/cmd/service/generate/models/read_model_files
import nexus/cmd/types/types


proc generateContextType*(
       module: Module,
       generatorInfo: GeneratorInfo) =

  debug "generateContextType()"

  # Create types path if it doesn't exist
  let
    typesPath = &"{module.srcPath}{DirSep}types"
    typesFilename = &"{typesPath}{DirSep}model_types.nim"
    contextFilename = &"{typesPath}{DirSep}context_type.nim"

  # Create a basic model types file if none exists
  createDir(typesPath)

  if not fileExists(typesFilename):

    createBasicModelTypesFile(
      typesPath,
      typesFilename,
      module)

  # Skip context type file if it already exists, as users can modify it
  if fileExists(contextFilename):

    echo ".. not overwriting: " & contextFilename
    return

  # Content
  var str = ""

  if module.nameInPascalCase == "NexusCore" or
     module.isWeb == true:
    str &= "import options\n"

  if module.nameInPascalCase != "NexusCore":
    str &= "import nexus/core/types/model_types as nexus_core_model_types\n"

  if module.isWeb == true or
     module.nameInPascalCase == "NexusCore":
    str &= "import nexus/core/types/view_types\n"

  str &=  "import model_types\n" &
          "\n" &
          "\n" &
          "type\n" &
         &"  {module.nameInPascalCase}Context* = object\n" &
         &"    db*: {module.nameInPascalCase}DbContext\n"

  if module.isWeb == true or
     module.nameInPascalCase == "NexusCore":
    str &= "    web*: Option[WebContext]\n" &
           "\n"

  if module.nameInPascalCase != "NexusCore":
    str &= "    nexusCoreDbContext*: NexusCoreDbContext\n" &
           "\n"

  str &= "    # Add your own context vars below this comment\n" &
         "\n"

  # Write types file
  echo ".. writing: " & contextFilename

  writeFile(contextFilename,
            str)


proc generateContextTypes*(generatorInfo: GeneratorInfo) =

  debug "generateContextTypes()"

  for module in generatorInfo.modules.mitems():

    if module.imported == false:

      generateContextType(
        module,
        generatorInfo)

