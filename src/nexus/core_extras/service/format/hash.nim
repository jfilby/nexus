import hashes, times


proc getUniqueHash*(inStrs: seq[string],
                    strSeparator: string = "-",
                    maxLen: int = 64,
                    withTimestamp: bool = true,
                    readable: bool = false): string =

  # Get concatted strings
  var
    first = true
    str = ""

  for inStr in inStrs:

    if first == false:
      str &= strSeparator

    else:
      first = false

    str &= inStr

  # Return final string
  if readable == false:
    str = $hash(str)

  # With timestamp
  if withTimestamp == true:
    let timestamp = format(now(),
                           "yyyyMMddhhmmss")

    return str & strSeparator & timestamp

  # Without timestamp
  else:
    return str

