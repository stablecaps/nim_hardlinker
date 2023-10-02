import std/os
import std/osproc
import std/strutils
import std/strformat
import docopt


let doc = """
Hardlinker: A program that recursively searches through a source directory
for files and creates hardlinks to them in a destination directory with
identical paths to that in the source folder.

Usage:
  hardlinker (--sourcedir=<sourcedir>) (--destdir=<destdir>)

Options:
  -h --help               Show this screen.
  -v --version            Show version.
  -s --sourcedir=<path>   Source directory conatining files to hardlink
  -d --destdir=<path>     Destination directory in which hardlinks => source files are created
"""

proc quitIfDirNotExist(mydir: string) =
  if not dirExists(mydir):
    echo fmt"Directory does not exist: <{mydir}>"
    echo "Exiting.."
    quit(1)

proc mkdirIfNone(mydir: string) =
  if not existsDir(mydir):
    createDir(mydir)

proc getFilePathVars(myPath, sourceDir, destDir: string): (string, string, string) =
  var filePath = rsplit(myPath, '/', 1)
  var dirPath = filePath[0]
  var src_path = quoteShellPosix(fmt"{sourceDir}/{myPath}")
  var dst_path = quoteShellPosix(fmt"{destDir}/{myPath}")
  echo "src_path: ", src_path
  echo "dst_path: ", dst_path

  result = (dirPath, src_path, dst_path)

proc hardlinkFile(src: string , dst: string) =
  # TODO: implement try/except to catch existing file
  let result = execProcess(fmt"ln {src} {dst}")
  echo "result: ", result



####################################
let args = docopt(doc, version="0.9.0")

echo "\nargs\n", args

let sourceDir: string = $args["--sourcedir"]
let destDir: string = $args["--destdir"]

quitIfDirNotExist(sourceDir)
quitIfDirNotExist(destDir)

#TODO: implement check to see if files are on same filesystem
echo fmt"\nRecursively Hardlinking files from src: {sourceDir} => dst: {destDir}"

var uniqDirPaths: seq[string]
var walkies: seq[string]

for subSrcDir1 in walkDirRec(sourceDir, relative=true):
  walkies.add(subSrcDir1)
  var (dirPath, src_path, dst_path) = getFilePathVars(subSrcDir1, sourceDir, destDir)

  # Use subprocess to leverage linux ln command to hardlink
  if uniqDirPaths.contains(dirPath):
    hardlinkFile(src_path, dst_path)
  else:
    uniqDirPaths.add(dirPath)
    mkdirIfNone(fmt"{destDir}/{dirPath}")
    hardlinkFile(src_path, dst_path)
  echo "\n"

echo "\nNumber of unique folders: ", uniqDirPaths.len
echo "\nNumber of files/dirs hardlinked: ", walkies.len


#https://nim-lang.org/docs/os.html#15