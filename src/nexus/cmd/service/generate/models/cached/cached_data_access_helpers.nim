import strformat, strutils
import nexus/cmd/service/generate/models/model_utils
import nexus/core/service/format/case_utils
import types/types


# Forward declarations
proc getPkString(model: Model,
                 withModel: bool = true,
                 withOption: bool = false): string
proc getUniqueFieldValuesStringStr*(
       uniqueFields: seq[string],
       model: Model): string


# Code
proc addIfNotExistModelRowToCache*(
       str: var string,
       model: Model) =

  let
    cachedRows = "cached" & model.namePluralInPascalCase
    moduleVar = model.module.nameInCamelCase & "Module"
    pkField = getPkString(model)

  # Generate code to put the row in the row cache
  var addToCacheStr =
        &"    {moduleVar}.{cachedRows}[{pkField}] = {model.nameInCamelCase}\n"

  if len(addToCacheStr) > 80:

    addToCacheStr =
      &"    {moduleVar}.{cachedRows}[{pkField}] =\n" &
      &"      {model.nameInCamelCase}\n"

  # Generate code to add to the row cache
  str &=  "  # Add to the model row cache if it's not there\n" &
         &"  if not {moduleVar}.{cachedRows}.hasKey({pkField}):\n" &
         addToCacheStr &
         "\n"


proc addModelRowToCache*(
       str: var string,
       model: Model,
       withModel: bool = true,
       withOption: bool = false) =

  var
    indent = "  "
    optionGet = ""

  if withOption == true:
    optionGet = ".get"

    str &= &"  if {model.nameInCamelCase} != none({model.nameInPascalCase}):\n" &
            "\n"

    indent &= "  "

  let
    cachedRows = "cached" & model.namePluralInPascalCase
    moduleVar = model.module.nameInCamelCase & "Module"

    pkField = getPkString(model,
                          withModel = withModel,
                          withOption = withOption)

  # Generate code to put the row in the row cache
  var addToCacheStr =
        &"{indent}{moduleVar}.{cachedRows}[{pkField}] = " &
          &"{model.nameInCamelCase}{optionGet}\n"

  if len(addToCacheStr) > 80:

    addToCacheStr =
      &"{indent}{moduleVar}.{cachedRows}[{pkField}] =\n" &
      &"{indent}  {model.nameInCamelCase}{optionGet}\n"

  # Generate code to add to the row cache
  str &= &"{indent}# Add to the model row cache\n" &
         addToCacheStr &
          "\n"


proc clearFilterCache*(
       str: var string,
       model: Model) =

  let
    cachedFilter = "cachedFilter" & model.nameInPascalCase
    moduleVar = model.module.nameInCamelCase & "Module"

  str &= "  # Clear filter cache\n" &
         &"  {moduleVar}.{cachedFilter}.clear()\n" &
         "\n"


proc existsModelRowInCacheByPk*(
       str: var string,
       model: Model) =

  let
    # cachedFilter = "cachedFilter" & model.nameInPascalCase
    cachedRows = "cached" & model.namePluralInPascalCase
    moduleVar = model.module.nameInCamelCase & "Module"

    pkField = getPkString(model,
                          withModel = false)

  str &= "  # Check existence in the model row cache\n" &
         &"  if {moduleVar}.{cachedRows}.hasKey({pkField}):\n" &
         "    return true\n" &
         "\n"


proc existsModelRowInCacheByUniqueFields*(
       str: var string,
       model: Model,
       uniqueFields: seq[string]) =

  let
    cachedFilter = "cachedFilter" & model.nameInPascalCase
    moduleVar = model.module.nameInCamelCase & "Module"
    uniqueFieldsStr = join(uniqueFields, "|")
    uniqueValuesStr = getUniqueFieldValuesStringStr(uniqueFields,
                                                      model)

  str &= "  # Define the filter key\n" &
         &"  let filterKey = \"0|{uniqueFieldsStr}\" & \n" &
         &"                  \"1|\" & {uniqueValuesStr}\n" &
         "\n" &
         "  # Check existence in the model row cache\n" &
         &"  if {moduleVar}.{cachedFilter}.hasKey(filterKey):\n" &
         "    return true\n" &
         "\n"


