import nexus/cmd/types/types


proc getColumnName*(field: Field): string =

  return field.nameInSnakeCase


proc getTableName*(model: Model): string =

  return model.baseNameInSnakeCase

