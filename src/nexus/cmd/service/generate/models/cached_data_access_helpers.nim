import strformat, strutils
import nexus/cmd/service/generate/models/model_utils
import types/types


# Forward declarations
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
    pkField = model.nameInCamelCase & "." & model.pkNameInCamelCase

  str &= "  # Add to the model row cache if it's not there\n" &
         &"  if not {moduleVar}.{cachedRows}.hasKey({pkField}):\n" &
         &"    {moduleVar}.{cachedRows}[{pkField}] = {model.nameInCamelCase}\n" &
         "\n"


proc addModelRowToCache*(
       str: var string,
       model: Model,
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
    pkField = &"{model.nameInCamelCase}{optionGet}.{model.pkNameInCamelCase}"

  str &= &"{indent}# Add to the model row cache\n" &
         &"{indent}{moduleVar}.{cachedRows}[{pkField}] = {model.nameInCamelCase}{optionGet}\n" &
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


proc existsModelRowInCacheByPK*(
       str: var string,
       model: Model) =

  let
    # cachedFilter = "cachedFilter" & model.nameInPascalCase
    cachedRows = "cached" & model.namePluralInPascalCase
    moduleVar = model.module.nameInCamelCase & "Module"
    pkField = model.pkNameInCamelCase

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
    # cachedRows = "cached" & model.namePluralInPascalCase
    moduleVar = model.module.nameInCamelCase & "Module"
    # pkField = model.pkNameInCamelCase
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

  let pkField = model.nameInCamelCase & "." & model.pkNameInCamelCase

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
    pkField = model.nameInCamelCase & "." & model.pkNameInCamelCase

  str &= "  # Set rows in filter cache\n" &
         &"  {moduleVar}.{cachedFilter}[filterKey] = pks\n" &
         "\n" &
         "  # Set rows in model row cache\n" &
         &"  for {model.nameInCamelCase} in {model.namePluralInCamelCase}:\n" &
         "\n" &
         &"    {moduleVar}.{cachedRows}[{pkField}] = {model.nameInCamelCase}\n" &
         "\n"


proc filterModelSetRowsInCacheWithWhereFields*(
       str: var string,
       model: Model) =

  let
    cachedFilter = "cachedFilter" & model.nameInPascalCase
    cachedRows = "cached" & model.namePluralInPascalCase
    moduleVar = model.module.nameInCamelCase & "Module"
    pkField = model.nameInCamelCase & "." & model.pkNameInCamelCase

  str &= &"  # Set rows in filter cache\n" &
         &"  {moduleVar}.{cachedFilter}[filterKey] = pks\n" &
         "\n" &
         &"  # Set rows in model row cache\n" &
         &"  for {model.nameInCamelCase} in {model.namePluralInCamelCase}:\n" &
         "\n" &
         &"    {moduleVar}.{cachedRows}[{pkField}] = {model.nameInCamelCase}\n" &
         &"\n"


proc getModelRowInCacheByPK*(
       str: var string,
       model: Model,
       withOption: bool) =

  let
    cachedRows = "cached" & model.namePluralInPascalCase
    moduleVar = model.module.nameInCamelCase & "Module"
    pkField = model.pkNameInCamelCase

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
    # pkField = model.pkNameInCamelCase
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
    pkField = model.pkNameInCamelCase

  str &= &"  # Remove from the model row cache\n" &
         &"  {moduleVar}.{cachedRows}.del({pkField})\n" &
         "\n" &
         &"  # Clear the filter cache\n" &
         &"  {moduleVar}.{cachedFilter}.clear()\n" &
         &"\n"

