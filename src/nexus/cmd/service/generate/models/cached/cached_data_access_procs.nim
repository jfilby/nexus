import chronicles, strformat
import nexus/cmd/service/generate/models/gen_model_utils
import nexus/cmd/service/generate/models/uncached/call_data_access_procs
import nexus/cmd/service/generate/models/drivers/stdlib_dbi/data_access_helpers
import nexus/cmd/types/types
import cached_data_access_helpers


# Code
proc cachedCreateWithTypeProc*(
       str: var string,
       model: Model,
       pragmas: string) =

  # Proc name
  var procName = "cachedCreate"

  if model.longNames == true:
    procName &= model.nameInPascalCase

  # Proc definition
  str &= &"proc {procName}*(\n" &
         &"       dbContext: var {model.module.nameInPascalCase}DbContext,\n"

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
          model.nameInPascalCase,
          pragmas)

  str &= &"){returnDetails} =\n" &
          "\n"

  # Call createProc()
  callCreateProc(str,
                 model)

  # Add to cache
  addModelRowToCache(str,
                     model)

  # Clear filter cache
  clearFilterCache(str,
                   model)

  str &= &"  return {model.nameInCamelCase}\n" &
          "\n"


proc cachedDeleteProc*(
       str: var string,
       model: Model,
       uniqueFields: seq[string],
       withStringTypes: bool = false,
       pragmas: string) =

  debug "cachedDeleteProc()",
    uniqueFields = uniqueFields

  let
    uniqueFieldsWithPkName =
      getFieldsWithPkNamed(
        uniqueFields,
        model)

    uniqueFieldsPascalCaseCase =
      getFieldsAsPascalCaseCase(
        uniqueFieldsWithPkName,
        model)

  # Proc name
  var procName = "cachedDelete"

  if model.longNames == true:
    procName &= model.nameInPascalCase

  if uniqueFields == model.pkFields:
    procName &= "ByPk"

  else:
    procName &= "By" & uniqueFieldsPascalCaseCase

  # Proc definition
  str &= &"proc {procName}*(\n" &
         &"       dbContext: var {model.module.nameInPascalCase}DbContext,\n"

  listFieldNames(str,
                 model,
                 indent = "       ",
                 withNimTypes = true,
                 listFields = uniqueFields)

  let returnDetails =
        getProcPostDetails(
          "int64",
          pragmas)

  str &= &"){returnDetails} =\n" &
          "\n"

  # Call createProc()
  callDeleteProc(str,
                 model,
                 uniqueFields,
                 uniqueFieldsPascalCaseCase,
                 withStringTypes)

  # Remove from cache
  removeModelRowFromCache(str,
                          model)

  # Clear filter cache
  clearFilterCache(str,
                   model)

  str &= &"  return rowsDeleted\n" &
          "\n"


proc cachedExistsProc*(
       str: var string,
       model: Model,
       uniqueFields: seq[string],
       withStringTypes: bool = false,
       pragmas: string) =

  debug "cachedExistsProc()",
    uniqueFields = uniqueFields

  let
    uniqueFieldsWithPkName =
      getFieldsWithPkNamed(
        uniqueFields,
        model)

    uniqueFieldsPascalCaseCase =
      getFieldsAsPascalCaseCase(
        uniqueFieldsWithPkName,
        model)

  # Proc name
  var procName = "cachedExists"

  if model.longNames == true:
    procName &= model.nameInPascalCase

  if uniqueFields == model.pkFields:
    procName &= "ByPk"

  else:
    procName &= "By" & uniqueFieldsPascalCaseCase

  # Proc definition
  str &= &"proc {procName}*(\n" &
         &"       dbContext: var " &
           &"{model.module.nameInPascalCase}DbContext,\n"

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

  # Return if in cache
  if uniqueFields == model.pkFields:
    existsModelRowInCacheByPk(
      str,
      model)

  else:
    existsModelRowInCacheByUniqueFields(
      str,
      model,
      uniqueFields)

  # Call existsProc()
  callExistsProc(str,
                 model,
                 uniqueFields,
                 uniqueFieldsPascalCaseCase,
                 withStringTypes)


proc cachedFilterProc*(
       str: var string,
       model: Model,
       pragmas: string) =

  # Proc name
  var procName = "cachedFilter"

  if model.longNames == true:
    procName &= model.nameInPascalCase

  # Proc definition
  let returnDetails =
        getProcPostDetails(
          model.namePluralInPascalCase,
          pragmas)

  str &= &"proc {procName}*(\n" &
         &"       dbContext: var {model.module.nameInPascalCase}DbContext,\n" &
          "       whereClause: string = \"\",\n" &
          "       whereValues: seq[string] = @[],\n" &
          "       orderByFields: seq[string] = @[],\n" &
         &"       limit: Option[int] = none(int)){returnDetails} =\n" &
          "\n"

  # Return if in cache
  filterModelGetRowsInCacheWithWhereClause(
    str,
    model)

  # Call callFilterWithWhereClauseProc()
  callFilterWithWhereClauseProc(
    str,
    model)

  # Extract PKs for caching
  filterModelGetPksFromResults(
    str,
    model)

  # Add to cache
  filterModelSetRowsInCacheWithWhereClause(
    str,
    model)

  # Return results
  str &= &"  return {model.namePluralInCamelCase}\n" &
          "\n"


