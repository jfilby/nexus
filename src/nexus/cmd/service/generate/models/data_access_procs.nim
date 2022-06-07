import chronicles, strformat
import nexus/cmd/types/types
import data_access_helpers
import gen_model_utils


# Code
proc countProc*(str: var string,
                model: Model,
                pragmas: string) =

  # Proc name
  var procName = "count"

  if model.longNames == true:
    procName &= model.pascalCaseName

  # Proc definition
  let returnDetails =
        getProcPostDetails(
          "int64",
          pragmas)

  str &= &"proc {procName}*(\n" &
         &"       {model.module.camelCaseName}Module: {model.module.pascalCaseName}Module,\n" &
         &"       whereFields: seq[string] = @[],\n" &
         &"       whereValues: seq[string] = @[]){returnDetails} =\n" &
          "\n"

  # Select count query
  selectCountQuery(
    str,
    model)

  str &= "\n"

  # Where clause
  str &= &"  var first = true\n" &
          "\n"

  whereEqOnlyClause(
    str,
    "selectStatement")

  # Get the records
  str &= &"  let row = getRow({model.module.camelCaseName}Module.db,\n" &
         &"                   sql(selectStatement),\n" &
         &"                   whereValues)\n" &
          "\n"

  # Return the record count
  str &= &"  return parseBiggestInt(row[0])\n" &
         &"\n"


proc countWhereClauseProc*(
       str: var string,
       model: Model,
       pragmas: string) =

  # Proc name
  var procName = "count"

  if model.longNames == true:
    procName &= model.pascalCaseName

  # Proc definition
  let returnDetails =
        getProcPostDetails(
          "int64",
          pragmas)

  str &= &"proc {procName}*(\n" &
         &"       {model.module.camelCaseName}Module: {model.module.pascalCaseName}Module,\n" &
         &"       whereClause: string,\n" &
         &"       whereValues: seq[string] = @[]){returnDetails} =\n" &
          "\n"

  # Select count query
  selectCountQuery(
    str,
    model)

  str &= "\n" &
         "\n"

  # Where clause
  whereClause(str,
              "selectStatement")

  # Get the records
  str &= &"  let row = getRow({model.module.camelCaseName}Module.db,\n" &
          "                   sql(selectStatement),\n" &
          "                   whereValues)\n" &
          "\n"

  # Return the record count
  str &= "  return parseBiggestInt(row[0])\n" &
         "\n"


proc createProc*(str: var string,
                 pg_try_insertId: var bool,
                 model: Model,
                 pragmas: string) =

  # Proc name
  var procName = "create"

  if model.longNames == true:
    procName &= model.pascalCaseName

  procName &= "ReturnsPK"

  # Proc definition
  str &= &"proc {procName}*(\n" &
         &"       {model.module.camelCaseName}Module: {model.module.pascalCaseName}Module,\n"

  listModelFieldNames(
    str,
    model,
    indent = "       ",
    skipAutoValue = true,
    withDefaults = true,
    withNimTypes = true)

  let returnDetails =
        getProcPostDetails(
          model.pkNimType,
          pragmas)

  str &= &"){returnDetails} =\n" &
          "\n"

  # Create insert SQL statement
  buildInsertSQLFromModelFieldNames(
    str,
    model,
    indent = "  ")

  # Exec the insert statement
  if model.fields[0].constraints.contains("auto-value"):
    pg_try_insertId = true

    str &=  "  # Execute the insert statement and return the sequence values\n" &
            "  return tryInsertNamedID(\n" &
           &"    {model.module.camelCaseName}Module.db,\n" &
            "    sql(insertStatement),\n" &
           &"    \"{model.pkSnakeCaseName}\",\n" &
            "    insertValues)\n"

  else:
    str &=  "  # Execute the insert statement and return the sequence values\n" &
            "  exec(\n" &
           &"    {model.module.camelCaseName}Module.db,\n" &
            "    sql(insertStatement),\n" &
            "    insertValues)\n" &
            "\n" &
           &"  return {model.pkCamelCaseName}\n"

  str &= "\n"


