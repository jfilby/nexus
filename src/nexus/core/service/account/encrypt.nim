import argon2, chronicles, random, times


proc createRandomKey*(): string =

  # Randomize
  randomize()

  # Seed/init random
  let seed: int = 429496729

  # Get salt
  var num: int64 = rand(seed)

  let key = $num & $getTime()

  return key


proc generateAPIKey*(): string =

  let key_chars = @[ 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
                     'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
                     'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
                     'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
                     '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' ]

  # Randomize
  randomize()

  # Generate the API key
  var apiKey = ""

  for i in (0 .. len(key_chars) - 1):

    let random_int = rand(len(key_chars) - 1)

    apiKey &= key_chars[random_int]

  debug "generateAPIKey()",
    apiKey = apiKey

  return apiKey


proc generateSignUpCode*(): string =

  # Get an API key
  let apiKey = generateAPIKey()

  # Return the first 5 chars
  return apiKey[0 .. 4]


proc hashPassword*(password: string,
                   inSalt: string): (string, string) =

  let
    hashLen: uint32 = 32
    saltLen = hashLen

  # Get salt if not specified
  var salt: string

  if inSalt == "":
    salt = createRandomKey()
  else:
    salt = inSalt

  # Hash the password
  let passwordInfo = argon2("i",
                            password,
                            salt,
                            2,         # iterations
                            65536,     # bytes in memory
                            4,         # threads
                            hashLen)

  # Return passwordHash and salt
  return ($passwordInfo.raw,
          salt)

