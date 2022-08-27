import chronicles, db_postgres, strutils, times


# Forward declarations
proc getPgArrayStringAsSeqString*(pgArrayStr: string): seq[string] {.gcsafe.}


# Code

# T: expected to be char or string
proc getSeqStringAsPgArrayString*[T](seqString: seq[T]): string {.gcsafe.} =

  var
    first = true
    pgArrayStr = "{ "

  for stringIter in seqString:

    if first == false:
      pgArrayStr &= ", "
    else:
      first = false

    pgArrayStr &= stringIter

  pgArrayStr &= " }"

  return pgArrayStr


proc getSeqNonStringAsPgArrayString*[T](seqNonString: seq[T]): string {.gcsafe.} =

  var
    first = true
    pgArrayStr = "{ "

  for stringIter in seqNonString:

    if first == false:
      pgArrayStr &= ", "
    else:
      first = false

    pgArrayStr &= $stringIter

  pgArrayStr &= " }"

  return pgArrayStr


proc getPgArrayStringAsSeqChar*(pgArrayStr: string): seq[char] {.gcsafe.} =

  # debug "getPgArrayStringAsSeqChar(): start",
  #   pgArrayStr = pgArrayStr

  let seqString: seq[string] = pgArrayStr[1 .. pgArrayStr.len() - 2].split(",")
  var seqChar: seq[char]

  # debug "getPgArrayStringAsSeqChar()",
  #   seqString = seqString

  for str in seqString:

    # debug "getPgArrayStringAsSeqChar()",
    #   str = str

    if len(str) > 0:
      seqChar.add(str[0])

    # Char can't be zero len
    # else:
    #   seqChar.add(char(0))

  # debug "getPgArrayStringAsSeqChar(): return",
  #   seqChar = seqChar,
  #   lenseqChar = len(seqChar),
  #   pgArrayStr = pgArrayStr

  return seqChar


proc getPgArrayStringAsSeqInt64*(pgArrayStr: string): seq[int64] {.gcsafe.} =

  # Get as seq of string
  let seqString = getPgArrayStringAsSeqString(pgArrayStr)

  # Convert to seq of int64
  var seqInt64: seq[int64]

  for str in seqString:
    seqInt64.add(parseBiggestInt(str))

  # debug "getPgArrayStringAsSeqInt64()",
  #   seqInt64 = seqInt64,
  #   lenSeqInt64 = len(seqInt64),
  #   pgArrayStr = pgArrayStr

  return seqInt64


proc getPgArrayStringAsSeqFloat*(pgArrayStr: string): seq[float] {.gcsafe.} =

  # debug "getPgArrayStringAsSeqFloat(): start",
  #   pgArrayStr = pgArrayStr

  if pgArrayStr == "{}":
    return @[]

  let seqString: seq[string] = pgArrayStr[1 .. pgArrayStr.len() - 2].split(",")
  var seqFloat: seq[float]

  for str in seqString:

    # debug "getPgArrayStringAsSeqFloat()",
    #   str = str

    seqFloat.add(parseFloat(str))

  # debug "getPgArrayStringAsSeqFloat(): return",
  #   seqFloat = seqFloat,
  #   lenSeqFloat = len(seqFloat),
  #   pgArrayStr = pgArrayStr

  return seqFloat


proc getPgArrayStringAsSeqString*(pgArrayStr: string): seq[string] {.gcsafe.} =

  # debug "getPgArrayStringAsSeqString(): start",
  #   pgArrayStr = pgArrayStr

  if pgArrayStr == "{}":
    return @[]

  var seqString: seq[string] = pgArrayStr[1 .. pgArrayStr.len() - 2].split(",")

  # Strip spaces
  for i in (0 .. len(seqString) - 1):

    seqString[i] = strip(seqString[i])    

  # Unquote if present
  for i in (0 .. len(seqString) - 1):

    # debug "getPgArrayStringAsSeqString()",
    #   seqStringI = seqString[i]

    if seqString[i][0 .. 0] == "\"":

      debug "remove double quotes.."

      seqString[i] = seqString[i][1 .. len(seqString[i]) - 2]

  # debug "getPgArrayStringAsSeqString()",
  #   seqString = seqString,
  #   lenSeqString = len(seqString),
  #   pgArrayStr = pgArrayStr

  return seqString


proc formatPgTimestamp*(timestamp: DateTime): string =

  return format(timestamp,
                "yyyy-MM-dd HH:mm:ss")


proc parsePgBool*(pgBoolStr: string): bool =

  if pgBoolStr == "t":
    return true

  else:
    return false


proc parsePgTimestamp*(pgTimestampStr: string): DateTime =

  if len(pgTimestampStr) == 10:
    return parse(pgTimestampStr,
                 "yyyy-MM-dd",
                 utc())

  elif len(pgTimestampStr) == 19:
    return parse(pgTimestampStr,
                 "yyyy-MM-dd HH:mm:ss",
                 utc())

  # Truncate for now, leaves out microseconds + tz data
  elif len(pgTimestampStr) >= 22:
    return parse(pgTimestampStr[0 .. 18],
                 "yyyy-MM-dd HH:mm:ss",
                 utc())

  #elif len(pgTimestampStr) == 29:
    # with .ffffff means microseconds
    # with +zz is the timezone offset from UTC
  #  return parse(pgTimestampStr[0 .. 28],
  #               "yyyy-MM-dd HH:mm:ss.ffffff+zz")

  error "parsePgTimestamp()",
    pgTimestampStr = pgTimestampStr


proc pgToBool*(b: bool): string =

  if b == true:
    return "true"

  else:
    return "false"


proc pgToDateString*(date: DateTime): string =

  return "to_date('" & date.format("yyyy-MM-dd") & "', 'yyyy-MM-dd')"


proc pgToDateTimeString*(timestamp: DateTime): string =

  return "to_timestamp('" & timestamp.format("yyyy-MM-dd HH:mm:ss") &
         "', 'yyyy-MM-dd HH24:MI:SS')"

