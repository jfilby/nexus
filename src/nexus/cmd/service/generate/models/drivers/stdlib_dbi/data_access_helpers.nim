import chronicles, options, strformat, strutils
import nexus/core/service/format/type_utils
import nexus/cmd/service/generate/models/gen_model_utils
import nexus/cmd/service/generate/models/model_utils
import nexus/cmd/types/types


# Forward declarations
proc getDbToStringFunc*(
       `type`: string,
       inParentheses: Option[string] = none(string)): string
proc getWherePredicates*(
       whereFields: seq[string],
       model: Model): seq[string]
proc listModelFieldNames*(
       str: var string,
       model: Model,
       horizontal: bool = false,
       indent: string,
       quoted: bool = false,
       skipAutoValue: bool = false,
       withDefaults: bool = false,
       withNimTypes: bool = false,
       skipNimTypeOptionsForFields: seq[string] = @[],
       addNimTypeOptionsForFields: seq[string] = @[],
       withStringTypes: bool = false)
proc listQuestionMarks*(
       str: var string,
       qLen: int)


# Code
proc buildAssignModelTypeFieldsFromRow*(
       str: var string,
       model: Model,
       indent: string) =

  var
    i = 0
    prevBreak = false

  for field in model.fields:

    # Get convert function
    let convertFunction =
          getConvertStringToNimTypeFunction(field)

    # Get fieldNimType
    let fieldNimType = getNimType(field,
                                  withOption = false)

    # Not null fields: add to insert statement
    if field.constraints.contains("not null"):

      if field.`type` == "char":
        str &= &"{indent}{model.nameInCamelCase}.{field.nameInCamelCase} = row[{i}][0]\n"
      elif field.`type` == "string":
        str &= &"{indent}{model.nameInCamelCase}.{field.nameInCamelCase} = row[{i}]\n"
      else:
        str &= &"{indent}{model.nameInCamelCase}.{field.nameInCamelCase} = {convertFunction}(row[{i}])\n"

      prevBreak = false

    else:

      if prevBreak == false:
        str &= "\n"

      str &= &"{indent}if row[{i}] != \"\":\n"

      if field.`type` == "char":
        str &= &"{indent}  {model.nameInCamelCase}.{field.nameInCamelCase} = some(row[{i}][0])\n"
      elif field.`type` == "string":
        str &= &"{indent}  {model.nameInCamelCase}.{field.nameInCamelCase} = some(row[{i}])\n"
      else:
        str &= &"{indent}  {model.nameInCamelCase}.{field.nameInCamelCase} = some({convertFunction}(row[{i}]))\n"

      str &= &"{indent}else:\n" &
             &"{indent}  {model.nameInCamelCase}.{field.nameInCamelCase} = none({fieldNimType})\n"

      prevBreak = true
      str &= "\n"

    # Inc i
    i += 1

  str &= "\n"


