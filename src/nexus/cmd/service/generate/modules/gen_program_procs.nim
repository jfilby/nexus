import os, strformat


proc generateProgramProcs*(module: Module) =

  let
    modulePath = &"{module.srcPath}{DirSep}service{DirSep}module"
    filename = &"{modulePath}{DirSep}program.nim"

    str = "import locks, options\n"
          "import nexus/core/data_access/db_conn\n" &
          "\n" &
          "\n" &
          "proc deinitNexusProgram*() =\n" &
          "\n" &
          "  dbConnLock = some(Lock())\n" &
          "\n" &
          "  deinitLock(dbConnLock.get)\n"
          "\n" &
          "\n" &
          "proc initNexusProgram*() =\n" &
          "\n" &
          "  dbConnLock = some(Lock())\n" &
          "\n" &
          "  initLock(dbConnLock.get)\n"
          "\n" &
          "\n"

  writeFile(filename,
            str)

