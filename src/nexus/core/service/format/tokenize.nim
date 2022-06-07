import chronicles


proc isNumberStartingChar(c: char): bool =

  if c >= '0' and c <= '9':

     return true

  return false


proc isNumberContinuingChar(c: char): bool =

  if (c >= '0' and c <= '9') or
     @[ ',', '.' ].contains(c):

     return true

  return false


proc isPunctChar(c: char): bool =

  if @[ ',', '.', '?', ':', ';', '\'', '"', '!', '@', '#', '$', '%', '^', '&', '*' ].contains(c):

     return true

  return false


proc isWhitespaceChar(c: char): bool =

  if @[ ' ', '\t', '\n', '\r' ].contains(c):

     return true

  return false


proc isWordChar(c: char): bool =

  if (c >= 'a' and c <= 'z') or
     (c >= 'A' and c <= 'Z'):

     return true

  return false


proc isWordPunctChar(c: char): bool =

  if @[ '/', '\'', '@', '#', '$', '%', '^', '&', '*', '-' ].contains(c):

     return true

  return false


proc tokenize*(s: string,
               whitespace_as_tokens: bool = false): seq[string] =

  var
    in_whitespace: bool = false
    in_word: bool = false
    in_number: bool = false
    in_punct: bool = false

    token: string = ""
    tokens: seq[string]

  for i in (0 .. len(s) - 1):

    let c = s[i]
    debug "note:",
      c = c

    # If in whitespace
    if in_whitespace == true:
      if isWhitespaceChar(c):
        token &= c
        continue
      else:
        in_whitespace = false

        if whitespace_as_tokens == true:
          tokens.add(token)

        token = ""

    # If in a word
    if in_word == true:
      if isWordChar(c) or isWordPunctChar(c):
        token &= c
        continue
      else:
        in_word = false
        tokens.add(token)
        token = ""

    # If in a number
    if in_number == true:
      if isNumberContinuingChar(c):
        token &= c
        continue
      else:
        in_number = false
        tokens.add(token)
        token = ""

    # If in punctuation
    if in_punct == true:
      if isPunctChar(c):
        token &= c
        continue
      else:
        in_punct = false
        tokens.add(token)
        token = ""

    # If not currently in a known class of chars
    if isWordChar(c):
      in_word = true
      token &= c
      continue

    if isWhitespaceChar(c):
      in_whitespace = true
      token &= c
      continue

    if isNumberStartingChar(c):
      in_number = true
      token &= c
      continue

    if isPunctChar(c):
      in_punct = true
      token &= c
      continue

  # Add the last token
  if len(token) > 0:
    tokens.add(token)

  return tokens

