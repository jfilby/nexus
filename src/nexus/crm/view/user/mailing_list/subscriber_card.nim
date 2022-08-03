import strformat, times
import karax / [karaxdsl, vdom, vstyles]
import nexus/core/types/model_types as nexus_core_model_types
import nexus/core/types/view_types
import nexus/core/view/base_page
import nexus/core/view/common/common_fields
import nexus/crm/data_access/mailing_list_subscriber_data
import nexus/crm/types/model_types


proc mailingListSubscriberCard*(
       webContext: WebContext,
       mailingListSubscriber: MailingListSubscriber): VNode =

  let
    formDiv = getFormFactorClass(webContext,
                                 desktopClass = "form_div")

    startDate = format(mailingListSubscriber.created,
                       "yyyy-MM-dd")

  var
    active = "No"
    autoRenew = "No"

  if mailingListSubscriber.isActive == true:
    active = "Yes"

  return buildHtml(tdiv(class = "column")):

    tdiv(class = formDiv):

      h2(class = "subtitle"): text "My Subscription"

      p(): text &"Started: {startDate}"
      p(): text &"Active: {active}"

