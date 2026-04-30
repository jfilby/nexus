import options


proc compareInt64sWithOptions*(
       aSeq: Option[seq[int64]],
       bSeq: Option[seq[int64]]): bool =

  if aSeq.isNone and
     bSeq.isNone:

    return false

  elif (aSeq.isNone and
        bSeq.isSome) or
       (aSeq.isSome and
        bSeq.isNone):

    return true

  for a in aSeq.get:
    if not bSeq.get.contains(a):
      return false

  for b in bSeq.get:
    if not aSeq.get.contains(b):
      return false

  return true

