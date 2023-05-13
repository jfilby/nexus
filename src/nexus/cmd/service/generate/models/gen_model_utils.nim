import algorithm, chronicles, options, sets, strformat, strutils
import nexus/core/service/format/case_utils
import nexus/core/service/format/tokenize
import nexus/cmd/service/generate/modules/module_utils
import nexus/cmd/types/types
import model_utils


# Forward declarations
proc getModelFields*(fieldNames: seq[string],
                     model: Model): Fields
proc getNimType*(field: Field,
                 withOption: bool = true): string
proc getNimType*(fields: Fields,
                 withOption: bool = true): string
proc getPkFieldNames*(model: Model): seq[string]
proc setPartitioning(model: var Model)
proc tokenError(
      errorHeading: string,
      errorDetail: string)


# Code
proc getModel*(modelYaml: ModelYAML,
               generatorInfo: GeneratorInfo,
               isRef: bool): Model =

  debug "getModel()",
    modelName = model.name

  # Set moduleImport
  # warn "to do"

  # Get model/field names in varying formats
  var model = Model(isRef: isRef)

  # Verify
  if modelYaml.name == "":

    raise newException(ValueError,
                       "Model's name is blank in YAML")

  # Convert fields from ModelYAML to Model
  model.name = modelYaml.name
  model.description = modelYaml.description
  model.modelOptions = modelYaml.modelOptions
  model.tableOptions = modelYaml.tableOptions
  model.defaults = modelYaml.defaults
  model.pkFields = modelYaml.pkFields
  model.uniqueFieldSets = modelYaml.uniqueFieldSets
  model.getFunctions = modelYaml.getFunctions
  model.relationships = modelYaml.relationships
  model.updateFunctions = modelYaml.updateFunctions

  # Add the module field
  model.module =
    getModuleByName(
      modelYaml.module,
      generatorInfo)

  # Set additional fields
  model.longNames = true
  model.moduleImport = modelYaml.module

  var
    refPascalCaseSuffix = ""
    refSnakeCaseSuffix = ""

  if isRef == true:
    refPascalCaseSuffix = "Ref"
    refSnakeCaseSuffix = "_ref"

  model.refSuffixInSnakeCase = refSnakeCaseSuffix

  model.baseNameInCamelCase = inCamelCase(model.name)
  model.baseNameInPascalCase = inPascalCase(model.name)
  model.baseNameInSnakeCase = inSnakeCase(model.name)

  model.nameInCamelCase =
    &"{model.baseNameInCamelCase}{refPascalCaseSuffix}"

  model.nameInPascalCase =
    &"{model.baseNameInPascalCase}{refPascalCaseSuffix}"

  model.nameInSnakeCase =
    &"{model.baseNameInSnakeCase}{refSnakeCaseSuffix}"

  model.namePlural = &"{model.name}s"
  model.namePluralInCamelCase = &"{model.nameInCamelCase}s"
  model.namePluralInPascalCase = &"{model.nameInPascalCase}s"
  model.namePluralInSnakeCase = &"{model.nameInSnakeCase}s"

  # PK
  var pkIsSet = false

  for fieldYaml in modelYaml.fields:

    # Convert FieldYAML to Field
    var field = Field()

    field.name = fieldYaml.name
    field.`type` = fieldYaml.`type`
    field.constraints = fieldYaml.constraints

    # Verify type
    let fieldTypes = @[ "bool",
                        "char",
                        "char[]",
                        "date",
                        "date[]",
                        "datetime",
                        "datetime[]",
                        "float",
                        "float[]",
                        "int",
                        "int[]",
                        "int64",
                        "int64[]",
                        "json",
                        "jsonb",
                        "string",
                        "string[]" ]

    if @[ "float64",
          "float64[]" ].contains(field.`type`):

      raise newException(
              ValueError,
              "Don't use type float64, rather just use float, which will " &
              "automatically be 64-bit on a 64-bit machine")

    if not fieldTypes.contains(field.`type`):

      raise newException(ValueError,
                         &"Invalid type for model: \"{model.name}\" field: \"{field.name}\"; " &
                         &"type is \"{field.`type`}\" (type must be lowercase)")

    # Set isArray
    if field.`type`[^1] == ']':
      field.isArray = true

    else:
      field.isArray = false

    # Set isRequired
    if field.constraints.contains("not null"):
      field.isRequired = true

    else:
      field.isRequired = false

    # Set isAutoValue
    if field.constraints.contains("auto-value"):
      field.isAutoValue = true

    else:
      field.isAutoValue = false

    # Set additional fields
    field.nameInCamelCase = inCamelCase(field.name)
    field.nameInPascalCase = inPascalCase(field.name)
    field.nameInSnakeCase = inSnakeCase(field.name)

    debug "getModel()",
      fieldName = field.name,
      fieldSnakeCaseName = field.nameInSnakeCase

    model.fields.add(field)

  # Get Nim types for the model
  for field in model.fields:

    let nimType = getNimType(field,
                             withOption = false)

    model.nimTypes.incl(nimType)

  # Get the Nim modules required to work with the Nim types
  for nimType in model.nimTypes:

    case nimType:

      of "JsonNode":
        model.nimTypeModules.incl("json")

  # Attempt to retrieve PK
  var first = true
  model.pkModelDNamesInCamelCase = ""

  for field in model.pkFields:

    let
      fieldCamelCaseName = inCamelCase(field)
      fieldSnakeCaseName = inSnakeCase(field)

      modelField =
        getFieldBySnakeCaseName(
          fieldSnakeCaseName,
          model)

    if len(model.pkFields) == 1:
      pkIsSet = true

      model.pkName = field
      model.pkNameInSnakeCase = fieldSnakeCaseName
      model.pkNameInCamelCase = fieldCamelCaseName

      model.pkNimType = getNimType(modelField,
                                   withOption = true)

      # PK: model.field
      model.pkModelDNamesInCamelCase =
        &"{model.nameInCamelCase}.{fieldCamelCaseName}"

    elif len(model.pkFields) > 1:
      pkIsSet = true

      let pkFields = getModelFields(model.pkFields,
                                    model)

      model.pkName = model.pkFields.join(", ")

      if first == false:
        model.pkNameInSnakeCase &= ", "
        model.pkNameInCamelCase &= ", "
        model.pkModelDNamesInCamelCase &= ", "

      else:
        first = false

      model.pkNameInSnakeCase &= fieldSnakeCaseName
      model.pkNameInCamelCase &= fieldCamelCaseName
      model.pkModelDNamesInCamelCase &= &"{model.nameInCamelCase}.{fieldCamelCaseName}"

      model.pkNimType = getNimType(pkFields,
                                   withOption = true)

  # Brackets pkModelDNamesInCamelCase for multi-PK fields
  if len(model.pkFields) > 1:

    model.pkNameInSnakeCase = &"({model.pkNameInSnakeCase})"
    model.pkNameInCamelCase = &"({model.pkNameInCamelCase})"
    model.pkModelDNamesInCamelCase = &"({model.pkModelDNamesInCamelCase})"

  # Stop if PK is not set
  let modelRequiresPk = false

  if modelRequiresPk == true and
     pkIsSet == false:

    raise newException(ValueError,
                       &"PK not specified for model: {model.name}")

  # Add partitioning if specified
  setPartitioning(model)

  # Setup indexes
  for indexYaml in modelYaml.indexes:

    var index = Index()

    index.unique = indexYaml.unique

    for fieldName in indexYaml.fields:

      index.fields.add(getFieldByName(fieldName,
                                      model))

    model.indexes.add(index)

  debug "getModel()",
    lenModel_indexes = len(model.indexes)

  # Verification
  if model.baseNameInSnakeCase == "":

    raise newException(ValueError,
                       "model.baseNameInSnakeCase is blank")

  # Return model
  return model


