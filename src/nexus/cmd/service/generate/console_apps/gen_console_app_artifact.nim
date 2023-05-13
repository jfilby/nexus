import os


proc generateConsoleAppArtifact*(
       basePath: string,
       generatorInfo: var GeneratorInfo) =

  generateLibraryArtifact(
    basePath,
    generatorInfo)