proc cachedFilterWhereEqOnlyProc*(
       str: var string,
       model: Model,
       pragmas: string) =

  # Proc name
  var procName = "cachedFilter"

  if model.longNames == true:
    procName &= model.nameInPascalCase

  # Proc definition
  let returnDetails =
        getProcPostDetails(
          model.namePluralInPascalCase,
          pragmas)

  str &= &"proc {procName}*(\n" &
         &"       dbContext: var {model.module.nameInPascalCase}DbContext,\n" &
          "       whereFields: seq[string],\n" &
          "       whereValues: seq[string] = @[],\n" &
          "       orderByFields: seq[string] = @[],\n" &
         &"       limit: Option[int] = none(int)){returnDetails} =\n" &
          "\n"

  # Return if in cache
  filterModelGetRowsInCacheWithWhereFields(
    str,
    model)

  # Call callFilterWithWhereClauseProc()
  callFilterWithWhereFieldsProc(
    str,
    model)

  # Extract PKs for caching
  filterModelGetPksFromResults(
    str,
    model)

  # Add to cache
  filterModelSetRowsInCacheWithWhereFields(
    str,
    model)

  # Return results
  str &= &"  return {model.namePluralInCamelCase}\n" &
          "\n"


proc cachedGetProc*(
       str: var string,
       model: Model,
       uniqueFields: seq[string],
       withStringTypes: bool = false,
       pragmas: string) =

  debug "cachedGetProc()",
    uniqueFields = uniqueFields

  let
    uniqueFieldsWithPkName =
      getFieldsWithPkNamed(
        uniqueFields,
        model)

    uniqueFieldsPascalCaseCase =
      getFieldsAsPascalCaseCase(
        uniqueFieldsWithPkName,
        model)

  # Proc name
  var procName = "cachedGet"

  if model.longNames == true:
    procName &= model.nameInPascalCase

  if uniqueFields == model.pkFields:
    procName &= "ByPk"

  else:
    procName &= "By" & uniqueFieldsPascalCaseCase

  # Proc definition
  str &= &"proc {procName}*(\n" &
         &"       dbContext: var {model.module.nameInPascalCase}DbContext,\n"

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
          &"Option[{model.nameInPascalCase}]",
          pragmas)

  str &= &"){returnDetails} =\n" &
          "\n"

  # Return if in cache
  if uniqueFields == model.pkFields:
    getModelRowInCacheByPk(
      str,
      model,
      withOption = true)

  else:
    getModelRowInCacheByUniqueFields(
      str,
      model,
      uniqueFields,
      withOption = true)

  # Call getProc()
  callGetProc(str,
              model,
              uniqueFields,
              uniqueFieldsPascalCaseCase,
              withStringTypes)

  # Add to cache
  addModelRowToCache(
    str,
    model,
    # withModel = false,
    withOption = true)

  # Return
  str &= &"  return {model.nameInCamelCase}\n" &
         &"\n"


proc cachedGetOrCreateProc*(
       str: var string,
       model: Model,
       uniqueFields: seq[string],
       pragmas: string) =

  debug "cachedGetOrCreateProc()",
    uniqueFields = uniqueFields

  let
    uniqueFieldsWithPkName =
      getFieldsWithPkNamed(
        uniqueFields,
        model)

    uniqueFieldsPascalCaseCase =
      getFieldsAsPascalCaseCase(
        uniqueFieldsWithPkName,
        model)

  # Proc name
  var procName = "cachedGetOrCreate"

  if model.longNames == true:
    procName &= model.nameInPascalCase

  if uniqueFields == model.pkFields:
    procName &= "ByPk"

  else:
    procName &= "By" & uniqueFieldsPascalCaseCase

  # Proc definition
  str &= &"proc {procName}*(\n" &
         &"       dbContext: var {model.module.nameInPascalCase}DbContext,\n"

  listModelFieldNames(
    str,
    model,
    indent = "       ",
    skipAutoValue = true,
    withNimTypes = true)

  let returnDetails =
        getProcPostDetails(
          model.nameInPascalCase,
          pragmas)

  str &= &"){returnDetails} =\n" &
          "\n"

  # Return if in cache
  if uniqueFields == model.pkFields:
    getModelRowInCacheByPk(
      str,
      model,
      withOption = false)

  else:
    getModelRowInCacheByUniqueFields(
      str,
      model,
      uniqueFields,
      withOption = false)

  # Call getOrCreate() proc
  if uniqueFields == model.pkFields:

    callGetOrCreateProcByPk(
      str,
      model,
      uniqueFields)

  else:
    callGetOrCreateProcByUniqueFields(
      str,
      model,
      uniqueFields,
      uniqueFieldsPascalCaseCase)

  # Add to cache
  addIfNotExistModelRowToCache(
    str,
    model)

  str &= &"  return {model.nameInCamelCase}\n" &
          "\n"


proc cachedUpdateByPkProc*(
       str: var string,
       model: Model,
       pragmas: string) =

  # Proc name
  var procName = "cachedUpdate"

  if model.longNames == true:
    procName &= model.nameInPascalCase

  # Proc definition
  let returnDetails =
        getProcPostDetails(
          "int64",
          pragmas)

  str &= &"proc {procName}ByPk*(\n" &
         &"       dbContext: var {model.module.nameInPascalCase}DbContext,\n" &
         &"       {model.nameInCamelCase}: {model.nameInPascalCase},\n" &
         &"       setFields: seq[string]){returnDetails} =\n" &
          "\n"

  # Update call clause
  callUpdateProc(str,
                 model)

  # Add to cache
  addModelRowToCache(str,
                     model)

  # Clear filter cache
  clearFilterCache(str,
                   model)

  # Return rows updated
  str &= &"  return rowsUpdated\n" &
          "\n"

