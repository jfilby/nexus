import db_connector/db_postgres
import nexus/core/service/account/jwt_utils


proc dailyNexusCoreScheduledTasks*(db: DbConn) =

  purgeDeletedJWTs(db)

