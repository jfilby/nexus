import chronicles, sets, strformat, strutils
import nexus/cmd/types/types
import data_access_helpers
import data_access_procs
import data_access_custom_procs


# Code
proc generateDataAccessFile*(
       model: var Model,
       dataAccessFilename: string) =

  debug "generateDataAccessFile()",
    dataAccessFilename = dataAccessFilename,
    modelPkName = model.pkName,
    modelUniqueFieldSets = model.uniqueFieldSets

  var
    str = ""
    pgTryInsertId = false

  let pragmas = "{.gcsafe.}"

  str &= &"# Forward declarations\n"

  rowToModelTypeDecl(
    str,
    model,
    pragmas)

  str &= "\n" &
         "\n" &
         "# Code\n"

  # Count
  countProc(str,
            model,
            pragmas)

  str &= "\n"

  # Count where clause
  countWhereClauseProc(
    str,
    model,
    pragmas)

  str &= "\n"

  # Create (without record type)
  createProc(str,
             pgTryInsertId,
             model,
             pragmas)

  str &= "\n"

  # Create (with record type)
  createWithTypeProc(
    str,
    model,
    pragmas)

  str &= "\n"

  # Delete by PK
  if deleteProcByPk(
       str,
       model,
       model.pkFields,
       pragmas = pragmas) == true:

    str &= "\n"

  # Delete by where clause
  deleteWhereClauseProc(
    str,
    model,
    pragmas = pragmas)

  str &= "\n"

  # Delete where eq only
  deleteWhereEqOnlyProc(
    str,
    model,
    pragmas)

  str &= "\n"

  # Exists check by PK
  if existsProc(str,
                model,
                model.pkFields,
                pragmas = pragmas) == true:

    str &= "\n"

  # Exists check for unique field sets
  for uniqueFields in model.uniqueFieldSets:

    if existsProc(str,
                  model,
                  uniqueFields.fields,
                  pragmas = pragmas) == true:

      str &= "\n"

  # Filter
  filterProc(str,
             model,
             pragmas)

  str &= "\n"

  # Filter
  filterWhereEqOnlyProc(
    str,
    model,
    pragmas)

  str &= "\n"

  # Get for PK
  if getProc(str,
             model,
             model.pkFields,
             pragmas = pragmas) == true:

    str &= "\n"

  if model.pkNimType != "string":

    # Count to see if there are any non-string types
    let nonStringCount =
          countFieldNames(
            model,
            countNonStringTypes = true,
            countStringTypes = false,
            model.pkFields)

    if nonStringCount > 0:

      # Get for PK that has parameters as string types only
      # The Nim types is generated by default (above)
      if getProc(str,
                 model,
                 model.pkFields,
                 withStringTypes = true,
                 pragmas) == true:

        str &= "\n"

  # Get for unique field sets
  for uniqueFields in model.uniqueFieldSets:

    if getProc(str,
               model,
               uniqueFields.fields,
               pragmas = pragmas) == true:

      str &= "\n"

  # Get custom procs
  for getFunction in model.getFunctions:

    getCustomProc(str,
                  getFunction,
                  model)

    str &= "\n"

  # Get or Insert by PK (if the PK isn't auto-generated)
  if not model.fields[0].constraints.contains("auto-value"):

    if getOrCreateProc(str,
                       model,
                       model.pkFields,
                       pragmas) == true:

      str &= "\n"

  # Get or Insert for unique field sets
  for uniqueFields in model.uniqueFieldSets:

    if getOrCreateProc(str,
                       model,
                       uniqueFields.fields,
                       pragmas) == true:

      str &= "\n"

  # Row to model type
  rowToModelType(str,
                 model,
                 pragmas)

  str &= "\n"

  # Truncate
  truncate(str,
           model,
           pragmas)

  str &= "\n"

  # Update set caluse
  updateSetClause(str,
                  model,
                  pragmas)

  str &= "\n"

  # Update
  if model.pkSnakeCaseName != "":

    if updateByPKProc(str,
                      model,
                      pragmas) == true:

      str &= "\n"

  # Update where clause
  updateWhereClauseProc(
    str,
    model,
    pragmas)

  str &= "\n"

  # Update where eq only
  updateWhereEqOnlyProc(
    str,
    model,
    pragmas)

  str &= "\n"

  # Get custom procs
  var i = 0

  for updateFunction in model.updateFunctions:

    updateCustomProc(str,
                     updateFunction,
                     model)

    i += 1

    if i < len(model.updateFunctions):
      str &= "\n"

  # Prepend the imports block
  var
    stdlib_seq: seq[string]
    stdlibImports = toOrderedSet( @[ "db_postgres",
                                     "options",
                                     "sequtils",
                                     "strutils",
                                     "times" ])

  for module in stdlibImports:

    stdlibImports.incl(module)

  for module in model.nimTypeModules:

    stdlibImports.incl(module)

  for module in stdlibImports:

    stdlib_seq.add(module)

  var importsStr =
        &"# Nexus generated file\n" &
        &"import " & join(stdlib_seq, ", ") & "\n" &
        &"import nexus/core/data_access/data_utils\n"

  if pg_try_insertId == true:
    importsStr &= "import nexus/core/data_access/pg_try_insert_id\n"

  importsStr &= &"import {model.module.importPath}/types/model_types\n" &
                &"\n\n"

  str = importsStr & str

  # Write data access file
  echo ".. writing: " & dataAccessFilename

  writeFile(dataAccessFilename,
            str)

