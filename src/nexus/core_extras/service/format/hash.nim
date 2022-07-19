import hashes, random, times


proc getUniqueHash*(inStrs: seq[string],
                    strSeparator: string = "-",
                    maxLen: int = 64,
                    withRandom: bool = true,
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

  # The calling app must call randomize() before calling this proc
  # Add a random integer
  if withRandom == true:

    let randInt = rand(99999)

    str &= strSeparator & $randInt

  # With timestamp
  if withTimestamp == true:
    let timestamp = format(now(),
                           "yyyyMMddhhmmssfff")

    return str & strSeparator & timestamp

  # Without timestamp
  else:
    return str

