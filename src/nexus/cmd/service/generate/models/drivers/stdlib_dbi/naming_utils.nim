import nexus/cmd/types/types


proc getColumnName*(field: Field): string =

  if field.name == "Email Verified":
    return "\\\"emailVerified\\\""

  else:
    return field.nameInSnakeCase


proc getTableName*(model: Model): string =

  # Quote the User table special case (to disambiugate from the Postgres user
  # table). A better approach would be to allow the user to specify a table
  # name in the config.
  if model.name == "User":
    return "\\\"User\\\""

  else:
    return model.baseNameInSnakeCase

