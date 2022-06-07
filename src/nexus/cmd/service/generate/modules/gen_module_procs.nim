import chronicles, os, random, strformat
import nexus/cmd/types/types


# Forward declarations
proc generateRollbackTransaction*(
       str: var string,
       module: Module)


# Code
proc generateBeginTransaction(
       str: var string,
       module: Module) =

  let param = &"{module.camelCaseName}Module: {module.pascalCaseName}Module"

  str &= &"proc beginTransaction*({param}) =\n" &
         "\n" &
         &"  {module.camelCaseName}Module.db.exec(sql\"begin\")\n" &
         "\n\n"


proc generateCommitTransaction(
       str: var string,
       module: Module) =

  let param = &"{module.camelCaseName}Module: {module.pascalCaseName}Module"

  str &= &"proc commitTransaction*({param}) =\n" &
         "\n" &
         &"  {module.camelCaseName}Module.db.exec(sql\"commit\")\n" &
         "\n\n"


proc generateIsInATransaction(
       str: var string,
       module: Module) =

  let param = &"{module.camelCaseName}Module: {module.pascalCaseName}Module"

  str &= &"proc isInATransaction*({param}): bool =\n" &
         "\n" &
         "  let row = getRow(\n" &
        &"              {module.camelCaseName}Module.db,\n" &
         "              sql\"select pg_current_xact_id_if_assigned()\")\n" &
         "\n" &
         "  if row[0] == \"\":\n" &
         "    return false\n" &
         "\n" &
         "  else:\n" &
         "    return true\n" &
         "\n\n"


proc generateNewModule*(
       str: var string,
       module: Module,
       generatorInfo: var GeneratorInfo) =

  str &= &"proc new{module.pascalCaseName}Module*(): " &
         &"{module.pascalCaseName}Module =\n" &
         "\n" &
         &"  var {module.camelCaseName}Module = " &
         &"{module.pascalCaseName}Module()\n" &
         &"\n"

  randomize()

  # IntSeqs
  var
    modelSeq = 0
    modelFieldSeq = 0

  # Settings per model
  for model in generatorInfo.models.mitems():

    if model.module.name != module.name:
      continue

    debug "generateModuleProcs()",
      modelName = model.name

    # Generating table set strings
    let
      mth = &"  {module.camelCaseName}Module.modelToIntSeqTable" &
            &"[\"{model.name}\"] = {modelSeq}\n"

      htm = &"  {module.camelCaseName}Module.intSeqToModelTable" &
            &"[{modelSeq}] = \"{model.name}\"\n"

    str &= mth &
           "\n" &
           htm &
           &"\n"

    modelSeq += 1

    # Fields-to-intseqs and intseqs-to-fields
    var
      ftis = ""
      istf = ""

    # Field to int seqs
    for field in model.fields.mitems():

      let tableField = model.name & "." & field.name

      # Generating table set strings
      ftis &= &"  {module.camelCaseName}Module.fieldToIntSeqTable" &
              &"[\"{tableField}\"] = {modelFieldSeq}\n"

      istf &= &"  {module.camelCaseName}Module.intSeqToFieldTable" &
              &"[{modelFieldSeq}] = \"{tableField}\"\n"

      modelFieldSeq += 1

    str &= ftis &
           "\n" &
           istf &
           &"\n"

  str &= &"  return {module.camelCaseName}Module\n" &
         &"\n"


proc generateModuleProcs*(
       module: Module,
       generatorInfo: var GeneratorInfo) =

  debug "generateModuleProcs()",
    moduleName = module.name

  # Imports
  var str = "import db_postgres, tables\n" &
            &"import {module.importPath}/types/model_types\n" &
            "\n" &
            "\n"

  # Call generate procs
  generateBeginTransaction(
    str,
    module)

  generateCommitTransaction(
    str,
    module)

  generateIsInATransaction(
    str,
    module)

  generateRollbackTransaction(
    str,
    module)

  generateNewModule(
    str,
    module,
    generatorInfo)

  # Verify path exists
  if module.srcPath == "":
    raise newException(
            ValueError,
            &"module path not defined for module: \"{module.name}\"")

  let modulesPath = module.srcPath & "/modules"

  # Create Dir
  createDir(modulesPath)

  # Write module file
  let moduleFilename = &"{modulesPath}/{module.snakeCaseName}.nim"

  writeFile(moduleFilename,
            str)


proc generateModulesProcs*(generatorInfo: var GeneratorInfo) =

  for module in generatorInfo.modules.mitems():

    if module.imported == false:

      generateModuleProcs(module,
                          generatorInfo)


proc generateRollbackTransaction(
       str: var string,
       module: Module) =

  let param = &"{module.camelCaseName}Module: {module.pascalCaseName}Module"

  str &= &"proc rollbackTransaction*({param}) =\n" &
         "\n" &
         &"  {module.camelCaseName}Module.db.exec(sql\"rollback\")\n" &
         "\n\n"