proc generateNimTypeStringToStringLine(
       str: var string,
       stdlibImports: var OrderedSet[string],
       field: Field,
       toVar: string,
       fromVar: string,
       indent: string) =

  let withOption = not field.isRequired

  str &= &"{indent}if {fromVar} != \"\":\n"
  
  if withOption == true:
    str &= &"{indent}  {toVar} = some({fromVar})\n"

  else:
    str &= &"{indent}  {toVar} = {fromVar}\n"


proc generateNimTypeStringToRawLine(
       str: var string,
       stdlibImports: var OrderedSet[string],
       field: Field,
       toVar: string,
       fromVar: string,
       indent: string) =

  let withOption = not field.isRequired

  str &= &"{indent}if {fromVar} != \"\":\n"

  # Handle from/to string
  var strSuffix = ""

  if field.`type` != "string":
    strSuffix = "Str"

  if withOption == true and
     strSuffix == "":

    str &= &"{indent}  {toVar}{strSuffix} = some({fromVar})\n"

  else:
    str &= &"{indent}  {toVar}{strSuffix} = {fromVar}\n"

  # Handle from string/to raw type
  strSuffix = "Str"

  case field.`type`:

    of "bool":
      if withOption == true:
        str &= &"{indent}  {toVar} = some(parseBool({toVar}{strSuffix}))\n"
      else:
        str &= &"{indent}  {toVar} = parseBool({toVar}{strSuffix})\n"

    of "char":
      if withOption == true:
        str &= &"{indent}  {toVar} = some({toVar}{strSuffix}[0])\n"
      else:
        str &= &"{indent}  {toVar} = {toVar}{strSuffix}[0]\n"

    of "date":
      stdlibImports.incl("times")

      let dateFormat = "yyyy-MM-dd"

      if withOption == true:
        str &= &"{indent}  {toVar} = some(parse({toVar}{strSuffix}, \"{dateFormat}\"))\n"
      else:
        str &= &"{indent}  {toVar} = parse({toVar}{strSuffix}, \"{dateFormat}\")\n"

    of "datetime":
      stdlibImports.incl("times")

      let datetimeFormat = "yyyy-MM-dd HH:mm:ss"

      if withOption == true:
        str &= &"{indent}  {toVar} = some(parse({toVar}{strSuffix}, \"{datetimeFormat}\"))\n"
      else:
        str &= &"{indent}  {toVar} = parse({toVar}{strSuffix}, \"{datetimeFormat}\")\n"

    of "float":
      stdlibImports.incl("strutils")

      if withOption == true:
        str &= &"{indent}  {toVar} = some(parseFloat({toVar}{strSuffix}))\n"
      else:
        str &= &"{indent}  {toVar} = parseFloat({toVar}{strSuffix})\n"

    of "int":
      stdlibImports.incl("strutils")

      if withOption == true:
        str &= &"{indent}  {toVar} = some(parseInt({toVar}{strSuffix}))\n"
      else:
        str &= &"{indent}  {toVar} = parseInt({toVar}{strSuffix})\n"

    of "int64":
      stdlibImports.incl("strutils")

      if withOption == true:
        str &= &"{indent}  {toVar} = some(parseBiggestInt({toVar}{strSuffix}))\n"
      else:
        str &= &"{indent}  {toVar} = parseBiggestInt({toVar}{strSuffix})\n"

    of "json":
      stdlibImports.incl("json")

    of "jsonb":
      stdlibImports.incl("json")

    else:
      raise newException(ValueError,
                         &"Type not handled: {field.`type`}")


