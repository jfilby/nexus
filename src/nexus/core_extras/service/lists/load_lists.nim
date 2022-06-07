import chronicles, db_postgres, os, streams, strformat, times, yaml
import nexus/core_extras/data_access/list_item_data
import nexus/core_extras/types/model_types


# Types
type
  ListBasicYAML* = object
    name*: string
    displayName*: string
    description*: string
    items*: seq[string]


  ListsBasicYAML* = seq[ListBasicYAML]


  ListFullYAML* = object
    name*: string
    displayName*: string
    description*: string
    items*: seq[ListFullYAML]


  ListsFullYAML* = seq[ListFullYAML]


  ListLoadType = enum
    Basic = 0,
    Full


# Forward declarations
proc loadListYAML*(nexusCoreExtrasModule: NexusCoreExtrasModule,
                   filename: string,
                   listLoadType: ListLoadType)


# Code
proc loadListFiles(nexusCoreExtrasModule: NexusCoreExtrasModule,
                   path: string,
                   listLoadType: ListLoadType) =

  for kind, filename in walkDir(path,
                                relative = true):

    if filename[0] == '.':
      continue

    let fullPath = &"{path}{DirSep}{filename}"

    case kind:

      of pcDir:
        loadListFiles(nexusCoreExtrasModule,
                      fullPath,
                      listLoadType)

      of pcLinkToDir:
        loadListFiles(nexusCoreExtrasModule,
                      fullPath,
                      listLoadType)

      of pcFile:
        loadListYAML(nexusCoreExtrasModule,
                     fullPath,
                     listLoadType)

      of pcLinkToFile:
        loadListYAML(nexusCoreExtrasModule,
                     fullPath,
                     listLoadType)


proc loadListFiles*(nexusCoreExtrasModule: NexusCoreExtrasModule,
                    path: string) =

  loadListFiles(nexusCoreExtrasModule,
                &"{path}{DirSep}basic",
                Basic)

  loadListFiles(nexusCoreExtrasModule,
                &"{path}{DirSep}full",
                Full)


proc truncateAndLoadListFiles*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       dataLoadPath: string,
       truncate: bool = false) =

  # Truncate
  if truncate == true:
    truncateListItem(nexusCoreExtrasModule,
                     cascade = true)

  # Load files
  info "truncateAndLoadListFiles()",
    dataLoadPath = dataLoadPath

  loadListFiles(nexusCoreExtrasModule,
                dataLoadPath)


proc loadBasicListYAML(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       filename: string) =

  info "loadBasicListYAML()",
    filename = filename

  # Load YAML
  var
    listsBasicYAML: ListsBasicYAML
    s = newFileStream(filename)

  load(s, listsBasicYAML)
  s.close()

  for listBasicYAML in listsBasicYAML:

    var description: Option[string]

    if listBasicYAML.description != "":
      description = some(listBasicYAML.description)

    # Create list
    let list = getOrCreateListItemByName(
                 nexusCoreExtrasModule,
                 parentListItemId = none(int64),
                 seqNo = 1,
                 listBasicYAML.name,
                 listBasicYAML.displayName,
                 description,
                 now())

    var seq_no = 1

    # Create list items
    for listItemName in listBasicYAML.items:

      if listBasicYAML.description != "":
        description = some(listBasicYAML.description)

      else:
        description = none(string)

      discard getOrCreateListItemByName(
                nexusCoreExtrasModule,
                some(list.listItemId),
                seqNo,
                &"{listBasicYAML.name}: {listItemName}",
                listItemName,
                description,
                now())

      seq_no += 1


proc loadFullListYAML(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       listsFullYAML: ListsFullYAML,
       parentListItemId: Option[int64] = none(int64)) =

  var seq_no = 1

  for listFullYAML in listsFullYAML:

    var description: Option[string]

    if listFullYAML.description != "":
      description = some(listFullYAML.description)

    # Create list
    let listItem =
          getOrCreateListItemByName(
            nexusCoreExtrasModule,
            parentListItemId,
            seqNo = 1,
            listFullYAML.name,
            listFullYAML.displayName,
            description,
            now())

    # Create list items
    loadFullListYAML(
      nexusCoreExtrasModule,
      listFullYAML.items,
      some(listItem.listItemId))

    seq_no += 1


proc loadFullListYAML(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       filename: string) =

  info "loadFullListYAML()",
    filename = filename

  # Load YAML
  var
    listsFullYAML: ListsFullYAML
    s = newFileStream(filename)

  load(s, listsFullYAML)
  s.close()

  loadFullListYAML(
    nexusCoreExtrasModule,
    listsFullYAML)


proc loadListYAML(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       filename: string,
       listLoadType: ListLoadType) =

  case listLoadType:

    of Basic:
      loadBasicListYAML(nexusCoreExtrasModule,
                        filename)

    of Full:
      loadFullListYAML(nexusCoreExtrasModule,
                       filename)

