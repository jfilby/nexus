import chronicles, options, strformat, strutils
import nexus/cmd/types/types


# Forward declarations
proc getModelByName*(
       modelName: string,
       generatorInfo: GeneratorInfo): (Model, bool)
proc resolveDataValue(
       str: string,
       models: Models): string


# Code
proc getDefaultValueAsNimValue*(
       model: Model,
       field: Field): Option[string] =

  for default in model.defaults:

    if default.field == field.name:

      if field.`type` == "bool":
        if @[ 'Y', 'y' ].contains(default.default[0]):
          return some("true")
        else:
          return some("false")

      elif field.`type` == "char":
        return some(&"'{default.default[0]}'")

      elif field.`type` == "datetime":
        if default.default == "now":
          return some(&"{default.default}()")

      elif field.`type` == "int":
        return some(&"{default.default}")

      elif field.`type` == "int64":
        return some(&"{default.default}")

      elif field.`type` == "string":
        return some(&"\"{default.default}\"")

      else:
        raise newException(
                ValueError,
                &"Field type: {field.`type`} not handled (fieldName: " &
                &"\"{field.name}\" for model: \"{model.name}\")")

  return none(string)


proc getDefaultValueAsString*(
       model: Model,
       field: Field): Option[string] =

  for default in model.defaults:

    if default.field == field.name:

      if field.`type` == "bool":
        if @[ 'Y', 'y' ].contains(default.default[0]):
          return some("true")
        else:
          return some("false")

      elif field.`type` == "char":
        return some(&"'{default.default[0]}'")

      elif field.`type` == "datetime":
        if default.default == "now":
          return some(&"{default.default}()")

      elif field.`type` == "int":
        return some(&"'parseInt({default.default})'")

      elif field.`type` == "int64":
        return some(&"'parseBiggestInt({default.default})'")

      elif field.`type` == "string":
        return some(&"\"{default.default}\"")

      else:
        raise newException(
                ValueError,
                &"Field type: {field.`type`} not handled (fieldName: " &
                &"\"{field.name}\" for model: \"{model.name}\")")

  return none(string)


proc getFieldByName*(fieldName: string,
                     model: Model): Field =

  debug "getFieldByName()",
    modelName = model.name,
    byFieldNameQuoted = &"\"{fieldName}\""

  for field in model.fields:

    debug "getFieldByName(): iter try match",
      tryfieldNameQuoted = &"\"{field.name}\"",
      result = (field.name == fieldName)

    # Identify a case insensitive match
    if fieldName != field.name and
       toLowerAscii(fieldName) == toLowerAscii(field.name):

      raise newException(
              ValueError,
              &"Field search for: \"{fieldName}\" has a case insensitive " &
              &"match for field: \"{field.name}\" on model: {model.name}.\n" &
              "Please fix the case to match exactly.")

    # Return on exact match
    if field.name == fieldName:
      return field

  # Field not found
  echo &"Error: Field not found by fieldName: \"{fieldName}\""

  quit(1)


proc getFieldBySnakeCaseName*(
       fieldSnakeCaseName: string,
       model: Model): Field =

  debug "getFieldBySnakeCaseName()",
    fieldSnakeCaseName = fieldSnakeCaseName

  # Find and return field
  for field in model.fields:

    debug "getFieldBySnakeCaseName()",
      fieldDSnakeCaseName = field.nameInSnakeCase

    if field.nameInSnakeCase == fieldSnakeCaseName:
      return field

  # Field not found
  echo &"Error: Field not found by fieldSnakeCaseName: " &
       &"\"{fieldSnakeCaseName}\" for model: \"{model.name}\""

  quit(1)


proc getFieldsAsSnakeCaseName*(
       fieldNames: seq[string],
       model: Model): seq[string] =

  var fieldSnakeCaseNames: seq[string]

  for fieldName in fieldNames:

    let field = getFieldByName(fieldName,
                               model)

    fieldSnakeCaseNames.add(field.nameInSnakeCase)

  return fieldSnakeCaseNames