proc buildInsertSQLFromModelFieldNames*(
       str: var string,
       model: Model,
       indent: string) =

  str &= &"{indent}# Formulate insertStatement and insertValues\n" &
         &"{indent}var\n" &
         &"{indent}  insertValues: seq[string]\n" &
         &"{indent}  insertStatement = \"insert into {model.baseNameInSnakeCase} (\"\n" &
         &"{indent}  valuesClause = \"\"\n"

  var
    skipFieldsComma = true
    skipValuesComma = true

  for field in model.fields:

    # Skip PK if auto-gen and not uuid
    if field.constraints.contains("auto-value") and
       field.`type` != "uuid":

      continue

    str &= "\n" &
           &"{indent}# Field: {field.name}\n"

    # Get fieldNimType
    let fieldNimType =
          getNimType(field,
                     withOption = false)

    # Add field value
    var
      getOption = ""
      aIndent = indent

    # Not null fields: add to insert statement
    if not field.constraints.contains("not null"):

      aIndent &= "  "
      getOption = ".get"

      str &= &"{indent}if {field.nameInCamelCase} != none({fieldNimType}):\n"

    skipFieldsComma = false
    skipValuesComma = false

    debug "buildInsertSQLFromModelFieldNames(): field",
      name = field.name,
      fieldType = field.`type`

    # Add field name to insert caluse (uuid is a special case)
    if field.`type` == "uuid":
      str &= &"{aIndent}insertStatement &= \"uuid_generate_v1(), \"\n"

    else:
      str &= &"{aIndent}insertStatement &= \"{field.nameInSnakeCase}, \"\n"

    # Define field, which may be quoted
    var valueStr = &"{field.nameInCamelCase}{getOption}"

    # Add field value to the values clause
    let andComma = &"& \", \""

    # The string type (no conversion necessary)
    if field.`type` == "string":
      str &= &"{aIndent}valuesClause &= \"?\" {andComma}\n"
      str &= &"{aIndent}insertValues.add({valueStr})\n"

    # Types that must be handled by DB functions
    elif @[ "char",
            "char[]",
            "datetime",
            "datetime[]",
            "float[]",
            "int[]",
            "int64[]",
            "json",
            "jsonb",
            "string[]" ].contains(field.`type`):

      var dbToStringFunc =
            getDbToStringFunc(
              field.`type`,
              inParentheses = some(valueStr))

      # Certain DB functions must be quoted: chars, array and json types
      if @[ "char",
            "char[]",
            "float[]",
            "int[]",
            "int64[]",
            "json",
            "jsonb",
            "string[]" ].contains(field.`type`):

        dbToStringFunc = "\"'\" & " & dbToStringFunc & " & \"'\""

      str &= &"{aIndent}valuesClause &= {dbToStringFunc} {andComma}\n"

    # Types that can be safely stringified with $
    else:
      str &= &"{aIndent}valuesClause &= \"?, \"\n"
      str &= &"{aIndent}insertValues.add(${valueStr})\n"

  # Remove trailing commas and finalize insertStatement
  str &= "\n" &
         &"{indent}# Remove trailing commas and finalize insertStatement\n" &
         &"{indent}if insertStatement[len(insertStatement) - 2 .. len(insertStatement) - 1] == \", \":\n" &
         &"{indent}  insertStatement = insertStatement[0 .. len(insertStatement) - 3]\n" &
         "\n" &
         &"{indent}if valuesClause[len(valuesClause) - 2 .. len(valuesClause) - 1] == \", \":\n" &
         &"{indent}  valuesClause = valuesClause[0 .. len(valuesClause) - 3]\n" &
         &"\n"

  # End fields clause and begin values clause
  str &= &"{indent}# Finalize insertStatement\n" &
         &"{indent}insertStatement &= \") values (\" & valuesClause & \")\"\n" &
         &"\n"


proc deleteFromOnly*(
       str: var string,
       model: Model) =

  # Create select SQL statement
  str &=  "  var deleteStatement =\n" &
          "    \"delete\" & \n" &
         &"    \"  from {model.baseNameInSnakeCase}\"\n" &
          "\n"


# Delete by whereFields
proc deleteQuery*(
       str: var string,
       whereFields: seq[string],
       model: Model) =

  # Get where predicates
  let wherePredicates =
        getWherePredicates(
          whereFields,
          model)

  # Create select SQL statement
  str &= &"  var deleteStatement =\n" &
         &"    \"delete\" & \n" &
         &"    \"  from {model.baseNameInSnakeCase}\""

  if len(whereFields) == 0:
    str &= "\n"
  else:
    str &= &" &\n" &
           &"    \" where {wherePredicates[0]}\""

  for i in 1 .. len(wherePredicates) - 1:
    str &= &"&\n"
    str &= &"    \"   and {wherePredicates[i]}\""

  str &= "\n"