proc createWithTypeProc*(
       str: var string,
       model: Model,
       pragmas: string) =

  # Proc name
  var procName = "create"

  if model.longNames == true:
    procName &= model.pascalCaseName

  # Proc definition
  str &= &"proc {procName}*(\n" &
         &"       {model.module.camelCaseName}Module: {model.module.pascalCaseName}Module,\n"

  listModelFieldNames(
    str,
    model,
    indent = "       ",
    skipAutoValue = true,
    withDefaults = true,
    withNimTypes = true)

  # Move these options to a type that includes db
  str &= ",\n       copyAllStringFields: bool = true" &
         ",\n       convertToRawTypes: bool = true"

  let returnDetails =
        getProcPostDetails(
          model.pascalCaseName,
          pragmas)

  str &= &"){returnDetails} =\n" &
         "\n"

  # Init type
  initType(str,
           indent = "  ",
           model)

  # Debug
  debug "createWithTypeProc()",
    str = str

  # Create insert SQL and insert_values seq
  var indent = "  "

  if model.pkModelDCamelCaseNames != "":

    if model.pkModelDCamelCaseNames[0] == '(':
      str &= &"{indent}{model.pkModelDCamelCaseNames} =\n"

    else:
      str &= &"{indent}{model.camelCaseName}.{model.pkCamelCaseName} =\n"

    indent &= "  "

  str &= &"{indent}create{model.pascalCaseName}ReturnsPK(\n" &
         &"{indent}  {model.module.camelCaseName}Module,\n"

  indent &= "  "

  listModelFieldNames(
    str,
    model,
    indent = indent,
    skipAutoValue = true)

  str &= ")\n" &
         "\n"

  setTypeFromFields(str,
                    model,
                    indent = "  ")

  str &= &"  return {model.camelCaseName}\n" &
          "\n"


proc deleteProcByPk*(
       str: var string,
       model: Model,
       uniqueFields: seq[string],
       withStringTypes: bool = false,
       pragmas: string): bool =

  debug "deleteProcByPk()",
    uniqueFields = uniqueFields

  let
    uniqueFieldsWithPkName =
      getFieldsWithPKNamed(
        uniqueFields,
        model)

    uniqueFieldsPascalCaseCase =
      getFieldsAsPascalCaseCase(
        uniqueFieldsWithPkName,
        model)

  # Proc name
  var procName = "delete"

  if model.longNames == true:
    procName &= model.pascalCaseName

  if uniqueFields == model.pkFields:
    procName &= "ByPK"

    if len(model.pkFields) == 0:
      return false

  else:
    procName &= "By" & uniqueFieldsPascalCaseCase

  # Proc definition
  str &= &"proc {procName}*(\n" &
         &"       {model.module.camelCaseName}Module: {model.module.pascalCaseName}Module,\n"

  if withStringTypes == false:
    listFieldNames(str,
                   model,
                   indent = "       ",
                   withNimTypes = true,
                   listFields = uniqueFields)

  else:
    listFieldNames(str,
                   model,
                   indent = "       ",
                   withStringTypes = true,
                   listFields = uniqueFields)

  let returnDetails = getProcPostDetails("int64",
                                         pragmas)

  str &= &"){returnDetails} =\n" &
          "\n"

  deleteQuery(str,
              whereFields = uniqueFields,
              model)

  str &= "\n"

  # Delete the record
  str &=  "  return execAffectedRows(\n" &
         &"           {model.module.camelCaseName}Module.db,\n" &
          "           sql(deleteStatement),\n"

  listFieldNames(str,
                 model,
                 indent = "           ",
                 listFields = uniqueFields)

  str &= ")\n" &
         "\n"

  return true


proc deleteWhereClauseProc*(
       str: var string,
       model: Model,
       pragmas: string) =

  # Proc name
  var procName = "delete"

  if model.longNames == true:
    procName &= model.pascalCaseName

  # Proc definition
  let returnDetails = getProcPostDetails("int64",
                                          pragmas)

  str &= &"proc {procName}*(\n" &
         &"       {model.module.camelCaseName}Module: {model.module.pascalCaseName}Module,\n" &
          "       whereClause: string,\n" &
         &"       whereValues: seq[string]){returnDetails} =\n" &
          "\n"

  # Delete query
  deleteQueryWhereClause(
    str,
    model)

  # Exec the delete and return rows affected
  str &=  "  return execAffectedRows(\n" &
         &"           {model.module.camelCaseName}Module.db,\n" &
          "           sql(deleteStatement),\n" &
          "           whereValues)\n" &
          "\n"


