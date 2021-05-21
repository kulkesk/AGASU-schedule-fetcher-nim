import strutils
import strformat


let postfix = if defined(release): "release" else: "debug"

let
    project_directory = projectDir()
    target = @[project_directory, "/target/", projectName(), "_", postfix].join()
    cache = @[project_directory, "/cache/", projectName(), "_", postfix, "/"].join()
    source = @[project_directory, "/src/main.nim"].join()


task build, "builds binary":
    if buildOS == "android":
        switch "define", "nimDisableCertificateValidation"
    setCommand "c"
    switch "define", "ssl"
    switch "o", target
    switch "nimcache", cache

task clean_cache, "cleans cache":
    exec &"rm -rf {cache}"

task clean_target, "cleans target":
    exec &"rm -rf {target}"
