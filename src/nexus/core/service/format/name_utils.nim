import chronicles, strutils


# Forward declarations
proc getSnakeCaseName*(
       name: string,
       replacePunctuation: bool = true,
       nimSafe: bool = true): string


# Code
proc getCamelCaseName*(
       name: string): string =

  debug "getCamelCaseName()",
    name = name

  # Return immediately if the string is blank
  if name == "":
    return ""

  # Split by space
  var nameModified =
        replace(name,
                '-',
                ' ')

  nameModified =
    replace(nameModified,
            '_',
            ' ')

  let subNames = nameModified.split(' ')

  # Camel-case subNames
  var
    first = true
    camelCaseName = ""

  for subName in subNames:

    debug "getCamelCaseName()",
      subName = subName

    if len(subName) == 0:
      continue

    if isUpperAscii(subName[0]) == true:

      # Capitalize all subNames after the first one
      if first == false:
        camelCaseName &= subName
      else:
        first = false
        camelCaseName &= toLowerAscii(subName)

    else:

      # Format the subName
      let field_subName = getSnakeCaseName(subName)

      # Capitalize all subNames after the first one
      if first == false:
        camelCaseName &= capitalizeAscii(field_subName)
      else:
        first = false
        camelCaseName &= field_subName

  # Return
  debug "getCamelCaseName()",
    camelCaseName = camelCaseName

  return camelCaseName


proc getNaturalCaseName*(name: string): string =

  # Return immediately if the string is blank
  if name == "":
    return ""

  # Split by space
  var nameModified =
        replace(name,
                '-',
                ' ')

  nameModified =
    replace(nameModified,
            '_',
            ' ')

  let subNames = nameModified.split(' ')

  # Pascal-case subNames
  var
    first = true
    naturalCaseName = ""

  for subName in subNames:

    if len(subName) == 0:
      continue

    if first == false:
      naturalCaseName &= " "
    else:
      first = false

    if isUpperAscii(subname[0]):
      naturalCaseName &= subname

    else:
      naturalCaseName &= capitalizeAscii(subName)

  # Return
  return naturalCaseName


proc getnameInPascalCase*(name: string): string =

  # Return immediately if the string is blank
  if name == "":
    return ""

  # Split by space
  var nameModified =
        replace(name,
                '-',
                ' ')

  nameModified =
    replace(nameModified,
            '_',
            ' ')

  let subNames = nameModified.split(' ')

  # Pascal-case subNames
  var nameInPascalCase = ""

  for subName in subNames:

    if len(subName) == 0:
      continue

    if isUpperAscii(subname[0]):
      nameInPascalCase &= subname

    else:
      nameInPascalCase &= capitalizeAscii(subName)

  # Return
  return nameInPascalCase


proc getSnakeCaseName*(
       name: string,
       replacePunctuation: bool = true,
       nimSafe: bool = true): string =

  # Return immediately if the string is blank
  if name == "":
    return ""

  # Get lowercase string
  var str = toLowerAscii(name)

  # Replace punctuation
  if replacePunctuation == true:

    str = replace(str,
                  ".",
                  "_d_")

    str = replace(str,
                  "-",
                  "_")

    str = replace(str,
                  " ",
                  "_")

    str = replace(str,
                  "(",
                  "opP")

    str = replace(str,
                  ")",
                  "clP")

  # Remove trailing underscores
  while str[len(str) - 1 .. len(str) - 1] == "_":
    str = str[0 .. len(str) - 2]

  # Nim safe
  if nimSafe == true:
    if @[ "for",
          "method",
          "type",
          "when" ].contains(str):

      str = "x_" & str

  # Return str
  return str