proc deleteWhereEqOnlyProc*(
       str: var string,
       model: Model,
       pragmas: string) =

  # Proc name
  var procName = "delete"

  if model.longNames == true:
    procName &= model.pascalCaseName

  # Proc definition
  let returnDetails = getProcPostDetails("int64",
                                          pragmas)

  str &= &"proc {procName}*(\n" &
         &"       {model.module.camelCaseName}Module: {model.module.pascalCaseName}Module,\n" &
          "       whereFields: seq[string],\n" &
         &"       whereValues: seq[string]){returnDetails} =\n" &
          "\n"

  # Delete query
  deleteFromOnly(
    str,
    model)

  # Where and order by clauses
  str &= "  var first = true\n" &
         "\n"

  whereEqOnlyClause(
    str,
    "deleteStatement")

  # Exec the delete and return rows affected
  str &=  "  return execAffectedRows(\n" &
         &"           {model.module.camelCaseName}Module.db,\n" &
          "           sql(deleteStatement),\n" &
          "           whereValues)\n" &
          "\n"


proc existsProc*(str: var string,
                 model: Model,
                 uniqueFields: seq[string],
                 withStringTypes: bool = false,
                 pragmas: string): bool =

  debug "existsProc()",
    uniqueFields = uniqueFields

  let
    uniqueFieldsWithPkName =
      getFieldsWithPKNamed(
        uniqueFields,
        model)

    uniqueFieldsPascalCaseCase =
      getFieldsAsPascalCaseCase(
        uniqueFieldsWithPkName,
        model)

  # Proc name
  var procName = "exists"

  if model.longNames == true:
    procName &= model.pascalCaseName

  if uniqueFields == model.pkFields:
    procName &= "ByPK"

    if len(model.pkFields) == 0:
      return false

  else:
    procName &= "By" & uniqueFieldsPascalCaseCase

  # Proc definition
  str &= &"proc {procName}*(\n" &
         &"       {model.module.camelCaseName}Module: {model.module.pascalCaseName}Module,\n"

  if withStringTypes == false:
    listFieldNames(str,
                   model,
                   indent = "       ",
                   withNimTypes = true,
                   listFields = uniqueFields)

  else:
    listFieldNames(str,
                   model,
                   indent = "       ",
                   withStringTypes = true,
                   listFields = uniqueFields)

  let returnDetails =
        getProcPostDetails(
          "bool",
          pragmas)

  str &= &"){returnDetails} =\n" &
          "\n"

  selectQuery(str,
              selectFields = @[ "1" ],
              whereFields = uniqueFields,
              model)

  str &= "\n"

  # Get the record
  str &=  "  let row = getRow(\n" &
         &"              {model.module.camelCaseName}Module.db,\n" &
          "              sql(selectStatement),\n"

  listFieldNames(str,
                 model,
                 indent = "              ",
                 listFields = uniqueFields)

  str &= &")\n" &
         &"\n"

  # Return the record
  str &= "  if row[0] == \"\":\n" &
         "    return false\n" &
         "  else:\n" &
         "    return true\n" &
         "\n"

  return true


proc rowToModelTypeDecl*(str: var string,
                         model: Model,
                         pragmas: string) =

  # Proc name
  var procName = &"rowTo{model.pascalCaseName}"

  # Proc definition
  let returnDetails =
        getProcPostDetails(
          model.pascalCaseName,
          pragmas,
          withColon = false)

  str &= &"proc {procName}*(row: seq[string]):\n" &
         &"       {returnDetails}\n"


proc rowToModelType*(str: var string,
                     model: Model,
                     pragmas: string) =

  # Proc name
  var procName = &"rowTo{model.pascalCaseName}"

  # Proc definition
  let returnDetails =
        getProcPostDetails(
          model.pascalCaseName,
          pragmas,
          withColon = false)

  str &= &"proc {procName}*(row: seq[string]):\n" &
         &"       {returnDetails} =\n" &
          "\n" &
         &"  var {model.camelCaseName} = {model.pascalCaseName}()\n" &
          "\n"

  # Create insert SQL statement
  buildAssignModelTypeFieldsFromRow(
    str,
    model,
    indent = "  ")

  str &= &"  return {model.camelCaseName}\n" &
          "\n"