# Delete by a given where string
proc deleteQueryWhereClause*(
       str: var string,
       model: Model) =

  # Create select SQL statement
  str &= &"  var deleteStatement =\n" &
         &"    \"delete\" & \n" &
         &"    \"  from {model.baseNameInSnakeCase}\" &\n" &
         &"    \" where \" & whereClause\n"

  str &= "\n"


proc getFieldsAsPascalCaseCase*(
       uniqueFields: seq[string],
       model: Model,
       joinStr = "And"): string =

  let uniqueFieldNames =
        getFieldsWithPKNamed(
          uniqueFields,
          model)

  return stripAllStrings(uniqueFieldNames.join(joinStr))


proc getFieldsReturnType*(
       selectFields: seq[string],
       model: Model,
       withOption: bool = false): string =

  var
    first = true
    returnType = ""

  for selectField in selectFields:

    # Add a comma
    if first == false:
      returnType &= ", "
    else:
      first = true

    # Get model field and nim type
    let field = getFieldBySnakeCaseName(selectField,
                                        model)

    let fieldNimType = getNimType(field,
                                  withOption = false)

    # Add field type to the return type
    returnType &= fieldNimType

  if len(selectFields) > 1:
    returnType = "(" & returnType & ")"

  if withOption == true:
    returnType = "Option[" & returnType & "]"

  return returnType


proc getFieldsFromRowToReturn*(
       selectFields: seq[string],
       model: Model): string =

  var
    i = 0
    first = true
    returnFields = ""

  for selectField in selectFields:

    # Add a comma
    if first == false:
      returnFields &= ", "
    else:
      first = true

    # Get model field and nim type
    let field = getFieldBySnakeCaseName(
                  selectField,
                  model)

    # Get convert function
    let convertFunction =
          getConvertStringToNimTypeFunction(field)

    # Add field type to the return type
    if convertFunction == "":
      returnFields &= &"row[{i}]"

    else:
      returnFields &= &"{convertFunction}(row[{i}])"

    # Inc i
    i += 1

  if len(selectFields) > 1:
    return "(" & returnFields & ")"

  return returnFields


proc countFieldNames*(
       model: Model,
       countNonStringTypes: bool = false,
       countStringTypes: bool = false,
       listFields: seq[string]): int =

  debug "countFieldNames()",
    listFields = listFields

  var count = 0

  for listField in listFields:

    # Get field
    let field = getFieldByName(listField,
                               model)

    # Add type
    let nimType = getNimType(field)

    if countNonStringTypes == true and
       nimType != "string":

      count += 1

    if countStringTypes == true and
       nimType == "string":

      count += 1

  debug "countFieldNames()",
    count = count

  return count


proc fieldListWithoutOptionalFields*(
       model: Model,
       listFields: seq[string]): seq[string] =

  var returnFields: seq[string]

  for listField in listFields:

    # Get field
    let field = getFieldByName(listField,
                               model)

    if not field.constraints.contains("not null"):
      returnFields.add(listField)

  # Return
  return returnFields


proc getDbToStringFunc*(
       `type`: string,
       inParentheses: Option[string] = none(string)): string =

  var
    isFunc = true
    str = ""

  case `type`:

    of "bool":
      str = "pgToBool"

    of "char[]", "float[]", "int64[]":
      str = "getSeqNonStringAsPgArrayString"

    of "date":
      str = "pgToDateString"

    of "datetime":
      str = "pgToDateTimeString"

    of "char", "float", "int", "int64", "json", "jsonb":
      isFunc = false
      str = "$"

    of "string", "uuid":
      isFunc = false
      str = ""

    of "string[]":
      str = "getSeqStringAsPgArrayString"

    else:
      raise newException(
              ValueError,
              &"Unhandled type: {`type`}")

  # In parentheses?
  if inParentheses == none(string):
    return str

  # With parentheses
  if isFunc == false:
    return &"{str}{inParentheses.get}"

  else:
    return &"{str}({inParentheses.get})"


