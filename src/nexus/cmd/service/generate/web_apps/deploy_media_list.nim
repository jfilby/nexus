import chronicles, httpclient, os, osproc, strformat, strutils
import nexus/core/service/format/name_utils
import nexus/cmd/types/types


# Forward declarations
proc sourceBulma(media: Media,
                 publicPath: string,
                 webApp: WebApp)
proc sourceCustomBulmaCSS(media: Media,
                          publicPath: string,
                          webApp: WebApp)


# Code
proc deployMediaList*(webApp: WebApp) =

  debug "deployMediaList()",
    lenMediaList = $len(webApp.mediaList)

  let publicPath = &"{webApp.srcPath}{DirSep}public"

  if not dirExists(publicPath):
    createDir(publicPath)

  for media in webApp.mediaList:

    debug "deployMediaList(): media",
      `type` = media.type,
      name = media.name

    if media.`type` == "CSS Framework":

      if media.name == "Bulma":

        sourceBulma(media,
                    publicPath,
                    webApp)

        sourceCustomBulmaCSS(media,
                             publicPath,
                             webApp)


proc sourceBulma(media: Media,
                 publicPath: string,
                 webApp: WebApp) =

  let
    mediaName = getSnakeCaseName(&"{media.name}_{media.version}",
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
      warn "sourceBulma(): failed to unzip downloaded file"


proc sourceCustomBulmaCSS(media: Media,
                          publicPath: string,
                          webApp: WebApp) =

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

