import math, options, strformat, strutils


proc charFromString*(str: string): char =

  if len(str) == 0:
    return char(0)

  else:
    return str[0]


proc charsFromStrings*(strs: seq[string]): seq[char] =

  var chars: seq[char]

  for str in strs:

    if len(str) == 0:
      chars.add(char(0))

    else:
      chars.add(str[0])

  return chars


proc charsWithOption*(strs: seq[string]): Option[seq[char]] =

  if len(strs) > 0:
    var chars: seq[char]

    for str in strs:

      if len(str) < 1:
        chars.add(char(0))

      else:
        chars.add(str[0])

    return some(chars)

  return none(seq[char])


# fmtfloat code from https://forum.nim-lang.org/t/8162 (see Javi's post)
proc fmtFloat*(value: float,
               decimals: int,
               format: string = "",
               thousandSep: string = ",",
               decimalSep: string = "."): string =

  if value != value:
    return "NaN"
  elif value == Inf:
    return "Inf"
  elif value == NegInf:
    return "-Inf"

  let
    forceSign  = format.find('s') >= 0
    thousands  = format.find('t') >= 0
    removeZero = format.find('z') >= 0

  var valueStr = ""

  if decimals >= 0:
    valueStr.formatValue(round(value, decimals), "." & $decimals & "f")
  else:
    valueStr = $value

  if valueStr[0] == '-':
    valueStr = valueStr[1 .. ^1]

  let
    period = valueStr.find('.')
    negZero = 1.0 / value == NegInf
    sign = if value < 0.0 or negZero: "-" elif forceSign: "+" else: ""

  var
    integer    = ""
    integerTmp = valueStr[0 .. period - 1]
    decimal    = decimalSep & valueStr[period + 1 .. ^1]

  if thousands:
    while true:
      if integerTmp.len > 3:
        integer = thousandSep & integerTmp[^3 .. ^1] & integer
        integerTmp = integerTmp[0 .. ^4]
      else:
        integer = integerTmp & integer
              
        break
  else:
    integer = integerTmp

  while removeZero:

    if decimal[^1] == '0':
      decimal = decimal[0 .. ^2]
    else:
      break

  if decimal == decimalSep:
    decimal = ""

  return sign & integer & decimal


proc getIndentByLen*(length: int): string =

  var str = ""

  for i in 0 .. length - 1:

    str &= " "

  return str


proc getStringAsFmtString*(inStr: string): string =

  var str = "fmt\""

  for c in inStr:

    if c == '"':
      str &= "{'\n\n'}"

    else:
      str &= c

  str &= "\""

  return str


proc int64sFromStrings*(strs: seq[string]): seq[int64] =

  var int64s: seq[int64]

  for str in strs:

    int64s.add(parseBiggestInt(str))

  return int64s


proc int64sFromStrings*(strs: Option[seq[string]]): Option[seq[int64]] =

  if strs == none(seq[string]):
    return none(seq[int64])

  return some(int64sFromStrings(strs.get))


proc int64sWithOption*(int64s: seq[int64]): Option[seq[int64]] =

  if len(int64s) > 0:
    return some(int64s)

  return none(seq[int64])


proc readonlyDefault*(str: string): string =

  if strip(str) == "":
    return "-"

  return str


proc stripAllStrings*(inStr: string): string =

  var str = ""

  for i in 0 .. len(inStr) - 1:

    if inStr[i] != ' ':
      str &= inStr[i]

  return str


proc stringsFromChars*(chars: seq[char]): seq[string] =

  var strs: seq[string]

  for char_iter in chars:

    strs.add($char_iter)

  return strs


proc stringsFromInt64s*(int64s: seq[int64]): seq[string] =

  var strs: seq[string]

  for int64_iter in int64s:

    strs.add($int64_iter)

  return strs


proc stringsWithOptionFromInt64sWithOption*(
       int64s: Option[seq[int64]]):
         Option[seq[string]] =

  if int64s == none(seq[int64]):
    return none(seq[string])

  return some(stringsFromInt64s(int64s.get))


proc stringWithOption*(str: string): Option[string] =

  if str == "":
    return none(string)

  else:
    return some(str)


proc stringWithoutOption*(str: Option[string]): string =

  if str == none(string):
    return ""

  else:
    return str.get


proc stringsWithOption*(strs: seq[string]): Option[seq[string]] =

  if len(strs) > 0:
    return some(strs)

  return none(seq[string])

