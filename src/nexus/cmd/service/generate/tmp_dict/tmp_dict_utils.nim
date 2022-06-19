import chronicles, os, streams, strutils, tables, times, yaml


proc fileChanged*(filename: string,
                  tmpDict: Table[string, string]): bool =

  if not tmpDict.hasKey(filename):
    return true

  let
    file_info = getFileInfo(filename)
    timestampInt64: int64 = parseBiggestInt(tmpDict[filename])

  if file_info.lastWriteTime != fromUnix(timestampInt64):
    return true

  return false


proc getOrCreateTmpDict*(filename: string): Table[string, string] =

  # Attempt to get from filename
  var tmpDict: Table[string, string]

  if fileExists(filename) == true:

    # Import tmpDict YAML
    var s = newFileStream(filename)

    load(s, tmpDict)
    s.close()

  return tmpDict


proc tmpDictChecks*() =

  debug "tmpDictChecks()"

  # Check for tmp relative path
  for kind, path in walkDir(".",
                            relative = true):

    debug "tmpDictChecks()",
      path = path

    if path == "tmp":
      return

  # Error
  raise newException(ValueError,
                     "relative path ./tmp must exist")


proc updateTmpDictFileWritten*(
       filename: string,
       tmpDict: var Table[string, string]) =

  let file_info = getFileInfo(filename)

  tmpDict[filename] = $toUnix(file_info.lastWriteTime)


proc writeTmpDict*(tmpDict: Table[string, string],
                   filename: string) =

  {.hint[XCannotRaiseY]: off.}

  var output =
        dump(tmpDict,
             tsRootOnly,
             asTidy,
             defineOptions(style = psMinimal))

  writeFile(filename,
            output)

