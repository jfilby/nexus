import options


type
  DbDriverYaml* = object
    driver*: string
    minDbVersion*: Option[string]


  DbDriver* = object
    driver*: string
    minDbVersion*: Option[string]

    package: Option[string]
    `import`*: string


const
  stdlibDbMySql = DbDriver(
    driver: "db_connector/db_mysql",
    minDbVersion: none(String),
    package: none(String),
    `import`: "db_mysql")


  stdlibDbPostgres = DbDriver(
    driver: "db_connector/db_postgres",
    minDbVersion: none(String),
    package: none(String),
    `import`: "db_postgres")


  stdlibDbSqlite = DbDriver(
    driver: "db_connector/db_sqlite",
    minDbVersion: none(String),
    package: none(String),
    `import`: "db_sqlite")


  supportedDbDrivers = @[
    stdlibDbMySql,
    stdlibDbPostgres,
    stdlibDbSqlite
  ]

