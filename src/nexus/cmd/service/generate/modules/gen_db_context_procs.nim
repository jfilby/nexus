import chronicles, os, random, strformat
import nexus/cmd/types/types


# Forward declarations
proc generateIsInATransaction(
       str: var string,
       module: Module)
proc generateNewDbContext(
       str: var string,
       module: Module,
       generatorInfo: var GeneratorInfo)
proc generateRollbackTransaction(
       str: var string,
       module: Module)


# Code
proc generateBeginTransaction(
       str: var string,
       module: Module) =

  let param = &"dbContext: {module.nameInPascalCase}DbContext"

  str &= &"proc beginTransaction*({param}) =\n" &
         "\n" &
         &"  dbContext.dbConn.exec(sql\"begin\")\n" &
         "\n\n"


proc generateCommitTransaction(
       str: var string,
       module: Module) =

  let param = &"dbContext: {module.nameInPascalCase}DbContext"

  str &= &"proc commitTransaction*({param}) =\n" &
         "\n" &
         &"  dbContext.dbConn.exec(sql\"commit\")\n" &
         "\n\n"


proc generateDbContextProcs*(
       module: Module,
       generatorInfo: var GeneratorInfo) =

  debug "generateDbContextProcs()",
    moduleName = module.name

  # Imports
  var str = "import tables\n" &
            "import db_connector/db_postgres\n" &
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

  generateNewDbContext(
    str,
    module,
    generatorInfo)

  # Verify path exists
  if module.srcPath == "":
    raise newException(
            ValueError,
            &"module path not defined for module: \"{module.name}\"")

  let modulesPath = module.srcPath & "/service/module"

  # Create Dir
  createDir(modulesPath)

  # Write module file
  let moduleDbFilename = &"{modulesPath}/db_context.nim"

  writeFile(moduleDbFilename,
            str)


proc generateDbContextProcs*(generatorInfo: var GeneratorInfo) =

  for module in generatorInfo.modules.mitems():

    if module.imported == false:

      generateDbContextProcs(
        module,
        generatorInfo)


proc generateIsInATransaction(
       str: var string,
       module: Module) =

  let param = &"dbContext: {module.nameInPascalCase}DbContext"

  str &= &"proc isInATransaction*({param}): bool =\n" &
         "\n" &
         "  let row = getRow(\n" &
        &"              dbContext.dbConn,\n" &
         "              sql\"select pg_current_xact_id_if_assigned()\")\n" &
         "\n" &
         "  if row[0] == \"\":\n" &
         "    return false\n" &
         "\n" &
         "  else:\n" &
         "    return true\n" &
         "\n\n"


proc generateNewDbContext(
       str: var string,
       module: Module,
       generatorInfo: var GeneratorInfo) =

  str &= &"proc new{module.nameInPascalCase}DbContext*(): " &
         &"{module.nameInPascalCase}DbContext =\n" &
         "\n" &
         &"  var dbContext = " &
         &"{module.nameInPascalCase}DbContext()\n" &
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

    debug "generateNewDbContext()",
      modelName = model.name

    # Generating table set strings
    let
      mth = &"  dbContext.modelToIntSeqTable" &
            &"[\"{model.name}\"] = {modelSeq}\n"

      htm = &"  dbContext.intSeqToModelTable" &
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
      ftis &= &"  dbContext.fieldToIntSeqTable" &
              &"[\"{tableField}\"] = {modelFieldSeq}\n"

      istf &= &"  dbContext.intSeqToFieldTable" &
              &"[{modelFieldSeq}] = \"{tableField}\"\n"

      modelFieldSeq += 1

    str &= ftis &
           "\n" &
           istf &
           &"\n"

  str &= &"  return dbContext\n" &
         &"\n"


proc generateRollbackTransaction(
       str: var string,
       module: Module) =

  let param = &"dbContext: {module.nameInPascalCase}DbContext"

  str &= &"proc rollbackTransaction*({param}) =\n" &
         "\n" &
         &"  dbContext.dbConn.exec(sql\"rollback\")\n" &
         "\n\n"

