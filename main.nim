import std/httpclient
import json
import uri
import strformat
import tables, hashes
from strutils import parseInt, repeat, center
from unicode import runeLen
import times

type 
  Subject* = object
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

  # Schedule* = Table[DateTime, seq[Subject]]

 
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


func remove_extra_spaces*(s:string): string =
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


func hash*(v: DateTime): Hash =
  result = `$`(v).hash
  # debugEcho result


func grouping_subjects_by_days*(subjects: seq[Subject]): Table[DateTime, seq[Subject]]=
  ##[
      Groups subjects by their respective days, as they should be send to begin with
  ]##
  result  = initTable[DateTime, seq[Subject]]()
  for subject in subjects:
    result.mgetOrPut(subject.date, @[]).add(subject)


proc print_schedule*(schedule:Table[DateTime, seq[Subject]])=
  ##[
      Prints schedule in human readable form
  ]##

  var sep_between_days = "="
  var sep_between_subjs = "-"
  var lenght: int = 1

  for date, subjs in schedule:
    for subj in subjs:
      lenght = max(subj.subject.runeLen()+3, lenght)
      lenght = max(subj.classroom.runeLen(), lenght)
      lenght = max(subj.classroom_building.runeLen(), lenght)
      lenght = max(subj.prim.runeLen(), lenght)
      lenght = max(subj.study_type.runeLen(), lenght)
      lenght = max(subj.group_name.runeLen(), lenght)
      lenght = max(subj.signature.runeLen(), lenght)

  sep_between_days = sep_between_days.repeat(lenght)
  sep_between_subjs = sep_between_subjs.repeat(lenght)

  for date, subjs in schedule:
    echo sep_between_days
    var weekday_rus =  case weekday(date)
    of WeekDay.dMon: "Понедельник"
    of WeekDay.dTue: "Вторник"
    of WeekDay.dWed: "Среда"
    of WeekDay.dThu: "Четверг"
    of WeekDay.dFri: "Пятница"
    of WeekDay.dSat: "Суббота"
    of WeekDay.dSun: "Воскресенье"

    weekday_rus = weekday_rus.center(lenght)
    echo weekday_rus
    
    for subj in subjs:
      echo sep_between_subjs
      echo fmt"{subj.pair}){subj.subject}"
      echo "  ", subj.study_type
      echo subj.signature
      if subj.prim.len() > 0:
        echo subj.prim
      if subj.sub_group.len() > 0:
        echo "подгруппа: ", subj.sub_group
      echo subj.classroom, ' ', subj.classroom_building
    echo sep_between_subjs


proc json_to_subject*(json_subjects:JsonNode): seq[Subject] =
  ##[
      magically turn json response from server to a normal list of objects that represents data
  ]##
  result = newSeqOfCap[Subject](json_subjects.len)
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

    result.add(subject)


proc main()=
  var client = newHttpClient()
  var url = parseUri("https://api.xn--80aai1dk.xn--p1ai/api/") / "schedule" ?
                    {"range": "3", "subdivision_cod": "2", "group_name": "4562"}
  var subjects = client.getContent($url).parseJson().json_to_subject()

  subjects.grouping_subjects_by_days().print_schedule
  echo "Нажми enter что бы закрыть окно"
  discard readLine(stdin)

when isMainModule:
  main()