proc listFieldNames*(
       str: var string,
       model: Model,
       horizontal: bool = false,
       indent: string,
       quoted: bool = false,
       withDefaults: bool = false,
       withNimTypes: bool = false,
       skipNimTypeOptionsForFields: seq[string] = @[],
       addNimTypeOptionsForFields: seq[string] = @[],
       withStringTypes: bool = false,
       listFields: seq[string]) =

  debug "listFieldNames()",
    fields = fields

  var first = true

  for listField in listFields:

    # Get field
    let field =
          getFieldByName(listField,
                         model)

    # Compose lines (for string and non-strings)
    if first == false:
      if quoted == true:
        str &= &",\" &"
      else:
        str &= &","

      if horizontal == false:
        str &= "\n"

    else:
      first = false

    # Add field variable name
    var varName = field.nameInCamelCase

    if addNimTypeOptionsForFields.contains(listField):
      varName = &"some({varName})"

    if quoted == true:
      str &= &"{indent}\" {varName}"
    else:
      str &= &"{indent}{varName}"

    # Add type
    var nimType: string

    if withStringTypes == true:
      nimType = "string"
      str &= ": string"

    elif withNimTypes == true:
      var withNimTypeOptions = true

      if skipNimTypeOptionsForFields.contains(listField):
        withNimTypeOptions = false

      let nimType = getNimType(field,
                               withOption = withNimTypeOptions)

      str &= &": {nimType}"

    # Add default if specified
    if withDefaults == true:

      var foundDefault = false

      for defaultField in model.defaults:
        if defaultField.field == field.name:

          foundDefault = true

          str &= " = " & getDefaultValueAsNimValue(model,
                                                   field).get

      if foundDefault == false and
         not field.constraints.contains("not null"):

        let nimTypeWithoutOption =
              getNimType(field,
                         withOption = false)

        str &= &" = none({nimTypeWithoutOption})"


proc listFieldNamesWithDbToStringFuncs*(
       str: var string,
       model: Model,
       indent: string,
       listFields: seq[string]) =

  var first = true

  for listField in listFields:

    # Comma and new line if not first iter
    if first == false:
      str &= ",\n"

    else:
      first = false

    # Get field
    let
      field =
        getFieldByName(listField,
                       model)

      dbToStringFunc =
        getDbToStringFunc(
          field.`type`,
          inParentheses = some(field.nameInCamelCase))

    str &= &"{indent}{dbToStringFunc}"


proc listModelFieldNames*(
       str: var string,
       model: Model,
       horizontal: bool = false,
       indent: string,
       quoted: bool = false,
       skipAutoValue: bool = false,
       withDefaults: bool = false,
       withNimTypes: bool = false,
       skipNimTypeOptionsForFields: seq[string] = @[],
       addNimTypeOptionsForFields: seq[string] = @[],
       withStringTypes: bool = false) =

  var fields: seq[string]

  for field in model.fields:

    if skipAutoValue == true:
      if field.constraints.contains("auto-value"):
        continue

    fields.add(field.name)

  listFieldNames(str,
                 model,
                 horizontal,
                 indent,
                 quoted,
                 withDefaults,
                 withNimTypes,
                 skipNimTypeOptionsForFields,
                 addNimTypeOptionsForFields,
                 withStringTypes,
                 fields)


proc listQuestionMarks*(
       str: var string,
       qLen: int) =

  var first = true

  for field in 0 .. qLen - 1:

    if first == false:
      str &= ", "
    else:
      first = false

    str &= "?"


proc getAllSelectFields*(model: Model): seq[string] =

  var
    i = 0
    curSelectFields = ""
    firstSelectField = true
    selectFields: seq[string]

  for field in model.fields:

    if firstSelectField == false:
      curSelectFields &= ", "
    else:
      firstSelectField = false

    curSelectFields &= field.nameInSnakeCase

    if len(curSelectFields) > 80:

      # Add a final comma if there are more fields to add
      if i < len(model.fields) - 1:
        curSelectFields &= ","

      selectFields.add(curSelectFields)

      curSelectFields = ""
      firstSelectField = true

    i += 1

  if curSelectFields != "":
    selectFields.add(curSelectFields)

  return selectFields


