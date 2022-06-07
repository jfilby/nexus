# This is a custom verion of Nim's v1.2 db_postgres.tryInsertID that allows the ID field name to be specified
# The original version is found in: https://github.com/nim-lang/Nim/blob/devel/lib/impure/db_postgres.nim

import db_common, db_postgres, postgres, strutils


proc dbFormat(formatstr: SqlQuery, args: varargs[string]): string =
  result = ""
  var a = 0
  if args.len > 0 and not string(formatstr).contains("?"):
    dbError("""parameter substitution expects "?" """)
  if args.len == 0:
    return string(formatstr)
  else:
    for c in items(string(formatstr)):
      if c == '?':
        add(result, dbQuote(args[a]))
        inc(a)
      else:
        add(result, c)


proc setupQuery(db: DbConn, query: SqlQuery,
                args: varargs[string]): PPGresult =
  result = pqexec(db, dbFormat(query, args))
  if pqResultStatus(result) != PGRES_TUPLES_OK: dbError(db)


proc tryInsertNamedID*(db: DbConn, query: SqlQuery,pkName: string,
                       args: varargs[string, `$`]): int64
                       {.tags: [WriteDbEffect].}=
  ## executes the query (typically "INSERT") and returns the
  ## generated ID for the row or -1 in case of an error. 
  var x = pqgetvalue(setupQuery(db, SqlQuery(string(query) & " RETURNING " & pkName),
    args), 0, 0)
  if not isNil(x):
    result = parseBiggestInt($x)
  else:
    result = -1

