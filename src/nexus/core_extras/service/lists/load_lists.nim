import chronicles, db_postgres, os, streams, strformat, times, yaml
import nexus/core_extras/data_access/list_item_data
import nexus/core_extras/types/context_type
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
proc loadListYAML*(nexusCoreExtrasContext: NexusCoreExtrasContext,
                   filename: string,
                   listLoadType: ListLoadType)


# Code
proc loadListFiles(nexusCoreExtrasContext: NexusCoreExtrasContext,
                   path: string,
                   listLoadType: ListLoadType) =

  for kind, filename in walkDir(path,
                                relative = true):

    if filename[0] == '.':
      continue

    let fullPath = &"{path}{DirSep}{filename}"

    case kind:

      of pcDir:
        loadListFiles(nexusCoreExtrasContext,
                      fullPath,
                      listLoadType)

      of pcLinkToDir:
        loadListFiles(nexusCoreExtrasContext,
                      fullPath,
                      listLoadType)

      of pcFile:
        loadListYAML(nexusCoreExtrasContext,
                     fullPath,
                     listLoadType)

      of pcLinkToFile:
        loadListYAML(nexusCoreExtrasContext,
                     fullPath,
                     listLoadType)


proc loadListFiles*(nexusCoreExtrasContext: NexusCoreExtrasContext,
                    path: string) =

  loadListFiles(nexusCoreExtrasContext,
                &"{path}{DirSep}basic",
                Basic)

  loadListFiles(nexusCoreExtrasContext,
                &"{path}{DirSep}full",
                Full)


proc truncateAndLoadListFiles*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       dataLoadPath: string,
       truncate: bool = false) =

  # Truncate
  if truncate == true:
    truncateListItem(nexusCoreExtrasContext.db,
                     cascade = true)

  # Load files
  info "truncateAndLoadListFiles()",
    dataLoadPath = dataLoadPath

  loadListFiles(nexusCoreExtrasContext,
                dataLoadPath)


proc loadBasicListYAML(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
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
                 nexusCoreExtrasContext.db,
                 parentId = none(int64),
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
                nexusCoreExtrasContext.db,
                some(list.id),
                seqNo,
                &"{listBasicYAML.name}: {listItemName}",
                listItemName,
                description,
                now())

      seq_no += 1


proc loadFullListYAML(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       listsFullYAML: ListsFullYAML,
       parentId: Option[int64] = none(int64)) =

  var seq_no = 1

  for listFullYAML in listsFullYAML:

    var description: Option[string]

    if listFullYAML.description != "":
      description = some(listFullYAML.description)

    # Create list
    let listItem =
          getOrCreateListItemByName(
            nexusCoreExtrasContext.db,
            parentId,
            seqNo = 1,
            listFullYAML.name,
            listFullYAML.displayName,
            description,
            now())

    # Create list items
    loadFullListYAML(
      nexusCoreExtrasContext,
      listFullYAML.items,
      some(listItem.id))

    seq_no += 1


proc loadFullListYAML(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
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
    nexusCoreExtrasContext,
    listsFullYAML)


proc loadListYAML(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       filename: string,
       listLoadType: ListLoadType) =

  case listLoadType:

    of Basic:
      loadBasicListYAML(nexusCoreExtrasContext,
                        filename)

    of Full:
      loadFullListYAML(nexusCoreExtrasContext,
                       filename)

