import argon2, chronicles, std/sysrand, strutils, times


# Number of random bytes behind a generated salt / API key.
const randomKeyBytes = 32

# argon2 requires a salt of at least 8 characters.
const minSaltLength = 8


proc randomKeyHex*(byteLen: int): string =

  # Draw from the OS CSPRNG. random.rand() is not a CSPRNG and re-seeding it on
  # every call weakens the whole stream, which matters here because these values
  # are password salts and JWT signing secrets.
  let raw = urandom(byteLen)

  var key = ""

  for b in raw:
    key.add toHex(b)

  return key


proc createRandomKey*(): string =

  return randomKeyHex(randomKeyBytes)


proc generateAPIKey*(): string =

  # The API key is the JWT signing secret, so it comes from the CSPRNG rather
  # than random.rand().
  return randomKeyHex(randomKeyBytes)


proc generateSignUpCode*(): string =

  # Get an API key
  let apiKey = generateAPIKey()

  # Return the first 12 chars: a 5 character code is only ~30 bits, which is
  # brute-forceable against an endpoint that accepts it with no attempt limit.
  return apiKey[0 .. 11]


proc hashPassword*(password: string,
                   inSalt: string): (string, string) =

  let
    hashLen: uint32 = 32

  # Get salt if not specified
  var salt: string

  if inSalt == "":
    salt = createRandomKey()
  else:
    salt = inSalt

  # argon2 rejects a salt shorter than 8 characters by raising. A short salt can
  # only come from a corrupt or hand-edited row, and this proc runs on the login
  # path, so let the caller treat it as "password did not match" rather than
  # taking down the request handler.
  if salt.len < minSaltLength:

    raise newException(ValueError,
                       "hashPassword(): the salt is too short to be valid")

  # Hash the password
  let passwordInfo = argon2("i",
                            password,
                            salt,
                            2,         # iterations
                            65536,     # bytes in memory
                            4,         # threads
                            hashLen)

  # The hash is returned as hex, not as the raw bytes. password_hash is a
  # character varying column: storing raw bytes corrupts the value (a 0x00
  # byte is rewritten by the driver) and a non-UTF8 byte sequence is rejected
  # outright, leaving the account unable to ever log in.
  return (cast[string](passwordInfo.raw).toHex.toLowerAscii,
          salt)

