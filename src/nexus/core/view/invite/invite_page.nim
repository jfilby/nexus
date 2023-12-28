import jester, options, strformat, times
import db_connector/db_postgres
import karax / [karaxdsl, vdom, vstyles]
import nexus/core/data_access/account_user_data
import nexus/core/data_access/db_conn
import nexus/core/data_access/invite_data
import nexus/core/service/account/jwt_utils
import nexus/core/service/account/roles
import nexus/core/service/email/send_email
import nexus/core/service/invite/verify_invite_fields
import nexus/core/types/model_types
import nexus/core/types/view_types
import nexus/core/view/common/common_fields
import nexus/core/view/base_page
import invite_fields


# Forward declarations
proc inviteSendPageMain*(
       request: Request,
       webContext: WebContext,
       nexusCoreDbContext: NexusCoreDbContext,
       errorMessage: string = "",
       fromName: var string,
       fromEmail: var string,
       toName: var string,
       toEmail: var string): string {.thread.}


# Code
proc inviteSendPage*(
       request: Request,
       webContext: WebContext,
       nexusCoreDbContext: NexusCoreDbContext): string =

  var
    fromName = ""
    fromEmail = ""
    toName = ""
    toEmail = ""

  inviteSendPageMain(
    request,
    webContext,
    nexusCoreDbContext,
    errorMessage = "",
    fromName,
    fromEmail,
    toName,
    toEmail)


proc inviteSendPageMain*(
       request: Request,
       webContext: WebContext,
       nexusCoreDbContext: NexusCoreDbContext,
       errorMessage: string = "",
       fromName: var string,
       fromEmail: var string,
       toName: var string,
       toEmail: var string): string {.thread.} =

  # Redirect to login if the user isn't logged in
  if webContext.loggedIn == false:
    return redirectToLogin()

  # Get accountUser row
  let accountUser =
        getAccountUserByPk(
          nexusCoreDbContext,
          webContext.accountUserId)

  # Set form fields, if not already set from a previous form post
  if fromName == "":
    fromName = accountUser.get.name

  if fromEmail == "":
    fromEmail = accountUser.get.email

  # Set pageContext
  var pageContext = newPageContext(pageTitle = "Send an Invite")

  # Get form_div
  let formDiv =
        getFormFactorClass(
          webContext,
          desktopClass = "form_div")

  # Form
  let vnode = buildHtml(tdiv()):

    tdiv(style = style(StyleAttr.width, webContext.formWidth)):

      if errorMessage != "":
        tdiv(style = style(StyleAttr.width, webContext.formWidthNarrow)):
          errorMessage(errorMessage)

    tdiv(class = formDiv,
         style = style(StyleAttr.width, webContext.formWidthNarrow)):

      form(`method` = "post"):
        fromNameFieldAutofocus(fromName)
        fromEmailAddressField(fromEmail)
        br()
        toNameField(toName)
        toEmailAddressField(toEmail)
        br()
        sendInviteButton()

  baseForContent(webContext,
                 pageContext,
                 vnode)


proc inviteSendPagePost*(
       request: Request,
       webContext: WebContext,
       nexusCoreDbContext: NexusCoreDbContext): string =

  # Redirect to login if the user isn't logged in
  if webContext.loggedIn == false:
    return redirectToLogin()

  # Get form parameters
  var
    errorMessage = ""
    fromName = ""
    fromEmail = ""
    toName = ""
    toEmail = ""

  if request.params.hasKey("fromName"):
    fromName = request.params["fromName"]

  if request.params.hasKey("fromEmail"):
    fromEmail = request.params["fromEmail"]

  if request.params.hasKey("toName"):
    toName = request.params["toName"]

  if request.params.hasKey("toEmail"):
    toEmail = request.params["toEmail"]

  # Verify fields
  var
    verified: bool
    verifiedRole: bool
    errorMessageRole: string

  (verified,
   errorMessage) = verifyInviteFields(
                     nexusCoreDbContext,
                     fromName,
                     fromEmail,
                     toName,
                     toEmail)

  # Check user roles
  (verifiedRole,
   errorMessageRole) = checkModifyDataRole(
                         nexusCoreDbContext,
                         webContext.accountUserId,
                         modify_data_role = "Modify user data")

  if verifiedRole == false:
    verified = false
    errorMessage = errorMessageRole

  if verified == true:

    # Insert into invite
    let invite = createInvite(
                   nexusCoreDbContext,
                   fromAccountUserId = webContext.accountUserId,
                   fromEmail,
                   fromName,
                   toEmail,
                   toName,
                   sent = none(DateTime),
                   created = now())

    # Send an email if password was changed
    sendEmail(to_address = toEmail,
              subject = "Todo Network invite",
              body = toName & ",\n\n" &
                     "You have been invited to join Todo Network!\n\n" &
                     "Go to: https://todo.network/ \n\n" &
                     "This invite was sent from " & fromName & " (" & fromEmail & ")")

    return redirectToURL(&"/invite/send/success?toName={toName}&toEmail={toEmail}")

  else:
    # On error go back to the invite page
    return inviteSendPageMain(
             request,
             webContext,
             nexusCoreDbContext,
             errorMessage,
             fromName,
             fromEmail,
             toName,
             toEmail)


proc inviteSendSuccessfulPage*(
       request: Request,
       webContext: WebContext,
       toName: string,
       toEmail: string): string =

  var pageContext = newPageContext(pageTitle = "Invite Sent!")

  let vnode = buildHtml(tdiv()):
    br()
    successMessage("An invite has been sent to " & toName & " (" & toEmail & ")")
    tdiv():
      br()
      p()

  baseForContent(webContext,
                 pageContext,
                 vnode)