proc filterProc*(str: var string,
                 model: Model,
                 pragmas: string) =

  var procName = "filter"

  if model.longNames == true:
    procName &= model.pascalCaseName

  # Proc definition
  let returnDetails =
        getProcPostDetails(
          model.pascalCaseNamePlural,
          pragmas)

  str &= &"proc {procName}*(\n" &
         &"       {model.module.camelCaseName}Module: {model.module.pascalCaseName}Module,\n" &
          "       whereClause: string = \"\",\n" &
          "       whereValues: seq[string] = @[],\n" &
         &"       orderByFields: seq[string] = @[]){returnDetails} =\n" &
          "\n"

  # Select query
  selectQuery(str,
              selectFields = @[],
              whereFields = @[],
              model)

  str &= "\n"

  # Where and order by clauses
  whereClause(str,
              "selectStatement")

  orderByClause(str,
                "selectStatement")

  str &= "\n"

  # Get the records
  str &= &"  var {model.camelCaseNamePlural}: {model.pascalCaseNamePlural}\n" &
         "\n" &
         &"  for row in fastRows({model.module.camelCaseName}Module.db,\n" &
          "                      sql(selectStatement),\n" &
          "                      whereValues):\n" &
         "\n" &
         &"    {model.camelCaseNamePlural}.add(rowTo{model.pascalCaseName}(row))\n" &
         &"\n"

  # Return the record
  str &= &"  return {model.camelCaseNamePlural}\n" &
          "\n"


proc filterWhereEqOnlyProc*(
       str: var string,
       model: Model,
       pragmas: string) =

  # Proc name
  var procName = "filter"

  if model.longNames == true:
    procName &= model.pascalCaseName

  # Proc definition
  let returnDetails =
        getProcPostDetails(
          model.pascalCaseNamePlural,
          pragmas)

  str &= &"proc {procName}*(\n" &
         &"       {model.module.camelCaseName}Module: {model.module.pascalCaseName}Module,\n" &
          "       whereFields: seq[string],\n" &
          "       whereValues: seq[string],\n" &
         &"       orderByFields: seq[string] = @[]){returnDetails} =\n" &
          "\n"

  # Select query
  selectQuery(str,
              selectFields = @[],
              whereFields = @[],
              model)

  str &= "\n"

  # Where and order by clauses
  str &= "  var first = true\n" &
         "\n"

  whereEqOnlyClause(
    str,
    "selectStatement")

  orderByClause(
    str,
    "selectStatement")

  str &= "\n"

  # Get the records
  str &= &"  var {model.camelCaseNamePlural}: {model.pascalCaseNamePlural}\n" &
          "\n" &
         &"  for row in fastRows({model.module.camelCaseName}Module.db,\n" &
          "                      sql(selectStatement),\n" &
          "                      whereValues):\n" &
          "\n" &
         &"    {model.camelCaseNamePlural}.add(rowTo{model.pascalCaseName}(row))\n" &
          "\n"

  # Return the record
  str &= &"  return {model.camelCaseNamePlural}\n" &
          "\n"


proc getProc*(str: var string,
             model: Model,
             uniqueFields: seq[string],
             withStringTypes: bool = false,
             pragmas: string): bool =

  debug "getProc()",
    uniqueFields = uniqueFields

  var
    uniqueFieldsWithPkName =
      getFieldsWithPKNamed(
        uniqueFields,
        model)

    uniqueFieldsPascalCaseCase =
      getFieldsAsPascalCaseCase(
        uniqueFieldsWithPkName,
        model)

  # Proc name
  var procName = "get"

  if model.longNames == true:
    procName &= model.pascalCaseName

  if uniqueFields == model.pkFields:
    procName &= "ByPK"

    if len(model.pkFields) == 0:
      return false

  else:
    procName &= "By" & uniqueFieldsPascalCaseCase

  # Proc definition
  str &= &"proc {procName}*(\n" &
         &"       {model.module.camelCaseName}Module: " &
         &"{model.module.pascalCaseName}Module,\n"

  if withStringTypes == false:
    listFieldNames(
      str,
      model,
      indent = "       ",
      withNimTypes = true,
      skipNimTypeOptionsForFields = uniqueFields,
      listFields = uniqueFields)

  else:
    listFieldNames(
      str,
      model,
      indent = "       ",
      withStringTypes = true,
      listFields = uniqueFields)

  let returnDetails =
        getProcPostDetails(&"Option[{model.pascalCaseName}]",
                           pragmas)

  str &= &"){returnDetails} =\n" &
          "\n"

  selectQuery(str,
              selectFields = @[],
              whereFields = uniqueFields,
              model)

  str &= "\n"

  # Get the record
  str &=  "  let row = getRow(\n" &
         &"              {model.module.camelCaseName}Module.db,\n" &
          "              sql(selectStatement),\n"

  listFieldNames(str,
                 model,
                 indent = "              ",
                 listFields = uniqueFields)

  str &= ")\n" &
         "\n"

  # Return the record
  str &=  "  if row[0] == \"\":\n" &
         &"    return none({model.pascalCaseName})\n" &
          "\n" &
         &"  return some(rowTo{model.pascalCaseName}(row))\n" &
          "\n"

  return true


