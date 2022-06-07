import chronicles, options, tables
import filename_utils


proc filenameUtilsTests*() =

  # Unix
  let unixHome = "/home/myuser"
  var testUnixPath1 = "$HOME/my/dir"

  var testEnvs: Table[string, string]
  testEnvs["HOME"] = unixHome

  discard parseFilenameExpandEnvVars(
            testUnixPath1,
            some(testEnvs))

  let expectedUnixResolvedPath = "/home/myuser/my/dir"

  if testUnixPath1 != expectedUnixResolvedPath:

    info "filenameUtilsTests()",
      testUnixPath1 = testUnixPath1,
      expectedUnixResolvedPath = expectedUnixResolvedPath

    raise newException(
            ValueError,
            "testUnixPath1 != expectedUnixResolvedPath")

  # Windows
  let windowsHome = "C:\\MyHome"
  var testWindowsPath1 = "%HOME%\\my\\dir"

  testEnvs["HOME"] = windowsHome

  discard parseFilenameExpandEnvVars(
            testWindowsPath1,
            some(testEnvs))

  let expectedWindowsResolvedPath = "C:\\MyHome\\my\\dir"

  if testWindowsPath1 != expectedWindowsResolvedPath:

    info "filenameUtilsTests()",
      testWindowsPath1 = testWindowsPath1,
      expectedWindowsResolvedPath = expectedWindowsResolvedPath

    raise newException(
            ValueError,
            "testWindowsPath1 != expectedWindowsResolvedPath")

