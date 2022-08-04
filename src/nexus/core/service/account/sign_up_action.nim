import chronicles, jester, json, options, strformat, tables, times
import docui/service/sdk/docui_types
import docui/service/sdk/docui_utils
import nexus/core/data_access/account_user_data
import nexus/core/modules/nexus_core
import nexus/core/service/account/encrypt
import nexus/core/service/account/send_user_emails
import nexus/core/service/account/utils
import nexus/core/service/account/verify_sign_up_fields
import nexus/core/service/nexus_settings/get
import nexus/core/types/context_type
import nexus/core/types/model_types as nexus_core_model_types
import nexus/core/types/view_types
import nexus/core_extras/service/format/hash
import nexus/crm/data_access/mailing_list_data
import nexus/crm/data_access/mailing_list_subscriber_data
import nexus/crm/types/model_types as nexus_crm_model_types


proc signUpAction*(nexusCoreContext: NexusCoreContext): DocUIReturn =

  # Validate
  if nexusCoreContext.web == none(WebContext):

    raise newException(
            ValueError,
            "nexusCoreContext.web == none")

  # Initial vars
  template request: untyped = nexusCoreContext.web.get.request

  let contentType = getContentType(request)

  var
    name = ""
    email = ""
    password1 = ""
    password2 = ""
    siteName = ""
    emailUpdates = ""

  # Handle form post
  if contentType == ContentType.Form:
    if request.params.hasKey("name"):
        name = request.params["name"]

    if request.params.hasKey("email"):
        email = request.params["email"]

    if request.params.hasKey("password1"):
        password1 = request.params["password1"]

    if request.params.hasKey("password2"):
        password2 = request.params["password2"]

    if request.params.hasKey("siteName"):
        siteName = request.params["siteName"]

    if request.params.hasKey("emailUpdates"):
        emailUpdates = "Y"

  # Handle JSON post
  var formValues: JsonNode

  if contentType == ContentType.JSON:
    let json = parseJson(request.body)

    if json.hasKey(DocUI_Form):
      if json[DocUI_Form].hasKey(DocUI_Children):

        formValues = json[DocUI_Form][DocUI_Children]

        if formValues.hasKey("name"):
          name = formValues["name"].getStr()

        if formValues.hasKey("email"):
          email = formValues["email"].getStr()

        if formValues.hasKey("password1"):
          password1 = formValues["password1"].getStr()

        if formValues.hasKey("password2"):
          password2 = formValues["password2"].getStr()

        if formValues.hasKey("siteName"):
          siteName = formValues["siteName"].getStr()

        if formValues.hasKey("emailUpdates"):
          emailUpdates = "Y"

  # Verify the input
  let docuiReturn =
        verifySignUpFields(
          nexusCoreContext,
          name,
          email,
          password1,
          password2)

  debug "signUpPagePost(): docuiReturn",
    isVerified = docuiReturn.isVerified,
    errorMessage = docuiReturn.errorMessage

  if docuiReturn.isVerified == false:
    return docuiReturn

  # Get the passwordHash and salt
  var
    passwordHash: string
    passwordSalt: string

  (passwordHash,
   passwordSalt) = hashPassword(password1,
                                inSalt = "")

  let
    apiKey = generateAPIKey()
    signUpCode = generateSignUpCode()

  # Begin
  beginTransaction(nexusCoreContext.db)

  # Create AccountUser record
  let accountUser =
        createAccountUser(
          nexusCoreContext.db,
          accountId = none(int64),
          name = name,
          email = email,
          passwordHash = passwordHash,
          passwordSalt = passwordSalt,
          apiKey = apiKey,
          signUpCode = signUpCode,
          signUpDate = now(),
          passwordResetCode = none(string),
          passwordResetDate = none(DateTime),
          isActive = false,
          isAdmin = false,
          isVerified = false,
          lastLogin = none(DateTime),
          lastUpdate = none(DateTime),
          created = now())

  # Create mailing list subscriber record
  if emailUpdates == "Y":

    # Get announcements mailing list name from NexusSetting
    let
      mailingListName =
        getNexusSettingValue(
          nexusCoreContext.db,
          module = "Nexus CRM",
          key = "Announcements Mailing List")

      mailingListOwnerEmail =
        getNexusSettingValue(
          nexusCoreContext.db,
          module = "Nexus CRM",
          key = "Announcements Mailing List Owner Email")

      nexusCrmDbContext =
        NexusCrmDbContext(dbConn: nexusCoreContext.db.dbConn)

      ownerAccountUser =
        getAccountUserByEmail(
          nexusCoreContext.db,
          mailingListOwnerEmail.get)

      # Get MailingList record
      mailingList =
        getMailingListByAccountUserIdAndName(
          nexusCrmDbContext,
          ownerAccountUser.get.accountUserId,
          mailingListName.get)

    if mailingList == none(MailingList):

      raise newException(
              ValueError,
              "MailingList record not found for owner with accountUserId: " &
              &"{ownerAccountUser.get.accountUserId} and mailing list name: " &
              mailingListName.get)

    # Get/create MailingListSubscriber record
    discard getOrCreateMailingListSubscriberByMailingListIdAndEmail(
              nexusCrmDbContext,
              accountUserId = some(accountUser.accountUserId),
              mailingList.get.mailingListId,
              getUniqueHash(@[ mailingListName.get,
                               email ]),
              isActive = false,
              email,
              name = some(name),
              verificationCode = some(signUpCode),
              isVerified = false,
              created = now(),
              deleted = none(DateTime))

  # Commit
  commitTransaction(nexusCoreContext.db)

  # Send sign-up code email
  sendSignUpCodeEmail(
    email,
    signUpCode,
    siteName)

  # Return
  return newDocUIReturn(true)