proc getOrCreateProc*(str: var string,
                      model: Model,
                      uniqueFields: seq[string],
                      pragmas: string): bool =

  debug "getOrCreateProc()",
    uniqueFields = uniqueFields

  # Proc name
  var procName = "getOrCreate"

  if model.longNames == true:
    procName &= model.pascalCaseName

  # Proc definition
  if uniqueFields == model.pkFields:
    procName &= "ByPK"

    if len(model.pkFields) == 0:
      return false

  else:
    let uniqueFieldsPascalCaseCase =
          getFieldsAsPascalCaseCase(
            uniqueFields,
            model)

    procName &= "By" & uniqueFieldsPascalCaseCase

  str &= &"proc {procName}*(\n" &
         &"       {model.module.camelCaseName}Module: {model.module.pascalCaseName}Module,\n"

  listModelFieldNames(
    str,
    model,
    indent = "       ",
    skipAutoValue = true,
    withNimTypes = true,
    skipNimTypeOptionsForFields = uniqueFields)  # Prevents doubling up Option[..]

  let returnDetails =
        getProcPostDetails(
          model.pascalCaseName,
          pragmas)

  str &= &"){returnDetails} =\n" &
          "\n"

  # Are the unique fields the PK fields?
  var getByFields: string

  if uniqueFields == model.pkFields:
    getByFields = "PK"
  else:
    getByFields =
      getFieldsAsPascalCaseCase(
        uniqueFields,
        model)

  # Select one
  str &= &"  let {model.camelCaseName} =\n" &
         &"        get{model.pascalCaseName}By{getByFields}(\n" &
         &"          {model.module.camelCaseName}Module,\n"

  listFieldNames(str,
                 model,
                 indent = "          ",
                 listFields = uniqueFields)

  str &= ")\n" &
         "\n"

  # Return if a record was found
  str &= &"  if {model.camelCaseName} != none({model.pascalCaseName}):\n" &
         &"    return {model.camelCaseName}.get\n" &
          "\n"

  # Create uniqueFieldsExcludingOptionTypes
  var uniqueFieldsExcludingOptionTypes =
        fieldListWithoutOptionalFields(
          model,
          uniqueFields)

  # Call create (no record found) and return the type
  str &= &"  return create{model.pascalCaseName}(\n" &
         &"           {model.module.camelCaseName}Module,\n"

  listModelFieldNames(
    str,
    model,
    indent = "           ",
    skipAutoValue = true,
    addNimTypeOptionsForFields = uniqueFieldsExcludingOptionTypes)

  str &= &")\n" &
         &"\n"

  return true


proc truncate*(str: var string,
               model: Model,
               pragmas: string) =

  var procName = "truncate"

  if model.longNames == true:
    procName &= model.pascalCaseName

  let sql = &"truncate table {model.base_snake_case_name} restart identity"

  str &= &"proc {procName}*(\n" &
         &"       {model.module.camelCaseName}Module: {model.module.pascalCaseName}Module,\n" &
          "       cascade: bool = false) =\n" &
          "\n" &
          "  if cascade == false:\n" &
         &"    exec({model.module.camelCaseName}Module.db,\n" &
         &"         sql(\"{sql};\"))\n" &
          "\n" &
          "  else:\n" &
         &"    exec({model.module.camelCaseName}Module.db,\n" &
         &"         sql(\"{sql} cascade;\"))\n" &
          "\n"


