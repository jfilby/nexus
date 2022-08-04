import db_postgres, htmlgen, jester, options
import nexus/core/data_access/db_conn
import nexus/core/service/account/jwt_utils
import nexus/core/types/context_type
import nexus/core/types/model_types
import nexus/core/types/view_types
import nexus/core/view/common/common_fields
import nexus/core/view/base_page


proc logoutPage*(nexusCoreContext: NexusCoreContext) =

  # Validate
  if nexusCoreContext.web == none(WebContext):

    raise newException(
            ValueError,
            "nexusCoreContext.web == none")

  # Log out with JWT
  logoutJWT(nexusCoreContext.web.get.request,
            nexusCoreContext.db,
            useCookie = true)

