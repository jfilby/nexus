import chronicles, options, strformat, strutils
import nexus/core/service/format/name_utils
import nexus/cmd/service/generate/models/gen_model_utils
import nexus/cmd/types/types


proc createPgTablePartitioning(model: Model): string =

  # Not partitioned
  if model.partitioning == none(Partitioning):
    return ""

  # Partitioned
  let partitioningType =
        toUpperAscii(model.partitioning.get.partitioningType)

  return &"PARTITION BY {partitioningType} " &
         &"({model.partitioning.get.keyField.nameInSnakeCase})"


proc createPgTable*(
       model: Model,
       dmlStr: var string) =

  let tableName = model.baseNameInSnakeCase

  # Start create table statement
  var
    table_type = ""
    schema = "public."

  if model.tableOptions.contains("temporary"):
    table_type = "TEMPORARY "
    schema = ""

  elif model.tableOptions.contains("unlogged"):
    table_type = "UNLOGGED "

  dmlStr &= &"CREATE {table_type}TABLE {schema}{tableName} (\n"

  # Columns
  var first = true

  for field in model.fields:

    # End of line
    if first == false:
      dmlStr &= &",\n"
    else:
      first = false

    let pgFieldType =
          getModelTypeAsPgType(
            field.`type`,
            dmlInfo = true)

    dmlStr &= &"  {field.nameInSnakeCase} {pgFieldType}"

    if field.constraints.contains("not null"):
      dmlStr &= " NOT NULL"

    if field.constraints.contains("auto-value"):
      dmlStr &= " GENERATED ALWAYS AS IDENTITY"

  # PK
  debug "createPgTable()",
    modelpkNameInSnakeCase = model.pkNameInSnakeCase

  if model.pkNameInSnakeCase != "":

    var pkStr = model.pkNameInSnakeCase

    if pkStr[0] != '(':
      pkStr = &"({pkStr})"

    dmlStr &= &",\n" &
               &"  CONSTRAINT {tableName}_pkey PRIMARY KEY {pkStr}\n"

  dmlStr &= ")\n"

  # Can't specify a default tablespace when table is partitioned (Postgres)
  if model.partitioning != none(Partitioning):

    dmlStr &= createPgTablePartitioning(model)

  else:
    # Default tablespace
    dmlStr &= "TABLESPACE pg_default"

  dmlStr &= ";\n" &
            "\n"


proc createPgForeignKeys*(
       model: Model,
       dmlStr: var string) =

  var
    id = 1
    schema = "public."

  for relationship in model.relationships:

    let
      # FK table
      tableName = model.baseNameInSnakeCase
      fkColumns = relationship.from

    var fkColumnFields = splitModelFields(fkColumns)
    snakeCaseFields(fkColumnFields)

    let
      fkColumns_delimited = fkColumnFields.join(", ")
      fk_name = model.baseNameInSnakeCase & "_fk" & "_" & $id

      # Parent table
      to_dot = find(relationship.to, '.')

    # Verify to_dot is found
    if to_dot == -1:
      raise newException(
              ValueError,
              "Relationship's to field is missing the dot separator for " &
              &"model: \"{model.name}\"")

    let
      to_tableName = getSnakeCaseName(relationship.to[0 .. to_dot - 1])
      to_columns = relationship.to[to_dot + 1 .. len(relationship.to) - 1]

    var to_column_fields = splitModelFields(to_columns)
    snakeCaseFields(to_column_fields)

    let toColumnsDelimited = to_column_fields.join(", ")

    # FK DML
    dmlStr &= &"ALTER TABLE {schema}{tableName}\n" &
               &"  ADD CONSTRAINT {fk_name}\n" &
               &"  FOREIGN KEY ({fkColumns_delimited})\n" &
               &"  REFERENCES {to_tableName} ({toColumnsDelimited});\n" &
               &"\n"

    id += 1


proc createPgBTreeIndex(
       id: int,
       index: Index,
       model: Model,
       dmlStr: var string) =

  # Index details
  var unique = ""

  if index.unique == true:
    unique = "UNIQUE "

  let tableName = model.baseNameInSnakeCase
  
  var
    first = true
    indexColumns = ""

  for field in index.fields:

    if first == false:
      indexColumns &= ", "

    else:
      first = false

    indexColumns &= field.nameInSnakeCase

  let indexName = &"{tableName}_ix_{id}"

  # Index DML
  dmlStr &= &"CREATE {unique}INDEX {indexName}\n" &
             &"  ON {tableName} ({indexColumns});\n" &
             &"\n"


proc getPgIndexType(index: Index,
                    model: Model): IndexType =

  return BTreeIndex


proc createPgIndexes*(
       model: Model,
       dmlStr: var string) =

  var
    id = 1

  for index in model.indexes:

    # Determine which index to use
    let indexType =
          getPgIndexType(index,
                         model)

    # Generate appropriate index create DML
    case indexType:

      of BTreeIndex:
        createPgBTreeIndex(
          id,
          index,
          model,
          dmlStr)

    # Inc id
    id += 1

