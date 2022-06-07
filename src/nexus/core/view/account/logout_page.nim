import db_postgres, htmlgen, jester, options
import nexus/core/data_access/db_conn
import nexus/core/service/account/jwt_utils
import nexus/core/types/model_types
import nexus/core/types/module_globals
import nexus/core/types/view_types
import nexus/core/view/common/common_fields
import nexus/core/view/base_page


proc logoutPage*(request: Request,
                 webContext: WebContext) =

  # Log out with JWT
  logoutJWT(request,
            nexusCoreModule,
            useCookie = true)

