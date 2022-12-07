import chronicles, jester, json, options, strformat, tables, times
import docui/service/sdk/docui_elements
import docui/service/sdk/docui_types
import docui/service/sdk/docui_utils
import nexus/core/data_access/account_user_data
import nexus/core/service/account/encrypt
import nexus/core/service/account/send_user_emails
import nexus/core/service/account/utils
import nexus/core/service/account/verify_sign_up_fields
import nexus/core/service/nexus_settings/get
import nexus/core/types/context_type
import nexus/core/types/view_types
import nexus/core_extras/service/format/hash
import nexus/crm/data_access/mailing_list_data
import nexus/crm/data_access/mailing_list_subscriber_data
import nexus/crm/types/model_types as nexus_crm_model_types
import verify_sign_up_code_fields


proc returnForm(children: seq[JsonNode]): JsonNode =

  return form("return",
              "sign_up_form",
              children)


proc verifySignUpAction*(context: NexusCoreContext): DocUIReturn =

  # Validate
  if context.web == none(WebContext):

    raise newException(
            ValueError,
            "context.web == none")

  # Initial vars
  template request: untyped = context.web.get.request

  let contentType = getContentType(request)

  var
    field_errors: Table[string, string]
    email = ""
    signUpCode = ""

  # Handle form post
  if contentType == ContentType.Form:
    if request.params.hasKey("email"):
      email = request.params["email"]

    if request.params.hasKey("signUpCode"):
      signUpCode = request.params["signUpCode"]

  # Handle JSON post
  var formValues: JsonNode

  if contentType == ContentType.JSON:
    debug "verifySignupAction: request",
      body = request.body

    let json = parseJson(request.body)

    if json.hasKey(DocUI_Form):
      if json[DocUI_Form].hasKey(DocUI_Children):

        formValues = json[DocUI_Form][DocUI_Children]

        if formValues.hasKey("email"):
          email = formValues["email"].getStr()

        if formValues.hasKey("signUpCode"):
          signUpCode = formValues["signUpCode"].getStr()

  # Get accountUser record
  var accountUser =
        getAccountUserByEmail(
          context.db,
          email)

  # Verify fields
  let docuiReturn =
        verifySignUpCodeFields(
          context.db,
          email,
          signUpCode,
          accountUser)

  if docuiReturn.isVerified == true:

    # Verify sign-up code
    if accountUser.get.signUpCode == signUpCode:

      accountUser.get.isActive = true
      accountUser.get.isVerified = true

      var rowsUpdated =
            updateAccountUserByPk(
              context.db,
              accountUser.get,
              setFields = @[ "is_active",
                             "is_verified" ])

      if rowsUpdated == 0:

        let form = returnForm(@[
                     fieldError("email",
                                "Email address not found in the system") ])

        return newDocUIReturn(false,
                              form)

      # Get mailing list
      let
        nexusCrmDbContext =
          NexusCrmDbContext(dbConn: context.db.dbConn)

        mailingListName =
          getNexusSettingValue(
            context.db,
            module = "Nexus CRM",
            key = "Announcements Mailing List")

        mailingListOwnerEmail =
          getNexusSettingValue(
            context.db,
            module = "Nexus CRM",
            key = "Announcements Mailing List Owner Email")

        ownerAccountUser =
          getAccountUserByEmail(
            context.db,
            mailingListOwnerEmail.get)

        mailingList =
          getMailingListByAccountUserIdAndName(
            nexusCrmDbContext,
            ownerAccountUser.get.accountUserId,
            mailingListName.get)

      # Activate mailing list for subscriber
      let uniqueHash =
            getUniqueHash(@[ $mailingList.get.mailingListId,
                             email ])

      var mailingListSubscriber =
            getOrCreateMailingListSubscriberByMailingListIdAndAccountUserId(
              nexusCrmDbContext,
              accountUser.get.accountUserId,
              mailingList.get.mailingListId,
              uniqueHash,
              isActive = true,
              email = email,
              name = some(accountUser.get.name),
              verificationCode = none(string),
              isVerified = true,
              created = now(),
              deleted = none(DateTime))

      if mailingListSubscriber.isActive == false or
         mailingListSubscriber.isVerified == false:

        mailingListSubscriber.isActive = true
        mailingListSubscriber.isVerified = true

        rowsUpdated =
          updateMailingListSubscriberByPk(
            nexusCrmDbContext,
            mailingListSubscriber,
            setFields = @[ "is_active",
                           "is_verified" ])

    else:
        let form = returnForm(@[
                     fieldError("signUpCode",
                                "Incorrect verification code.") ])

        return newDocUIReturn(false,
                              form)

  # Return OK
  return newDocUIReturn(true)

