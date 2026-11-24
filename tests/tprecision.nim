import ../orgtables

doAssert toOrgLine([1.25'f32, 2.5'f32], precision = 3) == "| 1.250 | 2.500 |\n"
let row = (value: 1.25'f32, count: 3)
doAssert toOrgTable([row], precision = 3) == "| value | count |\n| 1.250 | 3 |\n"
doAssert toOrgLine([0.000125'f32]) == toOrgLine([0.000125'f64])