proc getModelAndFieldByName*(
       name: string,
       generatorInfo: GeneratorInfo):
         (Model, bool, Field) =

  let
    dotPos = find(name, ".")
    modelName = name[0 .. dotPos - 1]
    fieldName = name[dotPos + 1 .. len(name) - 1]

  debug "getModelAndFieldByName()",
    modelName = modelName,
    fieldName = fieldName

  let
    (model,
     modelPlural) = getModelByName(modelName,
                                   generatorInfo)

  let field = getFieldByName(fieldName,
                             model)

  return (model,
          modelPlural,
          field)


proc getModelByName*(
       modelName: string,
       generatorInfo: GeneratorInfo):
         (Model, bool) =

  for model in generatorInfo.models:

    if model.name == modelName:
      return (model, false)

    if model.namePlural == modelName:
      return (model, true)

  # Model not found
  echo &"Error: Model not found by modelName: \"{modelName}\""

  quit(1)


# Returns: Model, isPlural
proc getModelBynameInPascalCase*(
       modelnameInPascalCase: string,
       generatorInfo: GeneratorInfo):
         (Model, bool) =

  for model in generatorInfo.models:

    if model.nameInPascalCase == modelnameInPascalCase:
      return (model, false)

    elif model.namePluralInPascalCase == modelnameInPascalCase:
      return (model, true)

  # Model not found
  echo  "Error: Model not found by modelnameInPascalCase: " &
       &"\"{modelnameInPascalCase}\""

  quit(1)


proc modelUsesArrayTypes*(model: Model): bool =

  for field in model.fields:

    if field.`type`[^2 .. ^1] == "[]":

      return true

  return false


proc modelUsesBoolTypes*(model: Model): bool =

  for field in model.fields:

    if @[ "bool",
          "bool[]" ].contains(field.`type`):

      return true

  return false


proc modelUsesCharTypes*(model: Model): bool =

  for field in model.fields:

    if @[ "char",
          "char[]" ].contains(field.`type`):

      return true

  return false


proc modelUsesDateTimeTypes*(model: Model): bool =

  for field in model.fields:

    if @[ "date",
          "date[]",
          "datetime",
          "datetime[]" ].contains(field.`type`):

      return true

  return false


proc modelUsesFloatTypes*(model: Model): bool =

  for field in model.fields:

    if @[ "float",
          "float[]" ].contains(field.`type`):

      return true

  return false


proc modelUsesJsonTypes*(model: Model): bool =

  for field in model.fields:

    if @[ "json",
          "json[]",
          "jsonb",
          "jsonb[]" ].contains(field.`type`):

      return true

  return false


proc modelUsesOptionalTypes*(model: Model): bool =

  for field in model.fields:

    if field.isRequired == false:
      return true

  return false


proc resolveDataString*(str: var string,
                        models: Models) =

  var openBrace = find(str, '{')

  while openBrace > 0:

    # Get string in braces
    let
      closeBrace = find(str, '}')
      braceValue = str[openBrace + 1 .. closeBrace - 1]
      dataValue = resolveDataValue(braceValue,
                                   models)

    debug "resolveDataString()",
      braceValue = braceValue,
      dataValue = dataValue

    str = replace(str,
                  "{" & braceValue & "}",
                  dataValue)

    # Get next open brace
    openBrace = find(str, '{')


proc resolveDataValue(str: string,
                      models: Models): string =

  # Look for a dot in the string (this indicates a model.field format)
  var dotPos = find(str, '.')

  if dotPos > 0:

    let
      modelName = str[0 .. dotPos - 1]
      fieldName = str[dotPos + 1 .. len(str) - 1]

    # Lookup model and field
    for model in models:

      if model.name == modelName:

        for field in model.fields:

          if field.name == fieldName:

            return model.nameInSnakeCase & "." & field.nameInSnakeCase

    # Field not found
    echo &"Error: Field not found: {fieldName} in string \"{str}\""

    quit(1)