proc filterModelGetPKsFromResults*(
       str: var string,
       model: Model) =

  let pkField = getPkString(model)

  str &= "  # Get PKs from the filter results\n" &
         &"  var pks: seq[{model.pkNimType}]\n" &
         "\n" &
         &"  for {model.nameInCamelCase} in {model.namePluralInCamelCase}:\n" &
         &"    pks.add({pkField})\n" &
         "\n"


proc filterModelGetRowsInCacheWithWhereClause*(
       str: var string,
       model: Model) =

  let
    cachedFilter = "cachedFilter" & model.nameInPascalCase
    cachedRows = "cached" & model.namePluralInPascalCase
    moduleVar = model.module.nameInCamelCase & "Module"

  str &= &"  # Get rows in the model row cache via the filter cache\n" &
         &"  let filterKey = \"0|\" & whereClause &\n" &
         &"                  \"1|\" & join(whereValues, \"|\") &\n" &
         &"                  \"2|\" & join(orderByFields, \"|\")\n" &
         "\n" &
         &"  var {cachedRows}: {model.namePluralInPascalCase}\n" &
         "\n" &
         &"  if {moduleVar}.{cachedFilter}.hasKey(filterKey):\n" &
         "\n" &
         &"    for pk in {moduleVar}.{cachedFilter}[filterKey]:\n" &
         "\n" &
         &"      {cachedRows}.add({moduleVar}.{cachedRows}[pk])\n" &
         "\n" &
         &"    return {cachedRows}\n" &
         "\n"


proc filterModelGetRowsInCacheWithWhereFields*(
       str: var string,
       model: Model) =

  let
    cachedFilter = "cachedFilter" & model.nameInPascalCase
    cachedRows = "cached" & model.namePluralInPascalCase
    moduleVar = model.module.nameInCamelCase & "Module"

  str &= "  # Get rows in the model row cache via the filter cache\n" &
         &"  let filterKey = \"0|\" & join(whereFields, \"|\") &\n" &
         &"                  \"1|\" & join(whereValues, \"|\") &\n" &
         &"                  \"2|\" & join(orderByFields, \"|\")\n" &
         "\n" &
         &"  var {cachedRows}: {model.namePluralInPascalCase}\n" &
         "\n" &
         &"  if {moduleVar}.{cachedFilter}.hasKey(filterKey):\n" &
         "\n" &
         &"    for pk in {moduleVar}.{cachedFilter}[filterKey]:\n" &
         "\n" &
         &"      {cachedRows}.add({moduleVar}.{cachedRows}[pk])\n" &
         "\n" &
         &"    return {cachedRows}\n" &
         "\n"


proc filterModelSetRowsInCacheWithWhereClause*(
       str: var string,
       model: Model) =

  let
    cachedFilter = "cachedFilter" & model.nameInPascalCase
    cachedRows = "cached" & model.namePluralInPascalCase
    moduleVar = model.module.nameInCamelCase & "Module"
    pkField = getPkString(model)

  # Generate code to put the row in the row cache
  var setInCacheStr =
        &"    {moduleVar}.{cachedRows}[{pkField}] = {model.nameInCamelCase}\n"

  if len(setInCacheStr) > 80:

    setInCacheStr =
      &"    {moduleVar}.{cachedRows}[{pkField}] =\n" &
      &"      {model.nameInCamelCase}\n"

  # Generate code to set to the row cache
  str &= "  # Set rows in filter cache\n" &
         &"  {moduleVar}.{cachedFilter}[filterKey] = pks\n" &
         "\n" &
         "  # Set rows in model row cache\n" &
         &"  for {model.nameInCamelCase} in {model.namePluralInCamelCase}:\n" &
         "\n" &
         setInCacheStr &
         "\n"


proc filterModelSetRowsInCacheWithWhereFields*(
       str: var string,
       model: Model) =

  let
    cachedFilter = "cachedFilter" & model.nameInPascalCase
    cachedRows = "cached" & model.namePluralInPascalCase
    moduleVar = model.module.nameInCamelCase & "Module"
    pkField = getPkString(model)

  # Generate code to put the row in the row cache
  var setInCacheStr =
        &"    {moduleVar}.{cachedRows}[{pkField}] = {model.nameInCamelCase}\n"

  if len(setInCacheStr) > 80:

    setInCacheStr =
      &"    {moduleVar}.{cachedRows}[{pkField}] =\n" &
      &"      {model.nameInCamelCase}\n"

  # Generate code to set to the row cache
  str &= &"  # Set rows in filter cache\n" &
         &"  {moduleVar}.{cachedFilter}[filterKey] = pks\n" &
         "\n" &
         &"  # Set rows in model row cache\n" &
         &"  for {model.nameInCamelCase} in {model.namePluralInCamelCase}:\n" &
         "\n" &
         setInCacheStr &
         &"\n"