proc generateNimTypeStringToRaw*(
       str: var string,
       stdlibImports: var OrderedSet[string],
       field: Field,
       fromVar: string,
       toVar: string,
       indent: string) =

  stdlibImports.incl("options")

  if field.`type` == "string":
    generateNimTypeStringToStringLine(
      str,
      stdlibImports,
      field,
      toVar,
      fromVar,
      indent)

  else:
    generateNimTypeStringToRawLine(
      str,
      stdlibImports,
      field,
      toVar,
      fromVar,
      indent)


proc getConvertStringToNimTypeFunction*(field: Field): string =

  case field.`type`:

    of "char[]":
      return "getPgArrayStringAsSeqChar"

    of "bool":
      return "parsePgBool"

    of "float":
      return "parseFloat"

    of "float[]":
      return "getPgArrayStringAsSeqFloat"

    of "int":
      return "parseInt"

    of "int[]":
      return "getPgArrayStringAsSeqInt"

    of "int64":
      return "parseBiggestInt"

    of "int64[]":
      return "getPgArrayStringAsSeqInt64"

    of "json":
      return "parseJson"

    of "jsonb":
      return "parseJson"

    of "date":
      return "parsePgTimestamp"

    of "datetime":
      return "parsePgTimestamp"

    of "string[]":
      return "getPgArrayStringAsSeqString"

    else:
      return ""


proc getFieldNamesInSnakeCase*(
       modelFieldNames: seq[string],
       model: Model): seq[string] =

  var fieldNames: seq[string]

  for modelFieldName in modelFieldNames:
    for field in model.fields:

      if field.name == modelFieldName:

        fieldNames.add(field.nameInSnakeCase)

  return fieldNames


proc getFieldsWithPkActualName*(
       fields: seq[string],
       model: Model): seq[string] =

  # let pkFieldNames = getPkFieldNames(model)

  var returnFields: seq[string]

  for field in fields:

    if field == "primary key":

      for pkField in model.pkFields:
        returnFields.add(pkField)

    else:
      returnFields.add(field)

  return returnFields


