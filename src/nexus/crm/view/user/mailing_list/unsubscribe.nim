import jester, options, strformat
import karax / [karaxdsl, vdom, vstyles]
import nexus/core/types/model_types as nexus_core_model_types
import nexus/core/types/view_types
import nexus/core/view/base_page
import nexus/crm/data_access/mailing_list_subscriber_data
import nexus/crm/types/model_types
import fields
import subscriber_card


proc mailingListUnsubscribePage*(
       nexusCoreDbContext: NexusCoreDbContext,
       request: Request,
       webContext: WebContext): string =

  # Get vars
  var
    uniqueHash: string
    verificationCode: string

  if request.params.contains("uniqueHash"):
    uniqueHash = request.params["uniqueHash"]
  else:
    return "Error"

  if request.params.contains("verificationCode"):
    verificationCode = request.params["verificationCode"]
  else:
    return "Error"

  # Get NexusCRMContext module
  let nexusCRMModule =
        NexusCRMContext(
          db: nexusCoreDbContext.db)

  # Get MailingListSubscriber record
  var
    subscriberVerificationCode = ""

    mailingListSubscriber =
        getMailingListSubscriberByUniqueHash(
          nexusCRMModule,
          uniqueHash)

  if mailingListSubscriber == none(MailingListSubscriber):

    raise newException(
            ValueError,
            "MailingListSubscriber record not found")

  if mailingListSubscriber.get.verificationCode != none(string):
    subscriberVerificationCode = mailingListSubscriber.get.verificationCode.get

  # Check verificationCode
  var pageContext =
        newPageContext(pageTitle = "Unsubscribe from Mailing List")

  if subscriberVerificationCode != verificationCode:

    let vnode = buildHtml(tdiv()):
      p(): text "Invalid verification code."

    return baseForContent(
             webContext,
             pageContext,
             vnode)

  # Subscription view page
  let vnode = buildHtml(tdiv()):
    mailingListSubscriberCard(
      webContext,
      mailingListSubscriber.get)
    br()
    unsubscribeButton()

  baseForContent(webContext,
                 pageContext,
                 vnode)


proc mailingListUnsubscribePagePost*(
       request: Request,
       webContext: WebContext,
       nexusCoreDbContext: NexusCoreDbContext): string =

  # Get vars
  var uniqueHash: string

  if request.params.contains("uniqueHash"):
    uniqueHash = request.params["uniqueHash"]
  else:
    return "Error"

  # Get NexusCRMContext module
  let nexusCRMModule =
        NexusCRMContext(
          db: nexusCoreDbContext.db)

  # Get MailingListSubscriber record
  var mailingListSubscriber =
        getMailingListSubscriberByUniqueHash(
          nexusCRMModule,
          uniqueHash)

  if mailingListSubscriber == none(MailingListSubscriber):

    raise newException(
            ValueError,
            "MailingListSubscriber record not found")

  # Set to unsubscribed
  discard
    updateMailingListSubscriberByPk(
      nexusCRMModule,
      mailingListSubscriber.get,
      setFields = @[ "active" ])

  # Redirect to unsubscribe confirmed page
  redirectToURL("/mailing/unsubscribe/confirm")

