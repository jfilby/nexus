import chronicles, db_postgres, jester, options, strformat, strutils, times
import karax / [karaxdsl, vdom, vstyles]
import nexus/core/types/view_types
import nexus/core/view/common/spacers
import nexus/core/view/base_page
import frontpage/frontpage


# Code
proc signUpStats*(request: Request,
                  webContext: WebContext): string {.gcsafe.} =

  error "signUpStats(): unimplemented"

#[
  # Get count
  let
    subscriberCount =
      ..

    subscriberVerified_count =
      ..

  # Setup content
  let content = &"<center>" &
                &"<p>Verified subscribers: {subscriberVerifiedCount}</p>" &
                &"<p>Total subscribers: {subscriberCount}</p>" &
                &"</center>" &
                $verticalPaddingSpacer("30em")

  # Setup PageContext
  var pageContext =
        newPageContext(pageTitle = "Subscriber Count",
                       displayPageHeading = false,
                       horizontalCenter = true,
                       verticalAlign = true)

  # Render template page
  templatePage(webContext,
               pageContext,
               indexStart,
               content,
               indexEnd)
]#

