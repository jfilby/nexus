import chronicles, strformat
import nexus/cmd/types/types


proc generateDbContextTypeHeader*(module: Module): string =

  debug "generateDbContextTypeHeader()",
    moduleName = module.name

  var str = &"  {module.nameInPascalCase}DbContext* = object\n" &
             "    dbConn*: DbConn\n" &
             "    modelToIntSeqTable*: Table[string, int]\n" &
             "    intSeqToModelTable*: Table[int, string]\n" &
             "    fieldToIntSeqTable*: Table[string, int]\n" &
             "    intSeqToFieldTable*: Table[int, string]\n" &
             "\n"

  return str


proc generateDbContextTypeModel*(
       str: var string,
       model: Model) =

  if model.modelOptions.contains("cacheable"):

    let
      cachedFilter = "cachedFilter" & model.nameInPascalCase
      cachedRows = "cached" & model.namePluralInPascalCase

    str &= &"    {cachedRows}*: Table[{model.pkNimType}, {model.nameInPascalCase}]\n" &
           &"    {cachedFilter}*: Table[string, seq[{model.pkNimType}]]\n" &
            "\n"

