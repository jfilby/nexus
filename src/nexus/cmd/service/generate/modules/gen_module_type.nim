import chronicles, strformat
import nexus/cmd/types/types


proc generateModuleGlobalVarsFile*(webApp: WebApp) =

  debug "generateModuleGlobalVarsFile()",
    webAppName = webApp.name,
    lenWebAppModules = len(webApp.modules)

  var str =
        "import nexus/core/service/common/globals\n" &
        "import model_types\n"

  for module in webApp.modules:

    if module.shortName == webApp.shortName and
       module.package == webApp.package:
      continue

    str &= &"import {module.snakeCaseName}/types/model_types as {module.snakeCaseName}_model_types\n"

  str &= "\n" &
         "\n" &
         "var\n"

  # The web app (as a module itself)
  str &= &"  {webApp.camelCaseName}Module* = {webApp.pascalCaseName}Module(db: db)\n"

  # Per webApp module
  for module in webApp.modules:

    if module.shortName == webApp.shortName and
       module.package == webApp.package:
      continue

    str &= &"  {module.camelCaseName}Module* = {module.pascalCaseName}Module(db: db)\n"

  str &= "\n"

  writeFile(filename = &"{webApp.srcPath}/types/module_globals.nim",
            str)


proc generateModuleTypeHeader*(module: Module): string =

  debug "generateModuleTypeHeader()", moduleName = module.name

  var str = &"  {module.pascalCaseName}Module* = object\n" &
             "    db*: DbConn\n" &
             "    modelToIntSeqTable*: Table[string, int]\n" &
             "    intSeqToModelTable*: Table[int, string]\n" &
             "    fieldToIntSeqTable*: Table[string, int]\n" &
             "    intSeqToFieldTable*: Table[int, string]\n" &
             "\n"

  return str


proc generateModuleTypeModel*(
       str: var string,
       model: Model) =

  if model.modelOptions.contains("cacheable"):

    let
      cachedFilter = "cachedFilter" & model.pascalCaseName
      cachedRows = "cached" & model.pascalCaseNamePlural

    str &= &"    {cachedRows}*: Table[{model.pkNimType}, {model.pascalCaseName}]\n" &
           &"    {cachedFilter}*: Table[string, seq[{model.pkNimType}]]\n" &
            "\n"

