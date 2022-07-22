import chronicles, strformat, strutils
import nexus/core/service/format/type_utils
import nexus/cmd/service/generate/models/gen_model_utils
import nexus/cmd/types/types
import data_access_helpers


# Code
proc getCustomProc*(
       str: var string,
       getFunction: GetFunction,
       model: Model) =

  debug "getCustomProc()",
    getFunction = getFunction

  # Get select/where fields with the primary key renamed to PK, and with
  # primary key name preserved.
  let
    selectFieldsWithPkName =
      getFieldsWithPkNamed(
        getFunction.selectFields,
        model)

    whereFieldsWithPkName =
      getFieldsWithPkNamed(
        getFunction.whereFields,
        model)

    selectFieldsWithActualPkName =
      getFieldsWithPkActualName(
        getFunction.selectFields,
        model)

    whereFieldsWithActualPkName =
      getFieldsWithPkActualName(
        getFunction.whereFields,
        model)

    selectFields =
      getFieldNamesInSnakeCase(
        selectFieldsWithActualPkName,
        model)

    # whereFields =
    #   getFieldNamesInSnakeCase(
    #     whereFieldsWithActualPkName,
    #     model)

  # Header
  var procName = "get"

  if getFunction.name == "by fields":
    procName &= stripAllStrings(selectFieldsWithPkName.join())

    procName &= "From" & model.nameInPascalCase

    if len(getFunction.whereFields) > 0:
      procName &= "By" & stripAllStrings(whereFieldsWithPkName.join())

  else:
    procName &= stripAllStrings(getFunction.name)

  # Determine returnType
  let
    returnType =
      getFieldsReturnType(
        selectFields,
        model,
        withOption = true)

    returnTypeWoOption =
      getFieldsReturnType(
        selectFields,
        model,
        withOption = false)

  # Proc definition
  str &= &"proc {procName}*(\n" &
         &"       {model.module.nameInCamelCase}Module: " &
           &"{model.module.nameInPascalCase}Module,\n"

  let withStringTypes = false

  if withStringTypes == false:
    listFieldNames(str,
                   model,
                   indent = "       ",
                   withNimTypes = true,
                   listFields = whereFieldsWithActualPkName)

  else:
    listFieldNames(str,
                   model,
                   indent = "       ",
                   withStringTypes = true,
                   listFields = whereFieldsWithActualPkName)

  str &= &"): {returnType} =\n" &
         &"\n"

  selectQuery(str,
              selectFieldsWithActualPkName,
              whereFieldsWithActualPkName,
              model)

  str &= "\n"

  # Get the record
  str &= &"  let row = getRow(\n" &
         &"              {model.module.nameInCamelCase}Module.db,\n" &
         &"              sql(selectStatement),\n"

  listFieldNames(str,
                 model,
                 indent = "              ",
                 listFields = whereFieldsWithActualPkName)

  str &= &")\n" &
         &"\n"

  # Return none if no row was returned
  str &= &"  if row[0] == \"\":\n" &
         &"    return none({returnTypeWoOption})\n" &
         &"\n"

  # Return the selected fields
  let returnFields =
        getFieldsFromRowToReturn(
          selectFields,
          model)

  str &= &"  return some({returnFields})\n"


proc updateCustomProc*(
       str: var string,
       updateFunction: UpdateFunction,
       model: Model) =

  debug "updateCustomProc()",
    updateFunction = updateFunction

  # Get set/where fields with the primary key renamed to PK, and with
  # primary key name preserved.
  let
    setFieldsWithPkName =
      getFieldsWithPkNamed(
        updateFunction.setFields,
        model)

    whereFieldsWithPkName =
      getFieldsWithPkNamed(
        updateFunction.whereFields,
        model)

    setFieldsWithActualPkName =
      getFieldsWithPkActualName(
        updateFunction.setFields,
        model)

    whereFieldsWithActualPkName =
      getFieldsWithPkActualName(
        updateFunction.whereFields,
        model)

    setFields =
      getFieldNamesInSnakeCase(
        setFieldsWithActualPkName,
        model)

    whereFields =
      getFieldNamesInSnakeCase(
        whereFieldsWithActualPkName,
        model)

  # Header
  var procName = "update"

  if updateFunction.name == "by fields":
    procName &= model.nameInPascalCase

    procName &= "Set" & stripAllStrings(setFieldsWithPkName.join())

    if len(updateFunction.whereFields) > 0:
      procName &= "By" & stripAllStrings(whereFieldsWithPkName.join())

  else:
    procName &= stripAllStrings(updateFunction.name)

  # Proc definition
  str &= &"proc {procName}*(\n" &
         &"       {model.module.nameInCamelCase}Module: " &
           &"{model.module.nameInPascalCase}Module,\n"

  let withStringTypes = false

  if withStringTypes == false:
    listFieldNames(
      str,
      model,
      indent = "       ",
      withNimTypes = true,
      listFields = setFieldsWithActualPkName)

    str &= ",\n"

    listFieldNames(
      str,
      model,
      indent = "       ",
      withNimTypes = true,
      listFields = whereFieldsWithActualPkName)

  else:
    listFieldNames(
      str,
      model,
      indent = "       ",
      withStringTypes = true,
      listFields = setFieldsWithActualPkName)

    str &= ",\n"

    listFieldNames(
      str,
      model,
      indent = "       ",
      withStringTypes = true,
      listFields = whereFieldsWithActualPkName)

  str &= "): int64 =\n" &
         "\n"

  # Update statement
  str &=  "  var updateStatement =\n" &
         &"    \"update {model.baseNameInSnakeCase}\" &\n"

  # Set and where clauses
  setClauseByCustomFields(
    str,
    setFields)

  whereClauseByCustomFields(
    str,
    whereFields)

  # Exec the update and return rows affected
  str &=  "  return execAffectedRows(\n" &
         &"           {model.module.nameInCamelCase}Module.db,\n" &
          "           sql(updateStatement),\n"

  # List set fields
  var first = true

  for setField in setFieldsWithActualPkName:

    if first == false:
      str &= &",\n"
    else:
      first = false

    var getOption = ""

    let field =
          getModelFieldByName(
            setField,
            model)

    if not field.constraints.contains("not null"):
      getOption = ".get"

    str &= &"           {field.nameInSnakeCase}{getOption}"

  # List where fields
  for whereField in whereFieldsWithActualPkName:

    var getOption = ""

    let field = getModelFieldByName(whereField,
                                    model)

    if not field.constraints.contains("not null"):
      getOption = ".get"

    str &= &",\n           {field.nameInSnakeCase}{getOption}"

  str &= &")\n"

