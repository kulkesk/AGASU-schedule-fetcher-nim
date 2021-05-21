
# import strutils
# import system
import system.nimscript

switch "define", "ssl"

task build, "builds stuff":
    discard

if hostOS == "android":
    switch "define", "nimDisableCertificateValidation"
