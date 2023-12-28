import chronicles, os, streams, strformat, times, yaml
import db_connector/db_postgres
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
proc loadListYAML*(dbContext: NexusCoreExtrasDbContext,
                   filename: string,
                   listLoadType: ListLoadType)


# Code
proc loadListFiles(dbContext: NexusCoreExtrasDbContext,
                   path: string,
                   listLoadType: ListLoadType) =

  for kind, filename in walkDir(path,
                                relative = true):

    if filename[0] == '.':
      continue

    let fullPath = &"{path}{DirSep}{filename}"

    case kind:

      of pcDir:
        loadListFiles(dbContext,
                      fullPath,
                      listLoadType)

      of pcLinkToDir:
        loadListFiles(dbContext,
                      fullPath,
                      listLoadType)

      of pcFile:
        loadListYAML(dbContext,
                     fullPath,
                     listLoadType)

      of pcLinkToFile:
        loadListYAML(dbContext,
                     fullPath,
                     listLoadType)


proc loadListFiles*(dbContext: NexusCoreExtrasDbContext,
                    path: string) =

  loadListFiles(dbContext,
                &"{path}{DirSep}basic",
                Basic)

  loadListFiles(dbContext,
                &"{path}{DirSep}full",
                Full)


proc truncateAndLoadListFiles*(
       dbContext: NexusCoreExtrasDbContext,
       dataLoadPath: string,
       truncate: bool = false) =

  # Truncate
  if truncate == true:
    truncateListItem(dbContext,
                     cascade = true)

  # Load files
  info "truncateAndLoadListFiles()",
    dataLoadPath = dataLoadPath

  loadListFiles(dbContext,
                dataLoadPath)


proc loadBasicListYAML(
       dbContext: NexusCoreExtrasDbContext,
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
                 dbContext,
                 parentId = none(string),
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
                dbContext,
                some(list.id),
                seqNo,
                &"{listBasicYAML.name}: {listItemName}",
                listItemName,
                description,
                now())

      seq_no += 1


proc loadFullListYAML(
       dbContext: NexusCoreExtrasDbContext,
       listsFullYAML: ListsFullYAML,
       parentId: Option[string] = none(string)) =

  var seq_no = 1

  for listFullYAML in listsFullYAML:

    var description: Option[string]

    if listFullYAML.description != "":
      description = some(listFullYAML.description)

    # Create list
    let listItem =
          getOrCreateListItemByName(
            dbContext,
            parentId,
            seqNo = 1,
            listFullYAML.name,
            listFullYAML.displayName,
            description,
            now())

    # Create list items
    loadFullListYAML(
      dbContext,
      listFullYAML.items,
      some(listItem.id))

    seq_no += 1


proc loadFullListYAML(
       dbContext: NexusCoreExtrasDbContext,
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
    dbContext,
    listsFullYAML)


proc loadListYAML(
       dbContext: NexusCoreExtrasDbContext,
       filename: string,
       listLoadType: ListLoadType) =

  case listLoadType:

    of Basic:
      loadBasicListYAML(dbContext,
                        filename)

    of Full:
      loadFullListYAML(dbContext,
                       filename)

