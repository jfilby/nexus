import options


proc compareInt64sWithOptions*(
       aSeq: Option[seq[int64]],
       bSeq: Option[seq[int64]]): bool =

  if aSeq == none(seq[int64]) and
     bSeq == none(seq[int64]):

    return false

  elif (aSeq == none(seq[int64]) and
        bSeq != none(seq[int64])) or
       (aSeq != none(seq[int64]) and
        bSeq == none(seq[int64])):

    return true

  for a in aSeq.get:
    if not bSeq.get.contains(a):
      return false

  for b in bSeq.get:
    if not aSeq.get.contains(b):
      return false

  return true

