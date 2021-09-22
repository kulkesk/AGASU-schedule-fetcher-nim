import std/[os,
            strformat,
            osproc,
            streams]
import nake

let
  Arguments = "--gc:orc --passL:-static -d:ssl"
  ProjectDirectory = getAppDir()
  TargetDirectory = ProjectDirectory/"target"
  SourceDirectory = ProjectDirectory/"src"
  CacheDirectory = ProjectDirectory/"cache"

  TargetDirectoryDebug = TargetDirectory/"debug"
  TargetDirectoryRelease = TargetDirectory/"release"
  CacheDirectoryDebug = CacheDirectory/"debug"
  CacheDirectoryRelease = CacheDirectory/"release"

  SourceFile = SourceDirectory/"main.nim"

type SourceDirectoryError = object of CatchableError

proc create_needed_directories() =
  let directories: array[0..3, string] = [
    TargetDirectoryDebug, TargetDirectoryRelease,
    CacheDirectoryDebug, CacheDirectoryRelease
  ]
  if not dirExists(SourceDirectory):
    raise newException(SourceDirectoryError, fmt"Source directory ({SourceDirectory}) is abscent")
  for directory in directories: 
    createDir(directory)


task "check-dep", "checks dependencies and installs if needed":
  if fileExists(ProjectDirectory/"requirements.txt"):
    let nimble_exe = findExe("nimble")
    var 
      requirements: seq[string]
      installed_packages: seq[string]
      packages_to_install = newSeq[string](requirements.len)
    
    block getting_requirements_from_file:
      var requirements_file: File
      discard open(requirements_file, ProjectDirectory/"requirements.txt", fmRead)
      requirements = requirements_file.readAll.split("\n")
      requirements_file.close()

    block getting_list_of_installed_packages_from_nimble:
      var nimble_process = startProcess(nimble_exe, args=["list", "-i"])
      discard nimble_process.waitForExit()
      var nimble_stdout = nimble_process.outputStream().readAll()
      for line in nimble_stdout.split("\n"):
        var package = line.split("  ")[0] # TODO: use somehow version number that nimble spitsout with package
        if package.len != 0:
          installed_packages.add(package)
      nimble_process.close()

    block checking_if_requirements_installed:
      for requirement in requirements:
        if requirement notin installed_packages:
          packages_to_install.add(requirement)
    
    block installing_needed_packages:
      if packages_to_install.len > 0:
        shell(nimble_exe, "install", packages_to_install.join(" "))


proc build(release:bool=true, check_if_needs_refresh:bool=false) =
  var target_directory = if release: TargetDirectoryRelease else: TargetDirectoryDebug
  var cache_directory = if release: CacheDirectoryRelease else: CacheDirectoryDebug
  var comp_mode = if release: "release --opt:speed" else: "debug"
  create_needed_directories()
  runTask("check-dep")
  if needsRefresh(target_directory/"main", SourceFile) or not check_if_needs_refresh:
    shell(nimExe, "c", &"-d:{comp_mode}", &"--nimcache:{cache_directory}",
          Arguments, &"--outdir:{target_directory}", SourceFile)

proc run(release:bool=true) =
  build(release=release, check_if_needs_refresh=true)
  let binary = (if release:TargetDirectoryRelease else: TargetDirectoryDebug)/"main"
  shell(binary)


task "run-debug", "Runs debug binary":
  run(release=false)


task "run-release", "Runs release binary":
  run(release=true)

task "build-debug", "Builds binary in debug mode":
  build(release=false, check_if_needs_refresh=false)


task "build-release", "Builds binary in release mode":
  build(release=true, check_if_needs_refresh=false)

task defaultTask, "Compiles binary in debug mode":
  runTask("build-debug")
