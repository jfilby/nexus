import chronicles, os, strformat
import nexus/cmd/types/types


proc generateContextProc*(
       module: Module,
       generatorInfo: GeneratorInfo) =

  debug "generateContextProc()"

  var str = ""

  if module.isWeb == true:
    str &=
      "import jester\n" &
      "import nexus/core/types/model_types as nexus_core_model_types\n"

  var param = ""

  if module.isWeb == true:
    param = "request: Request"

  str &=
    &"import {module.srcRelativePath}/types/context_type\n" &
    &"import {module.srcRelativePath}/types/model_types\n" &
     "import new_web_context\n" &
     "\n" &
     "\n" &
    &"proc new{module.nameInPascalCase}Context*({param}):\n" &
    &"       {module.nameInPascalCase}Context =\n" &
     "\n" &
    &"  var {module.nameInCamelCase}Context = {module.nameInPascalCase}Context()\n" &
     "\n" &
    &"  {module.nameInCamelCase}Context.db = {module.nameInPascalCase}DbContext()\n"

  if module.nameInPascalCase != "NexusCore":

    str &=
       "\n" &
      &"  {module.nameInCamelCase}Context.nexusCoreDbContext =\n" &
      &"    NexusCoreDbContext(dbConn: {module.nameInCamelCase}Context.db.dbConn)\n"

  if module.isWeb == true:
    str &=
       "\n" &
      &"  {module.nameInCamelCase}Context.web =\n" &
       "    newWebContext(request,\n"

  if module.nameInPascalCase == "NexusCore":
    str &= "                  nexusCoreDbContext)\n"

  else:
    str &= &"                  {module.nameInCamelCase}Context.nexusCoreDbContext)\n"

  str &=
     "\n" &
    &"  return {module.nameInCamelCase}Context\n" &
     "\n"

  # Write types file
  let
    modulePath = &"{module.srcPath}{DirSep}service{DirSep}module"
    contextFilename = &"{modulePath}{DirSep}context.nim"

  echo ".. writing: " & contextFilename

  createDir(modulePath)

  writeFile(contextFilename,
            str)


proc generateContextProcs*(generatorInfo: GeneratorInfo) =

  debug "generateContextProcs()"

  for module in generatorInfo.modules.mitems():

    if module.imported == false:

      generateContextProc(
        module,
        generatorInfo)

