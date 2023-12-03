import std / [strutils, strformat, sequtils]

proc formatFloat(x: SomeFloat, precision: int): string =
  if x < 1e-3:
    result = formatBiggestFloat(x, ffScientific, precision = precision)
  else:
    result = formatBiggestFloat(x, ffDecimal, precision = precision)

proc toOrgLine*[T: tuple](x: T, precision = 2): string =
  var vals = newSeq[string]()
  for f, v in fieldPairs(x):
    when typeof(v) is float:
      vals.add formatFloat(v, precision)
    else:
      vals.add $v
  result = "| " & vals.join(" | ") & " |\n"

proc toOrgLine*[T](s: openArray[T], precision = 2): string =
  when T is float:
    "| " & s.mapIt(it.formatFloat(precision)).join(" | ") & " |\n"
  else:
    "| " & s.mapIt($it).join(" | ") & " |\n"

proc toOrgHeader*[T: tuple](_: typedesc[T]): string =
  var keys = newSeq[string]()
  var tmp: T
  for f, v in fieldPairs(tmp):
    keys.add f
  result = toOrgLine(keys)

proc toOrgTable*[T: tuple](s: openArray[T], precision = 2): string =
  result.add toOrgHeader(T)
  for x in s:
    result.add toOrgLine(x, precision)
