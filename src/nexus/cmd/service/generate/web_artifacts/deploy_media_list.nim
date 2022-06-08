import chronicles, httpclient, os, osproc, strformat, strutils
import nexus/core/service/format/name_utils
import nexus/cmd/types/types


# Forward declarations
proc sourceBulma(
       media: Media,
       publicPath: string,
       webArtifact: WebArtifact)
proc sourceCustomBulmaCSS(
       media: Media,
       publicPath: string,
       webArtifact: WebArtifact)


# Code
proc deployMediaList*(webArtifact: WebArtifact) =

  debug "deployMediaList()",
    lenMediaList = $len(webArtifact.mediaList)

  let publicPath = &"{webArtifact.srcPath}{DirSep}public"

  if not dirExists(publicPath):
    createDir(publicPath)

  for media in webArtifact.mediaList:

    debug "deployMediaList(): media",
      `type` = media.type,
      name = media.name

    if media.`type` == "CSS Framework":

      if media.name == "Bulma":

        sourceBulma(
          media,
          publicPath,
          webArtifact)

        sourceCustomBulmaCSS(
          media,
          publicPath,
          webArtifact)


proc sourceBulma(
       media: Media,
       publicPath: string,
       webArtifact: WebArtifact) =

  let
    mediaName =
      getSnakeCaseName(
        &"{media.name}_{media.version}",
        replacePunctuation = false)

    mediaPath = &"{publicPath}{DirSep}{mediaName}"

  debug "sourceBulma()",
    mediaPath = mediaPath

  if not dirExists(mediaPath):

    echo &"creating media path: {mediaPath}"
    createDir(mediaPath)

    var client = newHttpClient()

    let
      pathSplit = split(media.url, DirSep)
      filename = &"{mediaPath}{DirSep}{pathSplit[len(pathSplit) - 1]}"
      zipBinary = client.getContent(media.url)

    echo &"writing downloaded file: {filename}"

    writeFile(filename,
              zipBinary)

    echo "unzipping file.."

    let ret = execCmd(&"unzip {filename} -d {mediaPath} > /dev/null")

    if ret != 0:
      echo "Failed to unzip downloaded file"
      quit(1)


proc sourceCustomBulmaCSS(
       media: Media,
       publicPath: string,
       webArtifact: WebArtifact) =

  let
    inFilename =
      getEnv("NEXUS_GENERATE_SRC_PATH") &
      &"{DirSep}service{DirSep}generate{DirSep}web_app{DirSep}bulma_custom.css"

    cssPath = &"{publicPath}/css"
    outFilename = &"{cssPath}/nexus_bulma.css"

    bulmaCustomCss = readFile(inFilename)

  if not dirExists(cssPath):
    createDir(cssPath)

  writeFile(outFilename,
            bulmaCustomCss)

