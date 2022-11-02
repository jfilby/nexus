import chronicles, db_postgres, jester, options, strformat
import karax / [karaxdsl, vdom, vstyles]
import nexus/core/data_access/account_user_data
import nexus/core/data_access/db_conn
import nexus/core/service/account/encrypt
import nexus/core/service/account/jwt_utils
import nexus/core/service/account/roles
import nexus/core/service/account/verify_my_account_fields
import nexus/core/service/email/send_email
import nexus/core/types/context_type
import nexus/core/types/model_types
import nexus/core/types/view_types
import nexus/core/view/common/common_fields
import nexus/core/view/base_page
import account_fields


# Forward declarations
proc myAccountPageMain(
       nexusCoreContext: NexusCoreContext,
       errorMessage: string = "",
       name: var string,
       email: var string,
       apiKey: bool = false): string {.gcsafe.}


# Code
proc myAccountPage*(
       nexusCoreContext: NexusCoreContext,
       apiKey: bool = false): string {.gcsafe.} =

  var
    name = ""
    email = ""

  myAccountPageMain(
    nexusCoreContext,
    "",
    name,
    email,
    apiKey)


proc myAccountPageMain(
       nexusCoreContext: NexusCoreContext,
       errorMessage: string = "",
       name: var string,
       email: var string,
       apiKey: bool = false): string {.gcsafe.} =

  # Redirect to login if the user isn't logged in
  if nexusCoreContext.web.get.loggedIn == false:
    return redirectToLogin()

  # Get accountUser record
  let accountUser =
        getAccountUserByPk(nexusCoreContext.db,
                           nexusCoreContext.web.get.accountUserId)

  # Set form fields, if not already set from a previous form post
  if name == "":
    name = accountUser.get.name

  if email == "":
    email = accountUser.get.email

  # Set pageContext
  var pageContext = newPageContext(pageTitle = "My Account")

  let formDiv = getFormFactorClass(
                  nexusCoreContext.web.get,
                  desktopClass = "form_div")

  # My Account form
  let vnode = buildHtml(tdiv(style =
                style(StyleAttr.width,
                      nexusCoreContext.web.get.formWidth))):

    if errorMessage != "":
      tdiv(style = style(StyleAttr.width,
                         nexusCoreContext.web.get.formWidthNarrow)):
        errorMessage(errorMessage)

    tdiv(class = formDiv,
         style = style(StyleAttr.width,
                      nexusCoreContext.web.get.formWidthNarrow)):

      form(`method` = "post"):
        nameField(name,
                  autofocus = true)
        emailAddressField(email,
                          autofocus = false)
        br()
        tdiv(style = style(StyleAttr.width, "100%")):
          submitButton(fieldName = "update",
                       name = "Update")

          if apiKey == true:
            submitButton(fieldName = "generate_apiKey",
                         name = "Generate a new API Key")

  # Render page
  baseForContent(nexusCoreContext.web.get,
                 pageContext,
                 vnode,
                 nexusCoreDbContext = some(nexusCoreContext.db))


proc myAccountPagePost*(nexusCoreContext: NexusCoreContext): string =

  # Redirect to login if the user isn't logged in
  if nexusCoreContext.web.get.loggedIn == false:
    return redirectToLogin()

  # Get form data
  var
    name = ""
    email = ""
    password1 = ""
    password2 = ""

  if nexusCoreContext.web.get.request.params.hasKey("name"):
    name = nexusCoreContext.web.get.request.params["name"]

  if nexusCoreContext.web.get.request.params.hasKey("email"):
    email = nexusCoreContext.web.get.request.params["email"]

  if nexusCoreContext.web.get.request.params.hasKey("password1"):
    password1 = nexusCoreContext.web.get.request.params["password1"]

  if nexusCoreContext.web.get.request.params.hasKey("password2"):
    password2 = nexusCoreContext.web.get.request.params["password2"]

  # Verify the input
  var
    verified: bool
    verifiedRole: bool
    errorMessage: string
    errorMessageRole: string

  let docUIReturn =
        verifyMyAccountFields(
          nexusCoreContext.db,
          name,
          email,
          password1,
          password2)

  verified = docUIReturn.isVerified
  errorMessage = docUIReturn.errorMessage

  # Check user roles
  (verifiedRole,
   errorMessageRole) = checkModifyDataRole(
                         nexusCoreContext.db,
                         nexusCoreContext.web.get.accountUserId,
                         modifyDataRole = "Modify user data")

  if verifiedRole == false:
    verified = false
    errorMessage = errorMessageRole

  # Create a new user (if verification succeeded)
  if verified == true:

    # Get accountUser row
    var accountUser =
          getAccountUserByPk(
            nexusCoreContext.db,
            nexusCoreContext.web.get.accountUserId)

    var
      emailChanged = ""
      personalDetailsChanged = ""
      passwordChanged = ""

    # Password change
    if password1 != "":

      passwordChanged = "Y"

      # Get the passwordHash and salt
      (accountUser.get.passwordHash,
       accountUser.get.passwordSalt) =
        hashPassword(password1,
                     "")

      let rowsUpdated =
            updateAccountUserByPk(
              nexusCoreContext.db,
              accountUser.get,
              setFields = @[ "password_hash",
                             "password_salt" ])

    # Update fields if changed
    if accountUser.get.name != name:

      personalDetailsChanged = "Y"

      accountUser.get.name = name

      let updatedRows =
            updateAccountUserByPk(
              nexusCoreContext.db,
              accountUser.get,
              setFields = @[ "name" ])

    # Send an email if username was changed
    if accountUser.get.email != email:

      emailChanged = "Y"

      accountUser.get.email = email

      let updatedRows =
            updateAccountUserByPk(
              nexusCoreContext.db,
              accountUser.get,
              setFields = @[ "email" ])

    return redirectToURL(&"/account/my-account/success?emailChanged={emailChanged}&" &
                         &"personalDetailsChanged={personalDetailsChanged}&" &
                         &"passwordChanged={passwordChanged}")

  else:
    # On error go back to the sign up page
    return myAccountPageMain(nexusCoreContext,
                             errorMessage,
                             name,
                             email)


proc myAccountSuccessPage*(
       nexusCoreContext: NexusCoreContext,
       emailChanged: string = "",
       personalDetailsChanged: string = "",
       passwordChanged: string = ""): string =

  let vnode = buildHtml(tdiv()):
    br()

    if emailChanged != "" or
       personalDetailsChanged != "" or
       passwordChanged != "":

      successMessage("Successfully updated.")
      tdiv():
        br()
        if emailChanged != "":
          p(): text "Your email address has been changed."
        if personalDetailsChanged != "":
          p(): text "Your personal details have been updated."
        if passwordChanged != "":
          p(): text "Your password has been changed."

    else:
      infoMessage("Nothing was changed.")

  # Set pageContext
  var pageContext = newPageContext(pageTitle = "My Account")

  # Render page
  baseForContent(nexusCoreContext.web.get,
                 pageContext,
                 vnode,
                 nexusCoreDbContext = some(nexusCoreContext.db))

