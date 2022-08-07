import chronicles, os, strformat
import nexus/cmd/types/types


# Forward declarations
proc generateDeleteContextProc(
       str: var string,
       module: Module)
proc generateImports(
       str: var string,
       param: var string,
       module: Module)
proc generateNewContextProc(
       str: var string,
       param: var string,
       module: Module)


# Code
proc generateContextProc*(
       module: Module,
       generatorInfo: GeneratorInfo) =

  debug "generateContextProc()"

  # Skip file if it already exists, as users can modify context procs
  let
    modulePath = &"{module.srcPath}{DirSep}service{DirSep}module"
    contextFilename = &"{modulePath}{DirSep}context.nim"

  if fileExists(contextFilename) and
     generatorInfo.overwrite == false:

    echo ".. not overwriting: " & contextFilename
    return

  # Vars
  var
    param = ""
    str = ""

  generateImports(
    str,
    param,
    module)

  generateDeleteContextProc(
    str,
    module)

  generateNewContextProc(
    str,
    param,
    module)

  # Write types file
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


proc generateDeleteContextProc(
       str: var string,
       module: Module) =

  str &=
     "proc deleteTraderEngineContext*(\n" &
    &"       {module.nameInCamelCase}Context: var {module.nameInPascalCase}Context) =\n" &
     "\n" &
    &"  closeDbConn({module.nameInCamelCase}Context.db.dbConn)\n" &
     "\n" &
     "\n"


proc generateImports(
       str: var string,
       param: var string,
       module: Module) =

  var
    imports: seq[string]
    importPrefix = ""

  if @[ "nexus",
        "nexus_plus" ].contains(module.package):

    importPrefix = &"{module.package}/"

  # Determine imports
  if module.isWeb == true or
    module.nameInPascalCase == "NexusCore":

    # Jester and options are only needed if moduleContext.web is used
    imports.add("jester, options")

  # DB Connections are always used
  imports.add("nexus/core/data_access/db_conn")

  # Nexus Core imports for non-Nexus Core modules
  if module.nameInPascalCase != "NexusCore":
    imports.add("nexus/core/types/context_type as nexus_core_context_type")
    imports.add("nexus/core/types/model_types as nexus_core_model_types")

  # Further .web imports
  if module.isWeb == true or
    module.nameInPascalCase == "NexusCore":

    imports.add(&"{importPrefix}{module.srcRelativePath}/types/context_type")
    imports.add(&"{importPrefix}{module.srcRelativePath}/types/model_types")
    imports.add("new_web_context")

    param = "request: Option[Request] = none(Request)"

  # Non .web imports
  else:
    imports.add(&"{importPrefix}{module.srcRelativePath}/types/context_type")
    imports.add(&"{importPrefix}{module.srcRelativePath}/types/model_types")

  # Generate: imports
  for `import` in imports:
    str &= &"import {`import`}\n"

  str &=
     "\n" &
     "\n"


proc generateNewContextProc(
       str: var string,
       param: var string,
       module: Module) =

  # Generate: newModuleContext()
  str &=
    &"proc new{module.nameInPascalCase}Context*({param}):\n" &
    &"       {module.nameInPascalCase}Context =\n" &
     "\n"

  # Declare context objects
  str &=
    &"  var {module.nameInCamelCase}Context =\n" &
    &"        {module.nameInPascalCase}Context(db: {module.nameInPascalCase}DbContext())\n"

  if module.nameInPascalCase != "NexusCore":
    str &=
       "\n" &
      &"  {module.nameInCamelCase}Context.nexusCoreContext =\n" &
      &"    NexusCoreContext(db: NexusCoreDbContext())\n"

  str &= "\n"

  # Generate: Init .db per context
  str &=
    &"  {module.nameInCamelCase}Context.db.dbConn = getDbConn()\n"

  if module.nameInPascalCase != "NexusCore":
    str &=
      &"  {module.nameInCamelCase}Context.nexusCoreContext.db.dbConn = {module.nameInCamelCase}Context.db.dbConn\n"

  # Generate: Init .web
  # For web-enabled modules or Nexus Core (which is a include web library procs)
  if module.isWeb == true or
     module.nameInPascalCase == "NexusCore":

    str &=
       "\n" &
      &"  {module.nameInCamelCase}Context.web =\n" &
       "    some(\n" &
       "      newWebContext(request.get,\n"

    if module.nameInPascalCase == "NexusCore":
      str &= "                    nexusCoreContext.db))\n"

    else:
      str &= &"                    {module.nameInCamelCase}Context.nexusCoreContext.db))\n"

  # For modules other than Nexus Core, create a Nexus Core context
  if module.nameInPascalCase != "NexusCore":

    if module.isWeb == true or
       module.nameInPascalCase == "NexusCore":

      str &=
         "\n" &
        &"  {module.nameInCamelCase}Context.nexusCoreContext.web = {module.nameInCamelCase}Context.web\n"

  # Generate: return
  str &=
     "\n" &
    &"  return {module.nameInCamelCase}Context\n" &
     "\n"

