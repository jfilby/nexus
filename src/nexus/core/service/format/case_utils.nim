import chronicles, strutils


# Forward declarations
proc inSnakeCase*(
       str: string,
       replacePunctuation: bool = true,
       nimSafe: bool = true): string


# Code
proc inCamelCase*(
       str: string): string =

  debug "inCamelCase()",
    str = str

  # Return immediately if the string is blank
  if str == "":
    return ""

  # Split by space
  var strModified =
        replace(str,
                '-',
                ' ')

  strModified =
    replace(strModified,
            '_',
            ' ')

  let subStrs = strModified.split(' ')

  # Camel-case subStrs
  var
    first = true
    camelCaseStr = ""

  for subStr in subStrs:

    debug "inCamelCase()",
      subStr = subStr

    if len(subStr) == 0:
      continue

    if isUpperAscii(subStr[0]) == true:

      # Capitalize all subStrs after the first one
      if first == false:
        camelCaseStr &= subStr
      else:
        first = false
        camelCaseStr &= toLowerAscii(subStr)

    else:

      # Format the subStr
      let fieldSubStr = inSnakeCase(subStr)

      # Capitalize all subStrs after the first one
      if first == false:
        camelCaseStr &= capitalizeAscii(fieldSubStr)
      else:
        first = false
        camelCaseStr &= fieldSubStr

  # Return
  debug "inCamelCase()",
    camelCaseStr = camelCaseStr

  return camelCaseStr


proc inNaturalCase*(str: string): string =

  # Return immediately if the string is blank
  if str == "":
    return ""

  # Split by space
  var strModified =
        replace(str,
                '-',
                ' ')

  strModified =
    replace(strModified,
            '_',
            ' ')

  let subStrs = strModified.split(' ')

  # Pascal-case subStrs
  var
    first = true
    naturalCaseStr = ""

  for subStr in subStrs:

    if len(subStr) == 0:
      continue

    if first == false:
      naturalCaseStr &= " "
    else:
      first = false

    if isUpperAscii(subStr[0]):
      naturalCaseStr &= subStr

    else:
      naturalCaseStr &= capitalizeAscii(subStr)

  # Return
  return naturalCaseStr


proc inPascalCase*(str: string): string =

  # Return immediately if the string is blank
  if str == "":
    return ""

  # Split by space
  var strModified =
        replace(str,
                '-',
                ' ')

  strModified =
    replace(strModified,
            '_',
            ' ')

  let subStrs = strModified.split(' ')

  # Pascal-case subStrs
  var strInPascalCase = ""

  for subStr in subStrs:

    if len(subStr) == 0:
      continue

    if isUpperAscii(subStr[0]):
      strInPascalCase &= subStr

    else:
      strInPascalCase &= capitalizeAscii(subStr)

  # Return
  return strInPascalCase


proc inSnakeCase*(
       str: string,
       replacePunctuation: bool = true,
       nimSafe: bool = true): string =

  # Return immediately if the string is blank
  if str == "":
    return ""

  # Get lowercase string
  var lowerStr = toLowerAscii(str)

  # Replace punctuation
  if replacePunctuation == true:

    lowerStr =
      replace(lowerStr,
              ".",
              "_d_")

    lowerStr =
      replace(lowerStr,
              "-",
              "_")

    lowerStr =
      replace(lowerStr,
              " ",
              "_")

    lowerStr =
      replace(lowerStr,
              "(",
              "opP")

    lowerStr =
      replace(lowerStr,
              ")",
              "clP")

  # Remove trailing underscores. Shrink by length rather than by slicing: with a
  # 1 character string, `s[0 .. ^2]` is `s[0 .. -1]`, i.e. the whole string
  # again, so the loop could never make progress and ran off the end of an
  # empty string.
  while lowerStr.len > 0 and
       lowerStr[^1] == '_':

    lowerStr.setLen(lowerStr.len - 1)

  # Nim safe
  if nimSafe == true:
    if @[ "for",
          "method",
          "type",
          "when" ].contains(lowerStr):

      lowerStr = "x_" & lowerStr

  # Return lowerStr
  return lowerStr

