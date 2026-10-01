import chronicles, strutils, times
import db_connector/db_postgres


# Forward declarations
proc getPgArrayStringAsSeqString*(pgArrayStr: string): seq[string] {.gcsafe.}


# Code

# quotePgArrayElement(): renders one element of a Postgres array literal that is
# safe to place inside the single-quoted SQL string literal the callers build.
#
# Two independent levels have to be escaped, and doing only one leaves the value
# injectable:
#  - SQL string literal: a `'` must be doubled, otherwise it closes the literal
#    early and the remainder of the element is executed as SQL.
#  - Array literal: an element is wrapped in `"` so a `,` or `}` inside it
#    cannot forge a new element, and a `"` or `\` inside is backslash-escaped.
#    Postgres rejects a doubled `""` there with "malformed array literal", so
#    the escape has to be a backslash.
#
# A backslash is not escaped for the SQL level: with standard_conforming_strings
# on (the default) Postgres treats it as an ordinary character there, and
# doubling it would corrupt the stored value.
proc quotePgArrayElement*(value: string): string =

  result = "\""

  for c in value:

    case c

    of '"':
      # Backslash-escaped: escapes the array delimiter
      result.add "\\\""

    of '\\':
      # Doubled: escapes the escape character itself
      result.add "\\\\"

    of '\'':
      # Doubled: keeps the SQL string literal open
      result.add "''"

    else:
      result.add c

  result.add "\""


# splitPgArrayLiteral(): splits the body of a Postgres array literal into its
# elements.
#
# A plain split(",") is wrong for quoted elements: {"a,b"} is the single element
# `a,b`, and splitting it yields two mangled values. This walks the string and
# only treats a comma as a separator when it is outside a quoted element, then
# removes the quoting and unescapes the doubled delimiters.
proc splitPgArrayLiteral*(pgArrayBody: string): seq[string] {.gcsafe.} =

  var
    elements: seq[string]
    current = ""
    inQuotes = false
    i = 0

  while i < pgArrayBody.len:

    let c = pgArrayBody[i]

    if inQuotes:

      # A backslash escapes the next character: \" is a literal quote and \\ is a
      # literal backslash. Postgres emits the escaping form, not a doubled one.
      if c == '\\' and
         i + 1 < pgArrayBody.len:

        current.add pgArrayBody[i + 1]
        i += 2
        continue

      if c == '"':
        inQuotes = false
        i += 1
        continue

      current.add c
      i += 1
      continue

    case c

    of '"':
      inQuotes = true
      i += 1

    of ',':
      # A NULL element is rendered empty; it is dropped rather than added
      if current.strip().len > 0:
        elements.add(current.strip())
      current = ""
      i += 1

    else:
      current.add c
      i += 1

  if current.strip().len > 0:
    elements.add(current.strip())

  return elements

# stripPgArrayBraces(): removes the outer braces of a Postgres array literal.
#
# The array can be empty or come back as an empty string for a NULL column, and
# slicing [1 .. len - 2] on a string shorter than 2 characters computes a
# negative length and raises, so the check has to happen before the slice.
proc stripPgArrayBraces*(pgArrayStr: string): string =

  if pgArrayStr.len < 2:
    return ""

  return pgArrayStr[1 .. pgArrayStr.len() - 2].strip()


# T: expected to be char or string
proc getSeqStringAsPgArrayString*[T](seqString: seq[T]): string {.gcsafe.} =

  var
    first = true
    pgArrayStr = "{"

  for stringIter in seqString:

    if first == false:
      pgArrayStr &= ","
    else:
      first = false

    pgArrayStr &= quotePgArrayElement($stringIter)

  pgArrayStr &= "}"

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

  let seqString: seq[string] = splitPgArrayLiteral(stripPgArrayBraces(pgArrayStr))
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


proc getPgArrayStringAsSeqInt*(pgArrayStr: string): seq[int] {.gcsafe.} =

  # Get as seq of string
  let seqString = getPgArrayStringAsSeqString(pgArrayStr)

  # Convert to seq of int
  var seqInt: seq[int]

  for str in seqString:
    seqInt.add(parseInt(str))

  # debug "getPgArrayStringAsSeqInt64()",
  #   seqInt = seqInt,
  #   lenSeqInt = len(seqInt),
  #   pgArrayStr = pgArrayStr

  return seqInt


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

  let seqString: seq[string] = splitPgArrayLiteral(stripPgArrayBraces(pgArrayStr))
  var seqFloat: seq[float]

  for str in seqString:

    # debug "getPgArrayStringAsSeqFloat()",
    #   str = str

    # An empty element is a NULL in the array, and parseFloat("") raises
    if str.len > 0:
      seqFloat.add(parseFloat(str))

  # debug "getPgArrayStringAsSeqFloat(): return",
  #   seqFloat = seqFloat,
  #   lenSeqFloat = len(seqFloat),
  #   pgArrayStr = pgArrayStr

  return seqFloat


proc getPgArrayStringAsSeqString*(pgArrayStr: string): seq[string] {.gcsafe.} =

  # debug "getPgArrayStringAsSeqString(): start",
  #   pgArrayStr = pgArrayStr

  # splitPgArrayLiteral() handles quoting, escaping and NULL elements, none of
  # which a plain split(",") can do
  return splitPgArrayLiteral(stripPgArrayBraces(pgArrayStr))


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

