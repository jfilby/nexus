import options, sets, tables


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
    appNameSnakeCase*: string
    appNameUpperSnakeCase*: string
    appNameLowerSnakeCase*: string

    moduleName*: string
    moduleNameSnakeCase*: string
    moduleNameUpperSnakeCase*: string
    moduleNameLowerSnakeCase*: string

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

    camelcaseName*: string
    pascalCaseName*: string
    snakeCaseName*: string

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

    camelcaseName*: string
    pascalCaseName*: string
    snakeCaseName*: string
    snakeCaseShortName*: string

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
    parameters*: RouteParametersYAML
    defaults*: seq[DefaultsField]
    modelFields*: ModelFieldsForRouteYAML

    groupSnakeCaseName*: string
    nameCamelCaseName*: string
    nameSnakeCaseName*: string

    pagesImport*: string


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

    baseCamelcaseName*: string
    camelcaseName*: string
    camelcaseNamePlural*: string

    basePascalCaseName*: string
    pascalCaseName*: string
    pascalCaseNamePlural*: string

    baseSnakeCaseName*: string
    snakeCaseName*: string
    snakeCaseNamePlural*: string
    snakeCaseRefSuffix*: string

    # Short hash for forms
    shortHash*: string

    # Named names are different when an alias is used
    namedName*: string
    namedNamePlural*: string
    namedCamelcaseName*: string
    namedCamelcaseNamePlural*: string
    namedPascalCaseName*: string
    namedPascalCaseNamePlural*: string
    namedSnakeCaseName*: string
    namedSnakeCaseNamePlural*: string

    packageImport*: string
    moduleImport*: string

    # Fields pkName and pkSnakeCaseName are only used for single-field PKs
    pkName*: string
    pkCamelCaseName*: string
    pkSnakeCaseName*: string
    pkModelDCamelCaseNames*: string
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


  WebTypes* = enum
    webApp,
    webService


  WebApp* = ref object of RootObj
    appOrService*: WebTypes

    shortName*: string
    package*: string
    camelCaseName*: string
    pascalCaseName*: string
    snakeCaseName*: string

    description*: string
    confPath*: string
    basePath*: string
    srcPath*: string
    srcRelativePath*: string
    mediaList*: MediaList

    routes*: Routes

    # Modules that are in-use by the WebApp
    modules*: Modules


  WebApps* = seq[WebApp]


  WebAppYAML* = object
    shortName*: string
    # package*: string
    description*: string
    basePath*: string
    srcPath*: string
    mediaList*: MediaList


  WebAppsYAML* = seq[WebAppYAML]


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
    appNameSnakeCase*: string
    appNameUpperSnakeCase*: string
    appNameLowerSnakeCase*: string
    package*: string

    libraries*: LibrariesYAML
    webApps*: WebApps
    modules*: Modules

    packages*: Packages
    moduleSettings*: ModuleSettings

    models*: Models