proc getWherePredicates*(
       whereFields: seq[string],
       model: Model): seq[string] =

  # Generate where predicates
  var wherePredicates: seq[string]

  for whereField in whereFields:

    let field = getFieldByName(whereField,
                               model)

    wherePredicates.add(&"{field.nameInSnakeCase} = ?")

  return wherePredicates


proc initType*(str: var string,
               indent: string,
               model: Model) =

  str &= &"{indent}var {model.nameInCamelCase} = {model.nameInPascalCase}()\n" &
         &"\n"


proc orderByClause*(str: var string,
                    query: string) =

  str &= &"  if len(orderByFields) > 0:\n" &
         &"    {query} &= \" order by \" & orderByFields.join(\", \")\n"


proc selectCountQuery*(str: var string,
                       model: Model) =

  # Create select SQL statement
  str &= &"  var selectStatement =\n" &
         &"    \"select count(1)\" & \n" &
         &"    \"  from {model.baseNameInSnakeCase}\""


proc selectQuery*(str: var string,
                  selectFields: seq[string],
                  whereFields: seq[string],
                  model: Model) =

  var selectFinalFields: seq[string]

  # Get select fields
  if len(selectFields) > 0:

    if (selectFields[0]) == "1":
      selectFinalFields = selectFields
    else:
      selectFinalFields =
        getFieldNamesInSnakeCase(
          selectFields,
          model)

  else:
    selectFinalFields = getAllSelectFields(model)

  debug "selectQuery()",
    selectFinalFields = selectFinalFields

  # Get where predicates
  let wherePredicates =
        getWherePredicates(
          whereFields,
          model)

  # Create select SQL statement
  str &= &"  var selectStatement =\n" &
         &"    \"select {selectFinalFields[0]}\" & \n"

  for i in 1 .. len(selectFinalFields) - 1:
    str &= &"    \"       {selectFinalFields[i]}\" &\n"

  str &= &"    \"  from {model.baseNameInSnakeCase}\""

  if len(whereFields) == 0:
    str &= "\n"
  else:
    str &= &" &\n" &
           &"    \" where {wherePredicates[0]}\""

  for i in 1 .. len(wherePredicates) - 1:
    str &= &" &\n"
    str &= &"    \"   and {wherePredicates[i]}\""

  if len(wherePredicates) > 0:
    str &= "\n"


proc setClauseByCustomFields*(
       str: var string,
       fields: seq[string]) =

  str &= &"    \"   set "

  var first = true

  for field in fields:

    if first == false:
      str &= &",\n                 \""
    else:
      first = false

    str &= &"{field} = ?\" &"

  str &= "\n"


