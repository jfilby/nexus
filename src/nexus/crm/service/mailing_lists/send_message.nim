import options, smtp, strformat, times
import nexus/core/service/email/send_email
import nexus/crm/data_access/mailing_list_subscriber_data
import nexus/crm/data_access/mailing_list_subscriber_message_data
import nexus/crm/types/model_types


proc sendEmailToMailingList*(
       email: string,
       mailingListMessage: MailingListMessage) =

  sendEmail(toAddress = email,
            mailingListMessage.subject,
            mailingListMessage.message)


proc sendEmailsToMailingList*(
       context: NexusCRMContext,
       mailingList: MailingList,
       mailingListMessage: MailingListMessage,
       batchSize: Option[int] = none(int)) =

  # Get all subscribers
  let mailingListSubscribers =
        filterMailingListSubscriber(
          context,
          whereClause =
            "mailing_list_id = ? and " &
            "not exists (select 1" &
            "              from mailing_list_subscriber_message mlsm" &
            "             where mlsm.mailing_list_message_id    = ?" &
            "               and mlsm.mailing_list_subscriber_id = " &
            "                   mailing_list_subscriber.mailing_list_subscriber_id)",
          whereValues = @[
            $mailingList.mailingListId,
            $mailingListMessage.mailingListMessageId ])

  # Send emails until batchSize is reached (if set)
  var sentEmails = 0

  for mailingListSubscriber in mailingListSubscribers:

    sendEmailToMailingList(
      mailingListSubscriber.email,
      mailingListMessage)

    discard getOrCreateMailingListSubscriberMessageByMailingListSubscriberIdAndMailingListMessageId(
              context,
              none(int64),
              mailingList.mailingListId,
              mailingListSubscriber.mailingListSubscriberId,
              mailingListMessage.mailingListMessageId,
              now())

    # Done?
    sentEmails += 1

    if batchSize != none(int):
      if sentEmails >= batchSize.get:
        break

