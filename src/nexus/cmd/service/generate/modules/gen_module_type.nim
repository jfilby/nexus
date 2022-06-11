import chronicles, os, strformat
import nexus/cmd/types/types


proc generateModuleGlobalVarsFile*(webArtifact: WebArtifact) =

  debug "generateModuleGlobalVarsFile()",
    webAppName = webArtifact.name,
    lenWebAppModules = len(webArtifact.modules)

  var str =
        "import nexus/core/service/common/globals\n" &
        "import model_types\n"

  for module in webArtifact.modules:

    if module.shortName == webArtifact.shortName and
       module.package == webArtifact.package:
      continue

    str &= &"import {module.nameInSnakeCase}/types/model_types as " &
           &"{module.nameInSnakeCase}_model_types\n"

  str &= "\n" &
         "\n" &
         "var\n"

  # The web-app (as a module itself)
  str &= &"  {webArtifact.nameInCamelCase}Module* = " &
         &"{webArtifact.nameInPascalCase}Module(db: db)\n"

  # Per web-app module
  for module in webArtifact.modules:

    if module.shortName == webArtifact.shortName and
       module.package == webArtifact.package:
      continue

    str &= &"  {module.nameInCamelCase}Module* = "&
           &"{module.nameInPascalCase}Module(db: db)\n"

  str &= "\n"

  # Formulate path and filename
  let
    path = &"{webArtifact.srcPath}{DirSep}types"
    filename = &"{path}{DirSep}module_globals.nim"

  # Create directory
  if not dirExists(path):
    createDir(path)

  # Write module_globals.nim source file
  writeFile(filename,
            str)


proc generateModuleTypeHeader*(module: Module): string =

  debug "generateModuleTypeHeader()", moduleName = module.name

  var str = &"  {module.nameInPascalCase}Module* = object\n" &
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
      cachedFilter = "cachedFilter" & model.nameInPascalCase
      cachedRows = "cached" & model.namePluralInPascalCase

    str &= &"    {cachedRows}*: Table[{model.pkNimType}, {model.nameInPascalCase}]\n" &
           &"    {cachedFilter}*: Table[string, seq[{model.pkNimType}]]\n" &
            "\n"