proc getModelRowInCacheByPk*(
       str: var string,
       model: Model,
       withOption: bool) =

  let
    cachedRows = "cached" & model.namePluralInPascalCase
    moduleVar = model.module.nameInCamelCase & "Module"

    pkField = getPkString(model,
                          withModel = false)

  var
    preRet = ""
    postRet = ""

  if withOption == true:
    preRet = "some("
    postRet = ")"

  str &= &"  # Get from the model row cache\n" &
         &"  if {moduleVar}.{cachedRows}.hasKey({pkField}):\n" &
         &"    return {preRet}{moduleVar}.{cachedRows}[{pkField}]{postRet}\n" &
         &"\n"


proc getModelRowInCacheByUniqueFields*(
       str: var string,
       model: Model,
       uniqueFields: seq[string],
       withOption: bool) =

  let
    cachedFilter = "cachedFilter" & model.nameInPascalCase
    cachedRows = "cached" & model.namePluralInPascalCase
    moduleVar = model.module.nameInCamelCase & "Module"
    uniqueFieldsStr = join(uniqueFields, " ")

    uniqueValuesStr =
      getUniqueFieldValuesStringStr(
        uniqueFields,
        model)

  var
    preRet = ""
    postRet = ""

  if withOption == true:
    preRet = "some("
    postRet = ")"

  str &= "  # Define the filter key\n" &
         &"  let filterKey = \"0|{uniqueFieldsStr}\" & \n" &
         &"                  \"1|\" & {uniqueValuesStr}\n" &
         "\n" &
         "  # Get from the model row cache\n" &
         &"  if {moduleVar}.{cachedFilter}.hasKey(filterKey):\n" &
         &"    return {preRet}{moduleVar}.{cachedRows}[{moduleVar}.{cachedFilter}[filterKey][0]]{postRet}\n" &
         &"\n"


proc getPkString(model: Model,
                 withModel: bool = true,
                 withOption: bool = false): string =

  # Get model if it's an option
  var modelAccessor = ""

  if withModel == true:
    modelAccessor = model.nameInCamelCase

    if withOption == true:
      modelAccessor &= ".get"

    modelAccessor &= "."

  # No PK fields set
  if len(model.pkFields) == 0:

    raise newException(
            ValueError,
            "Cached models currently require a primary key")

  # 1 PK field set
  elif len(model.pkFields) == 1:
    return &"{modelAccessor}{model.pkNameInCamelCase}"

  # 1+ PK fields set
  elif len(model.pkFields) > 1:

    var pkFieldsCamelCase: seq[string]

    for pkField in model.pkFields:

      pkFieldsCamelCase.add(
        &"{modelAccessor}{inCamelCase(pkField)}")

    return "(" & join(pkFieldsCamelCase, ", ") & ")"


proc getUniqueFieldValuesStringStr*(
       uniqueFields: seq[string],
       model: Model): string =

  var
    first = true
    str = ""

  for uniqueField in uniqueFields:

    # Get field
    let field = getFieldByName(uniqueField,
                               model)

    # Append field name
    if first == false:
      str &= &" & \"|\" & "
    else:
      first = false

    if field.`type` != "string":
      str &= "$"

    str &= field.nameInCamelCase

  return str


proc removeModelRowFromCache*(
       str: var string,
       model: Model) =

  let
    cachedFilter = "cachedFilter" & model.nameInPascalCase
    cachedRows = "cached" & model.namePluralInPascalCase
    moduleVar = model.module.nameInCamelCase & "Module"

    pkField = getPkString(model,
                          withModel = false)

  str &= &"  # Remove from the model row cache\n" &
         &"  {moduleVar}.{cachedRows}.del({pkField})\n" &
         "\n" &
         &"  # Clear the filter cache\n" &
         &"  {moduleVar}.{cachedFilter}.clear()\n" &
         &"\n"

