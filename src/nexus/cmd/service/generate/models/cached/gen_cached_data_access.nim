import chronicles, sets, strformat, strutils
import nexus/cmd/service/generate/models/model_utils
import nexus/cmd/types/types
import cached_data_access_procs
import cached_data_access_custom_procs


# Code
proc generateCachedDataAccessFile*(
       model: var Model,
       cachedDataAccessFilename: string) =

  debug "generateCachedDataAccessFile()",
    cachedDataAccessFilename = cachedDataAccessFilename,
    modelPkName = model.pkName,
    modelUniqueFieldSets = model.uniqueFieldSets

  # Generate the import block
  var
    stdlibs: seq[string]
    stdlibImports =
      toOrderedSet( @[ "options",
                       "strutils",
                       "tables" ])

  if modelUsesDateTimeTypes(model):
    stdlibImports.incl("times")

  for module in stdlibImports:

    stdlibImports.incl(module)

  for module in model.nimTypeModules:

    stdlibImports.incl(module)

  for module in stdlibImports:

    stdlibs.add(module)

  let modulePath =
        &"{model.module.package}/{model.module.shortNameInSnakeCase}"

  var str =  "# Nexus generated file\n" &
            &"import " & join(stdlibs, ", ") & "\n" &
            &"import {modulePath}/data_access/{model.nameInSnakeCase}_data\n" &
            &"import {modulePath}/types/model_types\n" &
             "\n" &
             "\n" &
             "# Code\n"

  let pragmas = "{.gcsafe.}"

  # Create (with record type)
  cachedCreateWithTypeProc(
    str,
    model,
    pragmas)

  str &= "\n"

  # Delete by PK
  cachedDeleteProc(
    str,
    model,
    model.pkFields,
    pragmas = pragmas)

  str &= "\n"

  # Exists check by PK
  cachedExistsProc(
    str,
    model,
    model.pkFields,
    pragmas = pragmas)

  str &= "\n"

  # Exists check for unique field sets
  for uniqueFields in model.uniqueFieldSets:

    cachedExistsProc(
      str,
      model,
      uniqueFields.fields,
      pragmas = pragmas)

    str &= "\n"

  # Filter
  cachedFilterProc(
    str,
    model,
    pragmas)

  str &= "\n"

  # Filter
  cachedFilterWhereEqOnlyProc(
    str,
    model,
    pragmas)

  str &= "\n"

  # Get for PK
  cachedGetProc(
    str,
    model,
    model.pkFields,
    pragmas = pragmas)

  str &= "\n"

  # Get for unique field sets
  for uniqueFields in model.uniqueFieldSets:

    cachedGetProc(
      str,
      model,
      uniqueFields.fields,
      pragmas = pragmas)

    str &= "\n"

  # Get custom procs
  for getFunction in model.getFunctions:

    cachedGetCustomProc(
      str,
      getFunction,
      model)

    str &= "\n"

  # Get or Insert by PK (if the PK isn't auto-generated)
  if model.fields[0].isAutoValue == false:

    cachedGetOrCreateProc(
      str,
      model,
      model.pkFields,
      pragmas)

    str &= "\n"

  # Get or Insert for unique field sets
  for uniqueFields in model.uniqueFieldSets:

    cachedGetOrCreateProc(
      str,
      model,
      uniqueFields.fields,
      pragmas)

    str &= "\n"

  # Update
  if model.pkNameInSnakeCase != "":
    cachedUpdateByPkProc(
      str,
      model,
      pragmas)

    str &= "\n"

  # Get custom procs
  var i = 0

  for updateFunction in model.updateFunctions:

    cachedUpdateCustomProc(
      str,
      updateFunction,
      model)

    i += 1

    if i < len(model.updateFunctions):
      str &= "\n"

  # Write data access file
  echo ".. writing: " & cachedDataAccessFilename

  writeFile(cachedDataAccessFilename,
            str)

