import options, sets, tables


const
  # Artifacts
  ModelsArtifact* = "models"
  WebAppArtifact* = "web-app"
  WebServiceArtifact* = "web-service"
  WebRoutesArtifact* = "web-routes"


type
  PlatformVars* = object
    scriptFileExtension*: string
    comment*: string
    set*: string
    docUiPath*: string
    envStart*: string
    envEnd*: string


  AppTemplate* = object
    appName*: string
    appNameInSnakeCase*: string
    appNameInUpperSnakeCase*: string
    appNameInLowerSnakeCase*: string

    moduleName*: string
    moduleNameInSnakeCase*: string
    moduleNameUpperInSnakeCase*: string
    moduleNameLowerInSnakeCase*: string

    artifact*: string
    docUi*: bool

    isUnix*: bool
    compileScript*: string

    cwd*: string

    basePathEnvVar*: string
    nimSrcPathEnvVar*: string

    basePath*: string
    confPath*: string
    moduleConfPath*: string
    srcPath*: string
    nimPath*: string
    nimPathExpanded*: string
    modulePath*: string
    confWebApp*: string
    confWebAppYaml*: string

    dbServer*: string
    dbPort*: string
    dbName*: string
    dbUsername*: string
    dbPassword*: string


  IndexType* = enum
    BTreeIndex = 0


  FieldYAML* = object
    name*: string
    `type`*: string
    constraints*: seq[string]


  FieldsYAML* = seq[FieldYAML]


  Field* = ref object of RootObj
    name*: string

    nameInCamelCase*: string
    nameInPascalCase*: string
    nameInSnakeCase*: string

    `type`*: string
    constraints*: seq[string]

    shortHash*: string


  Fields* = seq[Field]


  DefaultsField* = object
    field*: string
    default*: string


  UniqueFields* = object
    fields*: seq[string]


  IndexYAML* = object
    unique*: bool
    fields*: seq[string]

  IndexesYAML* = seq[IndexYAML]


  Index* = object
    unique*: bool
    fields*: Fields

  Indexes* = seq[Index]


  GetFunction* = object
    name*: string
    selectFields*: seq[string]
    whereFields*: seq[string]


  Relationship* = object
    `type`*: string
    `from`*: string
    `to`*: string


  UpdateFunction* = object
    name*: string
    setFields*: seq[string]
    whereFields*: seq[string]


  ModelYAML* = object
    name*: string
    description*: string
    module*: string
    modelOptions*: seq[string]
    tableOptions*: seq[string]
    fields*: FieldsYAML
    defaults*: seq[DefaultsField]
    pkFields*: seq[string]
    uniqueFieldSets*: seq[UniqueFields]
    indexes*: IndexesYAML
    getFunctions*: seq[GetFunction]
    relationships*: seq[Relationship]
    updateFunctions*: seq[UpdateFunction]


  ModelsYAML* = seq[ModelYAML]


  ModuleYAML* = object
    name*: string
    path*: string


  ModulesYAML* = seq[ModuleYAML]


  Module* = ref object of RootObj
    name*: string
    shortName*: string
    shortNameLower*: string

    nameInCamelCase*: string
    nameInPascalCase*: string
    nameInSnakeCase*: string
    shortNameInSnakeCase*: string

    package*: string
    importPath*: string

    basePath*: string
    confPath*: string
    srcPath*: string
    srcRelativePath*: string

    imported*: bool
    generate*: seq[string]


  Modules* = seq[Module]


  ModelFilterYAML* = object
    model*: string              # Model name
    alias*: string
    whereFields*: seq[string]
    whereValues*: seq[string]
    orderBy*: seq[string]


  ModelFiltersYAML* = seq[ModelFilterYAML]


  ModelFilter* = object
    modelName*: string
    modelAlias*: string
    whereFields*: seq[string]
    whereValues*: seq[string]
    orderBy*: seq[string]

    model*: Model
    modelPlural*: bool


  ModelFilters* = seq[ModelFilter]


  PackageYAML* = object
    package*: string
    moduleShortNames*: seq[string]

    # Paths
    confPath*: string
    generate*: seq[string]
    generateBasePath*: string
    generateSrcPath*: string


  PackagesYAML* = seq[PackageYAML]


  # A package is a set of imported modules
  Package* = ref object of RootObj
    modules*: Modules


  Packages* = seq[Package]


  ModelFieldForRouteYAML* = object
    name*: string
    module*: string
    field*: string


  ModelFieldsForRouteYAML* = seq[ModelFieldForRouteYAML]


  RouteParameterYAML* = object
    name*: string
    `type`*: string
    constraints*: seq[string]
    description*: string


  RouteParametersYAML* = seq[RouteParameterYAML]


  RouteParameter* = object
    name*: string
    `type`*: string
    constraints*: seq[string]
    description*: string

    nameInCamelCase*: string


  RouteParameters* = seq[RouteParameter]


  RouteYAML* = object
    name*: string
    description*: string
    group*: string
    methods*: seq[string]
    options*: string
    route*: string
    parameters*: RouteParametersYAML
    defaults*: seq[DefaultsField]
    modelFields*: ModelFieldsForRouteYAML


  RoutesYAML* = seq[RouteYAML]


  Route* = object
    name*: string
    description*: string
    group*: string
    methods*: seq[string]
    options*: string
    route*: string
    parameters*: RouteParameters
    defaults*: seq[DefaultsField]
    modelFields*: ModelFieldsForRouteYAML

    nameInCamelCase*: string
    nameInSnakeCase*: string
    groupInSnakeCase*: string

    pagesImport*: string
    jesterRoute*: string
    jesterRouteParameters*: seq[string]


  Routes* = object
    name*: string
    routes*: seq[Route]


  ExternalRouteYAML* = object
    module*: string
    routes*: seq[string]


  ExternalRoutesYAML* = seq[ExternalRouteYAML]


  RouteFileYAML* = object
    local*: seq[string]
    external*: ExternalRoutesYAML


  Partitioning* = object
    partitioningType*: string
    keyField*: Field


  Model* = object
    isRef*: bool
    longNames*: bool

    name*: string
    namePlural*: string

    baseNameInCamelCase*: string
    nameInCamelCase*: string
    namePluralInCamelCase*: string

    baseNameInPascalCase*: string
    nameInPascalCase*: string
    namePluralInPascalCase*: string

    baseNameInSnakeCase*: string
    nameInSnakeCase*: string
    namePluralInSnakeCase*: string
    refSuffixInSnakeCase*: string

    # Short hash for forms
    shortHash*: string

    # Named names are different when an alias is used
    namedName*: string
    namedNamePlural*: string
    namedNameInCamelCase*: string
    namedNamePluralInCamelCase*: string
    namedNameInPascalCase*: string
    namednamePluralInPascalCase*: string
    namedNameInSnakeCase*: string
    namedNamePluralInSnakeCase*: string

    packageImport*: string
    moduleImport*: string

    # Fields pkName and pkNameInSnakeCase are only used for single-field PKs
    pkName*: string
    pkNameInCamelCase*: string
    pkNameInSnakeCase*: string
    pkModelDNamesInCamelCase*: string
    pkNimType*: string

    # The Nim types used by the model type
    nimTypes*: OrderedSet[string]

    # The Nim modules required to work with the Nim types
    nimTypeModules*: OrderedSet[string]

    # More fields from ModelYAML (but with FieldsYAML converted to Fields)
    description*: string
    module*: Module
    modelOptions*: seq[string]
    tableOptions*: seq[string]
    fields*: Fields
    defaults*: seq[DefaultsField]
    partitioning*: Option[Partitioning]
    pkFields*: seq[string]
    uniqueFieldSets*: seq[UniqueFields]
    indexes*: Indexes
    getFunctions*: seq[GetFunction]
    relationships*: seq[Relationship]
    updateFunctions*: seq[UpdateFunction]


  Models* = seq[Model]


  ModuleSetting* = object
    package*: PackageYAML
    module*: Module

    routeFiles*: seq[string]
    routes*: RoutesYAML


  ModuleSettings* = seq[ModuleSetting]


  LibraryYAML* = object
    shortName*: string
    package*: string
    description*: string
    basePath*: string
    srcPath*: string


  LibrariesYAML* = seq[LibraryYAML]


  Media* = ref object of RootObj
    name*: string
    `type`*: string
    version*: string
    url*: string


  MediaList* = seq[Media]


  WebArtifact* = ref object of RootObj
    artifact*: string
    pathName*: string

    shortName*: string
    package*: string
    nameInCamelCase*: string
    nameInPascalCase*: string
    nameInSnakeCase*: string

    description*: string
    confPath*: string
    basePath*: string
    srcPath*: string
    srcRelativePath*: string
    mediaList*: MediaList

    routes*: Routes

    # Modules that are in-use by the WebApp
    modules*: Modules


  WebArtifacts* = seq[WebArtifact]


  WebAppYAML* = object
    shortName*: string
    # package*: string
    description*: string
    basePath*: string
    srcPath*: string
    mediaList*: MediaList


  WebAppsYAML* = seq[WebAppYAML]


  WebServiceYAML* = object
    shortName*: string
    # package*: string
    description*: string
    basePath*: string
    srcPath*: string


  WebServicesYAML* = seq[WebServiceYAML]


  WorkflowYAML* = object
    name*: string
    view*: string
    inputs*: seq[string]
    actions*: seq[string]
    outputs*: seq[string]
    directions*: Table[string, string]


  WorkflowsYAML* = seq[WorkflowYAML]


  TmpDictYAML* = Table[string, string]


  GeneratorInfo* = ref object of RootObj
    refresh*: bool
    status*: char
    errorMessage*: string

    tmpDict*: TmpDictYAML
    envTable*: Table[string, string]

    appName*: string
    appNameInSnakeCase*: string
    appNameInUpperSnakeCase*: string
    appNameInLowerSnakeCase*: string
    package*: string

    libraries*: LibrariesYAML
    webArtifacts*: WebArtifacts
    modules*: Modules

    packages*: Packages
    moduleSettings*: ModuleSettings

    models*: Models

