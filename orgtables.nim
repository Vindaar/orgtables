import std / [strutils, strformat, sequtils]

proc formatFloat(x: SomeFloat, precision: int): string =
  if abs(x) < 1e-3 and x != 0.0:
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

proc formatOrgTable*(table: string): string =
  ## Reformats an org-mode table string to ensure proper column alignment.
  ## Each column will be padded to accommodate the widest element plus 2 spaces.

  # Split the table into lines
  let lines = table.strip().splitLines()
  if lines.len == 0:
    return ""

  # Parse the table into a matrix of cell values
  var cells: seq[seq[string]] = @[]
  for line in lines:
    # Skip non-table lines
    if not line.startsWith("|"):
      result.add(line & "\n")
      continue

    # Split by "|" and strip whitespace from each cell
    var rowCells: seq[string] = @[]
    let parts = line.split('|')

    # Process each cell (skipping first and last which are empty due to outer pipes)
    for i in 1..<parts.len-1:
      rowCells.add(parts[i].strip())

    cells.add(rowCells)

  # Calculate the maximum width for each column
  var colWidths: seq[int] = @[]
  for row in cells:
    for i, cell in row:
      if i >= colWidths.len:
        colWidths.add(cell.len)
      else:
        colWidths[i] = max(colWidths[i], cell.len)

  # Rebuild the table with proper spacing
  var formattedLines: seq[string] = @[]

  # Add the first row
  if cells.len > 0:
    var line = "|"
    for i, cell in cells[0]:
      line.add(" " & cell.alignLeft(colWidths[i]) & " |")
    formattedLines.add(line)

    # Add a separator row after the header
    var sepLine = "|"
    for i, width in colWidths:
      let suf = if i < colWidths.high: "+" else: "|"
      sepLine.add("-".repeat(width + 2) & suf)
    formattedLines.add(sepLine)

    # Add the remaining rows
    for i in 1..<cells.len:
      var line = "|"
      for j, cell in cells[i]:
        line.add(" " & cell.alignLeft(colWidths[j]) & " |")
      formattedLines.add(line)

  result = formattedLines.join("\n") & "\n"
