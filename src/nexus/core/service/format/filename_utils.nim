import chronicles, options, os, strformat, strutils, tables
import nexus/core/types/types


# Forward declarations
proc parseFilenameExpandUnixEnvVars*(
       filename: var string,
       testEnvs: Option[Table[string, string]] = none(Table[string, string])):
         bool
proc parseFilenameExpandWindowsEnvVars*(
       filename: var string,
       testEnvs: Option[Table[string, string]] = none(Table[string, string])):
         bool


# Code
proc crossPlatformPath*(
       path: string,
       checkForEmptyPath: bool = false): string =

  debug "crossPlatformPath()",
    path = path

  # Handle an empty path
  if path == "":

    if checkForEmptyPath == true:
      raise newException(ValueError,
                         "path not specified")
    else:
      return

  # Normalize dir separators
  var
    crossPath = normalizedPath(path)
    inEnvVar = false
    isWindows = false

  if DirSep == '\\':
    isWindows = true

  # Solve env var if required
  # Note: this doesn't handle env vars plus with additional path info
#[
  if path[0] == '$' or
     path[0] == '%':
    let envVarExpanded = parseFilenameExpandEnvVars(crossPath)
]#

  debug "crossPlatformPath()",
    crossPath = crossPath

  # Convert env vars to Windows style
  if isWindows == true:

    for i in 0 .. len(crossPath) - 1:

      if inEnvVar == true and
         crossPath[i] == '/':

        inEnvVar = false
        crossPath = crossPath[0 .. i - 1] & '%' &
          crossPath[i + 1 .. len(crossPath) + 1]

      if crossPath[i] == '$':
        crossPath[i] = '%'
        inEnvVar = true

  debug "crossPlatformPath()",
    path = path,
    crossPath = crossPath

  return crossPath


proc getEnvInclTest(
       envVarName: string,
       testEnvs: Option[Table[string, string]] = none(Table[string, string])):
         string =

  # If used, lookup a test environment var setting
  if testEnvs != none(Table[string, string]):

    if testEnvs.get.hasKey(envVarName):
      return testEnvs.get[envVarName]

    else:
      return ""

  # Return OS env var
  return getEnv(envVarName)


proc getRelativePath*(filename: var string): string =

  let lastSlash = rfind(filename, DirSep)

  if lastSlash < 0 or
     lastSlash + 1 > len(filename) - 1:
    return ""

  return filename[lastSlash + 1 .. len(filename) - 1]


proc parseFilenameExpandEnvVars*(
       filename: var string,
       testEnvs: Option[Table[string, string]] = none(Table[string, string])):
         bool =

  var
    modifiedUnix = false
    modifiedWindows = false

  if find(filename,
          '$') >= 0:

    modifiedUnix =
      parseFilenameExpandUnixEnvVars(
        filename,
        testEnvs)

  if find(filename,
          '%') >= 0:

    modifiedWindows =
      parseFilenameExpandWindowsEnvVars(
        filename,
        testEnvs)

  if modifiedUnix == true or
     modifiedWindows == true:

    return true

  else:
    return false


proc parseFilenameExpandUnixEnvVars*(
       filename: var string,
       testEnvs: Option[Table[string, string]] = none(Table[string, string])):
         bool =

  debug "parseFilenameExpandUnixEnvVars",
    filename = filename

  var
    expanded = false
    timeout = 10
    findDollar = find(filename,
                      "$")

  # While env var dollar symbols are present
  while findDollar >= 0:

    var
      format = FormatEnvVar.NoFormat
      starting = -1
      ending = -1

    # Check for ${VAR} format
    let findDollarWithBraces =
          find(filename,
               "${")

    if findDollarWithBraces >= 0:
      format = FormatEnvVar.DollarWithBraces
      starting = findDollarWithBraces
      ending = find(filename, "}")

    else:
      format = FormatEnvVar.Dollar
      starting = findDollar
      ending = len(filename) - 1

    # If ending not found, raise an exception
    if starting < 0 or
       ending < 0:
      raise newException(
              ValueError,
              &"failed to parse filename: {filename} due to incorrect env " &
               "var formatting")

    # Env var substitution if found
    expanded = true

    if format == FormatEnvVar.DollarWithBraces:

      let
        envVarWithDollar = filename[starting .. ending]
        endCut = len(envVarWithDollar) - 2
        envVar = getEnvInclTest(
                   envVarWithDollar[2 .. endCut],
                   testEnvs)

      debug "parseFilenameExpandUnixEnvVars()",
        envVarWithDollar = envVarWithDollar,
        envVar = envVar

      filename = replace(filename,
                         envVarWithDollar,
                         envVar)

    elif format == FormatEnvVar.Dollar:

      # Look for the next forward slash (or backslash)
      let
          fwdSlash = find(filename, '/')
          backSlash = find(filename, '\\')

      if fwdSlash >= 0:
        ending = fwdSlash - 1

      if backSlash >= 0:
        ending = backSlash - 1

      let envVarWithDollar = filename[starting .. ending]

      debug "parseFilenameExpandUnixEnvVars()",
        envVarWithDollar = envVarWithDollar

      let envVar = getEnvInclTest(
                     envVarWithDollar[1 .. len(envVarWithDollar) - 1],
                     testEnvs)

      filename = replace(filename,
                         envVarWithDollar,
                         envVar)

    # Find another dollar
    findDollar = find(filename,
                      "$")

    # Timeout
    timeout -= 1

    if timeout == 0:
      raise newException(ValueError,
                         "function timed out")

  debug "parseFilenameExpandUnixEnvVars()",
    filename = filename

  return expanded


proc parseFilenameExpandWindowsEnvVars*(
       filename: var string,
       testEnvs: Option[Table[string, string]] = none(Table[string, string])):
         bool =

  debug "parseFilenameExpandWindowsEnvVars",
    filename = filename

  var
    expanded = false
    timeout = 10
    firstPct = find(filename,
                    '%')

  # While env var pct symbols are present
  while firstPct >= 0:

    # Check for ${VAR} format
    let
      secondPct =
        find(filename,
             '%',
             firstPct + 1)

    # If ending not found, raise an exception
    if secondPct < 0:
      raise newException(
              ValueError,
              &"failed to parse filename: {filename} due to incorrect env " &
               "var formatting")

    # Env var substitution if found
    expanded = true

    let
      envVarName = filename[firstPct + 1 .. secondPct - 1]
      envVar = getEnvInclTest(
                 envVarName,
                 testEnvs)

    debug "parseFilenameExpandWindowsEnvVars()",
      envVarName = envVarName,
      envVar = envVar

    filename = replace(filename,
                       &"%{envVarName}%",
                       envVar)

    # Find another dollar
    firstPct = find(filename,
                    '%')

    # Timeout
    timeout -= 1

    if timeout == 0:
      raise newException(ValueError,
                         "function timed out")

  debug "parseFilenameExpandWindowsEnvVars()",
    filename = filename

  return expanded


proc resolveCrossPlatformPath*(path: string): string =

  var pathVar = path

  discard parseFilenameExpandEnvVars(pathVar)

  return crossPlatformPath(pathVar)