proc setClause*(str: var string,
                queryType: string,
                model: Model) =

  str &= &"    \"   set \"\n" &
         "\n" &
         &"  for field in setFields:\n" &
         &"\n"

  # Set field as specified
  var first = true

  for field in model.fields:

    var
      el = ""
      getOption = ""
      option = false

    if first == false:
      el = "el"
    else:
      first = false

    let fieldNimType = getNimType(
                         field,
                         withOption = false)

    if not field.constraints.contains("not null"):
      getOption = ".get"
      option = true

    str &= &"    {el}if field == \"{field.nameInSnakeCase}\":\n"

    var valueToAdd = ""

    if @[ "bool[]",
          "char[]",
          "float[]",
          "float64[]",
          "int[]",
          "int64[]" ].contains(field.`type`):
      valueToAdd = &"getSeqNonStringAsPgArrayString({model.nameInSnakeCase}.{field.nameInSnakeCase}{getOption})"

    elif field.`type` == "string[]":
      valueToAdd = &"getSeqStringAsPgArrayString({model.nameInSnakeCase}.{field.nameInSnakeCase}{getOption})"

    else:
      valueToAdd = &"${model.nameInCamelCase}.{field.nameInCamelCase}{getOption}"

    if option == false:
      str &= &"      {queryType}Statement &= \"       {field.nameInSnakeCase} = ?,\"\n" &
             &"      {queryType}Values.add({valueToAdd})\n" &
             &"\n"
    else:
      str &= &"      if {model.nameInCamelCase}.{field.nameInCamelCase} != none({fieldNimType}):\n" &
             &"        {queryType}Statement &= \"       {field.nameInSnakeCase} = ?,\"\n" &
             &"        {queryType}Values.add({valueToAdd})\n" &
             &"      else:\n" &
             &"        {queryType}Statement &= \"       {field.nameInSnakeCase} = null,\"\n" &
             &"\n"

  # Remove last ,
  str &= &"  {queryType}Statement[len({queryType}Statement) - 1] = ' '\n"

  # New line
  str &= "\n"


proc setTypeFromFields*(
       str: var string,
       model: Model,
       indent: string) =

  # Copy fields to type
  str &= &"{indent}# Copy all fields as strings\n"

  for field in model.fields:

    #  Skip PK (handled separately)
    if model.pkFields.contains(field.name):
      continue

    str &= &"{indent}{model.nameInCamelCase}.{field.nameInCamelCase} = " &
           &"{field.nameInCamelCase}\n"

  str &= "\n"


proc updateCallClause*(
       str: var string,
       procName: string,
       queryType: string,
       model: Model) =

  str &= &"  var\n" &
         &"    {queryType}Statement: string\n" &
         &"    {queryType}Values: seq[string]\n" &
         "\n" &
         &"  {procName}SetClause(\n" &
         &"    {model.nameInSnakeCase},\n" &
         &"    setFields,\n" &
         &"    {queryType}Statement,\n" &
         &"    {queryType}Values)\n" &
         &"\n"


proc whereClause*(str: var string,
                  query: string) =

  str &= &"  if whereClause != \"\":\n" &
         &"    {query} &= \" where \" & whereClause\n" &
         &"\n"


proc whereEqOnlyClause*(
       str: var string,
       query: string) =

  str &= &"  for whereField in whereFields:\n" &
         "\n" &
         &"    var whereClause: string\n" &
         "\n" &
         &"    if first == false:\n" &
         &"      whereClause = \"   and \" & whereField & \" = ?\"\n" &
         &"    else:\n" &
         &"      first = false\n" &
         &"      whereClause = \" where \" & whereField & \" = ?\"\n" &
         "\n" &
         &"    {query} &= whereClause\n" &
         &"\n"


proc whereClauseByCustomFields*(
       str: var string,
       fields: seq[string]) =

  str &= &"    \" where "

  var first = true

  for field in fields:

    if first == false:
      str &= &",\n                 \""
    else:
      first = false

    str &= &"{field} = ?\""

  str &= "\n" &
         &"\n"


proc wherePKClause*(str: var string,
                    whereStr: string,
                    queryType: string,
                    model: Model) =

  # Build SQL where clause
  var first = true

  for pkFieldName in model.pkFields:

    let field = getFieldByName(pkFieldName,
                               model)

    if first == false:
      str &= &"  {whereStr} &= \"   and {field.nameInSnakeCase} = ?\"\n"
    else:
      first = false
      str &= &"  {whereStr} &= \" where {field.nameInSnakeCase} = ?\"\n"

  str &= "\n"

  # Add values
  for pkFieldName in model.pkFields:

    let field = getFieldByName(pkFieldName,
                               model)

    str &= &"  {queryType}Values.add(${model.nameInCamelCase}.{field.nameInCamelCase})\n"

  str &= "\n"

