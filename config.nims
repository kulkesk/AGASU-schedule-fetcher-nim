import strutils
import strformat


let postfix = if defined(release): "release" else: "debug"

let
    project_directory = projectDir()
    target_directory = @[project_directory, "/target/"].join()
    target = @[target_directory, projectName(), "_", postfix].join()
    cache_main_directory = @[project_directory, "/cache/"].join()
    cache = @[cache_main_directory, projectName(), "_", postfix, "/"].join()
    source = @[project_directory, "/src/main.nim"].join()


task build, "builds binary":
    if buildOS == "android":
        switch "define", "nimDisableCertificateValidation"
    setCommand "c"
    switch "define", "ssl"
    switch "o", target
    switch "nimcache", cache

task clean_cache, "cleans cache":
    hint("Conf", false)
    exec &"rm -rf {cache_main_directory}"

task clean_target, "cleans target":
    hint("Conf", false)
    exec &"rm -rf {target_directory}"

task run, "runs project":
    hint("Conf", false)
    exec target
