import std/httpclient
import json
import uri
import strformat
from strutils import parseInt
from times import parse, DateTime, format, TimeFormatParseError, initDateTime


type 
    Subject = object
        date: DateTime
        week_number: int
        week_day: string
        pair: int
        signature: string
        sub_group: string
        classroom: string
        classroom_building: string
        subject: string
        prim: string
        study_type: string
        group_name: string

 
proc `$`*(s: Subject): string=
    var new_s = ""
    new_s.add("{")
    new_s.add(
        fmt"""

    date: {$s.date.format("dd'.'MM'.'YYYY")},
    week_number: {$s.week_number},
    week_day: "{$s.week_day}",
    pair: {$s.pair},
    signature: "{$s.signature}",
    sub_group: "{$s.subgroup}",
    classroom: "{$s.classroom}",
    classroom_building: "{$s.classroom_building}",
    subject: "{$s.subject}",
    prim: "{$s.prim}",
    study_type: "{$s.study_type}",
    group_name: "{$s.group_name}",
"""
    )
    new_s.add("}")
    return new_s


func remove_extra_spaces(s:string): string =
    ##[
        Usefull for deleting extra spaces that goes one after another
        returns string without extra spaces
    ]##
    if s.len == 0: return ""
    var new_s = newStringOfCap(s.len)
    var space = false
    for character in s:
        if character == ' ':
            if space:
                continue
            elif not(space):
                space = true
        elif character != ' ':
            if space:
                new_s.add(" ")
                space = false
            new_s.add character
    return new_s


proc json_to_subject(json_subjects:JsonNode): seq[Subject] =
    var return_result = newSeqOfCap[Subject](json_subjects.len) 
    for json_subject in json_subjects:
        var subject = Subject()
        subject.date = json_subject["date"].getStr("").parse("dd'.'MM'.'yy")
        subject.week_number = json_subject["week_number"].getStr("0").parseInt()
        subject.week_day = json_subject["week_day"].getStr("")
        subject.pair = json_subject["pair"].getStr("").parseInt()
        subject.signature = json_subject["signature"].getStr("").remove_extra_spaces()
        subject.subgroup = json_subject["sub_group"].getStr("")
        subject.classroom = json_subject["classroom"].getStr("").remove_extra_spaces()
        subject.classroom_building = json_subject["classroom_building"].getStr("").remove_extra_spaces()
        subject.subject = json_subject["subject"].getStr("").remove_extra_spaces()
        subject.prim = json_subject["prim"].getStr("").remove_extra_spaces()
        subject.study_type = json_subject["study_type"].getStr("").remove_extra_spaces()
        subject.group_name = json_subject["group_name"].getStr("").remove_extra_spaces()

        return_result.add(subject)
    return return_result
    


proc main()=
    var client = newHttpClient()
    var url = parseUri("https://api.xn--80aai1dk.xn--p1ai/api/") / "schedule" ?
                        {"range": "3", "subdivision_cod": "2", "group_name": "4562"}
    var subjects = client.getContent($url).parseJson().json_to_subject()
    for subject in subjects:
        echo $subject

if isMainModule:
    main()