proc updateByPKProc*(str: var string,
                     model: Model,
                     pragmas: string): bool =

  # Proc name
  var procName = "update"

  if model.longNames == true:
    procName &= model.pascalCaseName

  if len(model.pkFields) == 0:
    return false

  # Proc definition
  let returnDetails =
        getProcPostDetails(
          "int64",
          pragmas)

  str &= &"proc {procName}ByPK*(\n" &
         &"       {model.module.camelCaseName}Module: {model.module.pascalCaseName}Module,\n" &
         &"       {model.camelCaseName}: {model.pascalCaseName},\n" &
          "       setFields: seq[string],\n" &
         &"       exceptionOnNRowsUpdated: bool = true){returnDetails} =\n" &
          "\n"

  # Update call clause
  updateCallClause(str,
                   procName,
                   "update",
                   model)

  # Where clause
  wherePKClause(str,
                "updateStatement",
                "update",
                model)

  # Exec the update and return rows affected
  str &=  "  let rowsUpdated = \n" &
          "        execAffectedRows(\n" &
         &"          {model.module.camelCaseName}Module.db,\n" &
          "          sql(updateStatement),\n" &
          "          updateValues)\n" &
          "\n" &
          "  # Exception on no rows updated\n" &
          "  if rowsUpdated == 0 and\n" &
          "     exceptionOnNRowsUpdated == true:\n" &
          "\n" &
          "    raise newException(ValueError,\n" &
          "                       \"no rows updated\")\n" &
          "\n" &
          "  # Return rows updated\n" &
          "  return rowsUpdated\n" &
          "\n"

  return true


proc updateSetClause*(str: var string,
                      model: Model,
                      pragmas: string) =

  # Proc name
  var procName = "update"

  if model.longNames == true:
    procName &= model.pascalCaseName

  # Proc definition
  let returnDetails =
        getProcPostDetails(
          "",
          pragmas)

  str &= &"proc {procName}SetClause*(\n" &
         &"       {model.camelCaseName}: {model.pascalCaseName},\n" &
          "       setFields: seq[string],\n" &
          "       updateStatement: var string,\n" &
         &"       updateValues: var seq[string]){returnDetails} =\n" &
          "\n" &
          "  updateStatement =\n" &
         &"    \"update {model.baseSnakeCaseName}\" &\n"

  setClause(str,
            "update",
            model)

  str &= "\n"


proc updateWhereClauseProc*(
       str: var string,
       model: Model,
       pragmas: string) =

  # Proc name
  var procName = "update"

  if model.longNames == true:
    procName &= model.pascalCaseName

  # Proc definition
  let returnDetails =
        getProcPostDetails(
          "int64",
          pragmas)

  str &= &"proc {procName}ByWhereClause*(\n" &
         &"       {model.module.camelCaseName}Module: {model.module.pascalCaseName}Module,\n" &
         &"       {model.camelCaseName}: {model.pascalCaseName},\n" &
          "       setFields: seq[string],\n" &
          "       whereClause: string,\n" &
         &"       whereValues: seq[string]){returnDetails} =\n" &
          "\n"

  # Update call clause
  updateCallClause(str,
                   procName,
                   "update",
                   model)

  whereClause(str,
              "updateStatement")

  # Exec the update and return rows affected
  str &=  "  return execAffectedRows(\n" &
         &"           {model.module.camelCaseName}Module.db,\n" &
          "           sql(updateStatement),\n" &
          "           concat(updateValues,\n" &
          "                  whereValues))\n" &
          "\n"


proc updateWhereEqOnlyProc*(
       str: var string,
       model: Model,
       pragmas: string) =

  # Proc name
  var procName = "update"

  if model.longNames == true:
    procName &= model.pascalCaseName

  # Proc definition
  let returnDetails =
        getProcPostDetails(
          "int64",
          pragmas)

  str &= &"proc {procName}ByWhereEqOnly*(\n" &
         &"       {model.module.camelCaseName}Module: {model.module.pascalCaseName}Module,\n" &
         &"       {model.camelCaseName}: {model.pascalCaseName},\n" &
          "       setFields: seq[string],\n" &
          "       whereFields: seq[string],\n" &
         &"       whereValues: seq[string]){returnDetails} =\n" &
          "\n"

  # Update call clause
  updateCallClause(str,
                   procName,
                   "update",
                   model)

  str &= &"  var first = true\n" &
         &"\n"

  whereEqOnlyClause(str,
                    "updateStatement")

  # Exec the update and return rows affected
  str &=  "  return execAffectedRows(\n" &
         &"           {model.module.camelCaseName}Module.db,\n" &
          "           sql(updateStatement),\n" &
          "           concat(updateValues,\n" &
          "                  whereValues))\n" &
          "\n"

