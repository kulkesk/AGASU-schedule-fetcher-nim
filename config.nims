#!/usr/bin/env nim

switch "define", "ssl"

if hostOS == "android":
    switch "define", "nimDisableCertificateValidation"