proc getFieldsWithPkNamed*(
       fields: seq[string],
       model: Model): seq[string] =

  let pkField_names = getPkFieldNames(model)

  var returnFields: seq[string]

  for field in fields:

    if pkField_names.contains(field) or
       field == "primary key":

      returnFields.add("PK")

    else:
      returnFields.add(field)

  return returnFields


proc getModelFields*(fieldNames: seq[string],
                     model: Model): Fields =

  debug "getModelFields()",
    fieldNames = fieldNames

  var fields: Fields

  for fieldName in fieldNames:

    var field_found = false

    for field in model.fields:

      debug "getModelFields()",
        field_d_name = field.name,
        fieldName = fieldName

      if field.name == fieldName:
        field_found = true
        fields.add(field)

    if field_found == false:
        raise newException(ValueError,
                           &"field not found: {fieldName}")

  return fields


proc getModelFieldByName*(name: string,
                          model: Model): Field =

  for field in model.fields:

    if field.name == name:
      return field

  raise newException(ValueError,
                     &"name not found: {name}")


proc getModelImport*(model: Model,
                     generatorInfo: GeneratorInfo): string =

  if model.moduleImport == "":
    raise newException(ValueError,
                       &"moduleImport not set for model: {model.name}")

  let module = getModuleByName(model.moduleImport,
                               generatorInfo)

  return module.nameInSnakeCase & "/data_access/" & model.nameInSnakeCase & "_data"


proc getModelTypesImport*(
       model: Model,
       generatorInfo: GeneratorInfo): string =

  if model.moduleImport == "":
    raise newException(ValueError,
                       &"moduleImport not set for model: {model.name}")

  let module = getModuleByName(model.moduleImport,
                               generatorInfo)

  # Types import must be disambiguated using an alias.
  # Nim doesn't allow importing the same filename twice, even if they have
  # different import paths.
  return &"{module.nameInSnakeCase}/types/model_types as {model.nameInSnakeCase}" &
          "_types"


proc getModelTypeAsPgType*(
       fieldType: string,
       dmlInfo: bool = false): string =

  var pgType = toUpperAscii(fieldType)

  if fieldType == "date":
    pgType = "DATE"

  elif fieldType == "date[]":
    pgType = "DATE[]"

  elif fieldType == "datetime":
    pgType = "TIMESTAMP WITH TIME ZONE"

  elif fieldType == "datetime[]":
    pgType = "TIMESTAMP[] WITH TIME ZONE"

  elif fieldType == "int64":
    pgType = "BIGINT"

  elif fieldType == "int64[]":
    pgType = "BIGINT[]"

  elif fieldType == "json":
    pgType = "JSON"

  elif fieldType == "jsonb":
    pgType = "JSONB"

  elif fieldType == "string":
    pgType = "CHARACTER VARYING"

    if dmlInfo == true:
      pgType &= &" COLLATE pg_catalog.\"default\""

  elif fieldType == "string[]":
    pgType = "CHARACTER VARYING[]"

    if dmlInfo == true:
      pgType &= &" COLLATE pg_catalog.\"default\""

  return pgType


proc getNimType*(field: Field,
                 withOption: bool = true): string =

  var nimType = field.`type`

  # Translate model types to Nim types
  if field.`type` == "date" or
     field.`type` == "datetime":

    nimType = "DateTime"

  if field.`type` == "date[]" or
     field.`type` == "datetime[]":

    nimType = "seq[DateTime]"

  elif field.`type` == "char[]":
    nimType = "seq[char]"

  elif field.`type` == "float[]":
    nimType = "seq[float]"

  elif field.`type` == "int[]":
    nimType = "seq[int]"

  elif field.`type` == "int64[]":
    nimType = "seq[int64]"

  elif @[ "json",
          "jsonb" ].contains(field.`type`):
    nimType = "JsonNode"

  elif field.`type` == "string[]":
    nimType = "seq[string]"

  elif field.`type` == "uuid":
    nimType = "string"

  # Add option syntax
  if withOption == true and
     field.isRequired == false:
    nimType = "Option[" & nimType & "]"

  return nimType


