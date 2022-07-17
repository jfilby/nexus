import jester, json, options, tables
import docui/service/sdk/docui_types
import docui/service/sdk/docui_utils
import nexus/core/data_access/account_user_data
import nexus/core/data_access/db_conn
import nexus/core/service/account/utils
import nexus/core/types/model_types
import nexus/core/types/module_globals
import nexus/core/types/view_types
import nexus/core/view/common/common_fields
import nexus/core/view/base_page
import encrypt
import send_user_emails
import verify_reset_password_fields


proc resetPasswordRequestAction*(request: Request): DocUIReturn =

  let content_type = getContentType(request)

  var
    email = ""
    siteName = ""

  # Get form params
  if request.params.hasKey("email"):
    email = request.params["email"]

  if request.params.hasKey("siteName"):
    siteName = request.params["siteName"]

  # Handle JSON post
  var formValues: JsonNode

  if content_type == ContentType.JSON:
    let json = parseJson(request.body)

    if json.hasKey(DocUI_Form):
      if json[DocUI_Form].hasKey(DocUI_Children):

        formValues = json[DocUI_Form][DocUI_Children]

        if formValues.hasKey("email"):
          email = formValues["email"].getStr()

        if formValues.hasKey("siteName"):
          siteName = formValues["siteName"].getStr()

  # Get accountUser record
  let accountUser =
        getAccountUserByEmail(
          nexusCoreModule,
          email)

  # Verify the input
  let docuiReturn =
        verifyResetPasswordRequestFields(
          email,
          accountUser)

  if docuiReturn.isVerified == false:
    return docuiReturn

  # Generate reset code and send password reset email
  else:

    # Get accountUser record
    var accountUser =
          getAccountUserByEmail(
            nexusCoreModule,
            email)

    # Get passwordResetCode
    accountUser.get.passwordResetCode = some(generateSignUpCode())

    # Update accountUser with the passwordResetCode
    discard updateAccountUserByPk(
              nexusCoreModule,
              accountUser.get,
              setFields = @[ "password_reset_code"])

    # Send email for password request verification
    sendResetPasswordRequestEmail(
      email,
      accountUser.get.passwordResetCode.get,
      siteName)

  # Return
  return newDocUIReturn(true)


proc resetPasswordChangeAction*(request: Request): DocUIReturn =

  let content_type = getContentType(request)

  # Get form params
  var
    email = ""
    passwordResetCode = ""
    password1 = ""
    password2 = ""

  if request.params.hasKey("email"):
    email = request.params["email"]

  if request.params.hasKey("passwordResetCode"):
    passwordResetCode = request.params["passwordResetCode"]

  if request.params.hasKey("password1"):
    password1 = request.params["password1"]

  if request.params.hasKey("password2"):
    password2 = request.params["password2"]

  # Handle JSON post
  var formValues: JsonNode

  if content_type == ContentType.JSON:
    let json = parseJson(request.body)

    if json.hasKey(DocUI_Form):
      if json[DocUI_Form].hasKey(DocUI_Children):

        formValues = json[DocUI_Form][DocUI_Children]

        if formValues.hasKey("email"):
          email = formValues["email"].getStr()

        if formValues.hasKey("passwordResetCode"):
          passwordResetCode = formValues["passwordResetCode"].getStr()

        if formValues.hasKey("password1"):
          password1 = formValues["password1"].getStr()

        if formValues.hasKey("password2"):
          password2 = formValues["password2"].getStr()

  # Get accountUser record
  let accountUser =
        getAccountUserByEmail(
          nexusCoreModule,
          email)

  # Verify the input
  let docuiReturn =
        verifyChangePasswordFields(
          email,
          passwordResetCode,
          password1,
          password2,
          accountUser)

  # Generate reset code and send password reset email
  if docuiReturn.isVerified == false:
    return docuiReturn

  else:

    # Get accountUser record
    var accountUser =
          getAccountUserByEmail(
            nexusCoreModule,
            email)

    # Update password
    # Get the passwordHash and salt
    (accountUser.get.passwordHash,
     accountUser.get.passwordSalt) =
      hashPassword(password1,
                   inSalt = "")

    discard updateAccountUserByPk(
              nexusCoreModule,
              accountUser.get,
              setFields = @[ "password_hash",
                             "password_salt" ])

  # Return
  return newDocUIReturn(true)

