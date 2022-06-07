import options, strformat, times
import nexus/core_extras/service/format/hash
import nexus/crm/data_access/mailing_list_message_data
import nexus/crm/types/model_types


proc createMailingListMessage*(
       nexusCRMModule: NexusCRMModule,
       accountUserId: int64,
       subject: string,
       body: string) =

  let uniqueHash =
        getUniqueHash(@[ subject,
                         body ])

  let mailingListMessage =
        getOrCreateMailingListMessageByUniqueHash(
          nexusCRMModule,
          accountUserId,
          uniqueHash,
          subject,
          body,
          created = now(),
          updated = none(DateTime),
          deleted = none(DateTime))

  echo &"Message created with uniqueHash: {mailingListMessage.uniqueHash}"

