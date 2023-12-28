import htmlgen, jester, options
import db_connector/db_postgres
import nexus/core/data_access/db_conn
import nexus/core/service/account/jwt_utils
import nexus/core/types/context_type
import nexus/core/types/model_types
import nexus/core/types/view_types
import nexus/core/view/common/common_fields
import nexus/core/view/base_page


proc logoutPage*(context: NexusCoreContext) =

  # Validate
  if context.web == none(WebContext):

    raise newException(
            ValueError,
            "context.web == none")

  # Log out with JWT
  logoutJWT(context.web.get.request,
            context.db,
            useCookie = true)

