import strformat, strutils
import nexus/core/service/format/type_utils
import nexus/cmd/types/types
import data_access_helpers


proc callCreateProc*(
       str: var string,
       model: Model) =

  str &= &"  # Call the create proc\n"

  var procName = "create"

  if model.longNames == true:
    procName &= model.nameInPascalCase

  # Proc definition
  let
    proc_line = &"  let {model.nameInCamelCase} = {procName}({model.module.nameInCamelCase}Module,\n"
    indentLen = find(proc_line, '(') + 1
    indent = getIndentByLen(indentLen)

  str &= proc_line

  listModelFieldNames(str,
                      model,
                      indent = indent,
                      skipAutoValue = true,
                      withDefaults = true,
                      withNimTypes = false)

  str &= &")\n" &
         &"\n"


proc callDeleteProc*(
       str: var string,
       model: Model,
       uniqueFields: seq[string],
       uniqueFieldsPascalCaseCase: string,
       withStringTypes: bool = false) =

  str &= &"  # Call the model's delete proc\n"

  # Get procName
  var procName = "delete"

  if model.longNames == true:
    procName &= model.nameInPascalCase

  if uniqueFields == model.pkFields:
    procName &= "ByPK"

  else:
    procName &= "By" & uniqueFieldsPascalCaseCase

  # Proc definition
  let
    proc_line = &"  let rows_deleted = {procName}({model.module.nameInCamelCase}Module,\n"
    indentLen = find(proc_line, '(') + 1
    indent = getIndentByLen(indentLen)

  str &= proc_line

  if withStringTypes == false:
    listFieldNames(str,
                   model,
                   indent = indent,
                   withNimTypes = false,
                   listFields = uniqueFields)

  else:
    listFieldNames(str,
                   model,
                   indent = indent,
                   withStringTypes = false,
                   listFields = uniqueFields)

  str &= &")\n" &
         &"\n"


proc callExistsProc*(
       str: var string,
       model: Model,
       uniqueFields: seq[string],
       uniqueFieldsPascalCaseCase: string,
       withStringTypes: bool = false) =

  str &= &"  # Call the model's exists proc\n"

  # Get procName
  var procName = "exists"

  if model.longNames == true:
    procName &= model.nameInPascalCase

  if uniqueFields == model.pkFields:
    procName &= "ByPK"

  else:
    procName &= "By" & uniqueFieldsPascalCaseCase

  # Proc definition
  let
    proc_line = &"  return {procName}({model.module.nameInCamelCase}Module,\n"
    indentLen = find(proc_line, '(') + 1
    indent = getIndentByLen(indentLen)

  str &= proc_line

  if withStringTypes == false:
    listFieldNames(str,
                   model,
                   indent = indent,
                   withNimTypes = false,
                   listFields = uniqueFields)

  else:
    listFieldNames(str,
                   model,
                   indent = indent,
                   withStringTypes = false,
                   listFields = uniqueFields)

  str &= &")\n" &
         &"\n"


proc callFilterWithWhereClauseProc*(
       str: var string,
       model: Model) =

  str &= &"  # Call the model's filter proc\n"

  var procName = "filter"

  if model.longNames == true:
    procName &= model.nameInPascalCase

  # Proc definition
  let
    proc_line = &"  let {model.namePluralInCamelCase} = {procName}({model.module.nameInCamelCase}Module,\n"
    indentLen = find(proc_line, '(') + 1
    indent = getIndentByLen(indentLen)

  str &= proc_line &
         &"{indent}whereClause,\n" &
         &"{indent}whereValues,\n" &
         &"{indent}orderByFields)\n" &
         &"\n"


proc callFilterWithWhereFieldsProc*(
       str: var string,
       model: Model) =

  str &= &"  # Call the model's filter proc\n"

  var procName = "filter"

  if model.longNames == true:
    procName &= model.nameInPascalCase

  # Proc definition
  let
    proc_line = &"  let {model.namePluralInSnakeCase} = {procName}({model.module.nameInSnakeCase}Module,\n"
    indentLen = find(proc_line, '(') + 1
    indent = getIndentByLen(indentLen)

  str &= proc_line &
         &"{indent}whereFields,\n" &
         &"{indent}whereValues,\n" &
         &"{indent}orderByFields)\n" &
         &"\n"


proc callGetProc*(
       str: var string,
       model: Model,
       uniqueFields: seq[string],
       uniqueFieldsPascalCaseCase: string,
       withStringTypes: bool = false) =

  str &= &"  # Call the model's get proc\n"

  # Get procName
  var procName = "get"

  if model.longNames == true:
    procName &= model.nameInPascalCase

  if uniqueFields == model.pkFields:
    procName &= "ByPK"

  else:
    procName &= "By" & uniqueFieldsPascalCaseCase

  # Proc definition
  let
    proc_line = &"  let {model.nameInCamelCase} = {procName}({model.module.nameInCamelCase}Module,\n"
    indentLen = find(proc_line, '(') + 1
    indent = getIndentByLen(indentLen)

  str &= proc_line

  if withStringTypes == false:
    listFieldNames(str,
                   model,
                   indent = indent,
                   withNimTypes = false,
                   listFields = uniqueFields)

  else:
    listFieldNames(str,
                   model,
                   indent = indent,
                   withStringTypes = false,
                   listFields = uniqueFields)

  str &= &")\n" &
         &"\n"


proc callGetOrCreateProcByPK*(
       str: var string,
       model: Model,
       uniqueFields: seq[string]) =

  var procName = "getOrCreate"

  if model.longNames == true:
    procName &= model.nameInPascalCase

  # Proc definition
  str &= &"  let {model.nameInCamelCase} = {procName}ByPK(\n"

  listModelFieldNames(str,
                      model,
                      indent = "       ",
                      skipAutoValue = true,
                      withNimTypes = false)

  str &= &")\n" &
         &"\n"


proc callGetOrCreateProcByUniqueFields*(
       str: var string,
       model: Model,
       uniqueFields: seq[string],
       uniqueFieldsPascalCaseCase: string) =

  var procName = "getOrCreate"

  if model.longNames == true:
    procName &= model.nameInPascalCase

  # Proc definition
  let
    uniqueFieldsPascalCaseCase =
      getFieldsAsPascalCaseCase(
        uniqueFields,
        model)

    proc_line = &"  let {model.nameInCamelCase} = {procName}By{uniqueFieldsPascalCaseCase}(" &
                &"{model.module.nameInCamelCase}Module,\n"
    indentLen = find(proc_line, '(') + 1
    indent = getIndentByLen(indentLen)

  str &= proc_line

  listModelFieldNames(str,
                      model,
                      indent = indent,
                      skipAutoValue = true,
                      withNimTypes = false)

  str &= &")\n" &
         &"\n"


proc callUpdateProc*(
       str: var string,
       model: Model) =

  str &= &"  # Call the model's update proc\n"

  var procName = "update"

  if model.longNames == true:
    procName &= model.nameInPascalCase

  procName &= "ByPK"

  # Proc definition
  let
    proc_line = &"  let rowsUpdated = {procName}({model.module.nameInCamelCase}Module,\n"
    indentLen = find(proc_line, '(') + 1
    indent = getIndentByLen(indentLen)

  str &= proc_line &
         &"{indent}{model.nameInCamelCase},\n" &
         &"{indent}setFields)\n" &
         &"\n"