proc getNimType*(fields: Fields,
                 withOption: bool = true): string =

  var
    first = true
    nimType = "("

  for field in fields:

    if first == false:
      nimType &= ", "
    else:
      first = false

    var nimFieldType = field.`type`

    # Translate model types to Nim types
    if field.`type` == "date" or
       field.`type` == "datetime":

      nimFieldType = "DateTime"

    elif field.`type` == "char[]":
      nimFieldType = "seq[char]"

    elif field.`type` == "float[]":
      nimFieldType = "seq[float]"

    elif field.`type` == "int[]":
      nimFieldType = "seq[int]"

    elif field.`type` == "int64[]":
      nimFieldType = "seq[int64]"

    elif @[ "json",
            "jsonb" ].contains(field.`type`):
      nimType = "JsonNode"

    elif field.`type` == "string[]":
      nimFieldType = "seq[string]"

    elif field.`type` == "uuid":
      nimFieldType = "string"

    # Add option syntax
    if withOption == true and
       field.isRequired == false:
      nimFieldType = "Option[" & nimFieldType & "]"

    nimType &= nimFieldType

  nimType &= ")"

  return nimType


proc getPkFieldNames*(model: Model): seq[string] =

  var pkFields: seq[string]

  for field in model.pkFields:

    pkFields.add(inSnakeCase(field))    

  return pkFields


proc getProcPostDetails*(
       returnType: string,
       pragmas: string,
       withColon: bool = true): string =

  var str = ""

  # If pragmas only then don't need a leading colon
  if returnType != "" and
     withColon == true:

    str &= ": "

  # Add return type
  if returnType != "":
    str &= returnType

    if pragmas != "":
      str &= " "

  # Add pragmas
  if pragmas != "":

    if str == "":
      str = " "

    str &= pragmas

  # Return
  return str


proc initModelTypesStr*(imports: var seq[string]): string =

  # Sort imports
  sort(imports)

  # Imports string (delimited with commas)
  var
    first = true
    importsStr = ""

  for `import` in imports:

    if first == false:
      importsStr &= ", "
    else:
      first = false

    importsStr &= `import`

  let str = &"# Nexus generated file\n" &
            &"import {importsStr}\n" &
            "\n" &
            &"\n"

  return str


proc setPartitioning(model: var Model) =

  # Get partitioning tokens
  var tokens: seq[string]

  for tableOption in model.tableOptions:

    if len(tableOption) > 9:
      if tableOption[0 .. 8] == "partition":
        tokens = tokenize(tableOption)

  if len(tokens) == 0:
    return

  # Parse partitioning tableOption
  let partitioningTableOptionError =
        &"Model: \"{model.name}\" partitioning tableOption error:\n"

  var partitionKeyFieldName: seq[string]

  if len(tokens) < 5:
    raise newException(
            ValueError,
            partitioningTableOptionError &
            &".. Insufficient tokens, only {len(tokens)} found")

  for i in 0 .. len(tokens) - 1:

    let token = tokens[i]

    if i == 0 and
       token != "partition":

      tokenError(
        partitioningTableOptionError,
        ".. \"partition\" not specified at token 1")

    elif i == 1 and
         token != "by":

      tokenError(
        partitioningTableOptionError,
        ".. \"by\" not specified at token 2")

    elif i == 2 and
         not @[ "hash",
                "list",
                "range" ].contains(token):

      tokenError(
        partitioningTableOptionError,
        ".. \"hash\", \"list\" or \"range\" not specified at token 3")

    elif i == 3 and
         token != "on":

      tokenError(
        partitioningTableOptionError,
        ".. \"on\" not specified at token 4")

    # Collect partition key field name
    if i >= 4:
      partitionKeyFieldName.add(token)

  # Verify partitionKeyFieldName
  if len(partitionKeyFieldName) == 0:

      tokenError(
        partitioningTableOptionError,
        ".. partition key field name not specified starting at token 5")

  # Lookup partitionKeyFieldName as Field
  let keyField =
        getFieldByName(
          join(
            partitionKeyFieldName,
            " "),
          model)

  # Set model.partitioning
  var partitioning =
        Partitioning(
          partitioningType: tokens[2],
          keyField: keyField)

  model.partitioning = some(partitioning)


proc snakeCaseFields*(strSeq: var seq[string]) =

  for i in 0 .. len(strSeq) - 1:

    strSeq[i] = inSnakeCase(strSeq[i])


proc splitModelFields*(str: string): seq[string] =

  var strSeq = str.split(",")

  for i in 0 .. len(strSeq) - 1:

    strSeq[i] = strip(strSeq[i])

  return strSeq


proc tokenError(
      errorHeading: string,
      errorDetail: string) =

  raise newException(
          ValueError,
          errorHeading &
          errorDetail)

