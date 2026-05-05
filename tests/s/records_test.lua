local Luna = require("balm/luna")
local m = require("balm/s/records")

local case = Luna:new("balm.Records")

case:describe("&new/0", function (t2)
  t2:test("can initialize a new record head with headers", function (t3)
    local subject = m:new("x", "y", "z")
    t3:assert(subject)
    t3:assert_eq(subject:col(1), "x")
    t3:assert_eq(subject:col(2), "y")
    t3:assert_eq(subject:col(3), "z")
  end)
end)

case:describe("#new/0", function (t2)
  t2:test("can create a new record list", function (t3)
    local head = m:new("x", "y", "z")
    local list = head:new()
    t3:assert(list)
  end)
end)

case:describe("#push/0 and #pop/0", function (t2)
  t2:test("can push and pop rows", function (t3)
    local head = m:new("x", "y", "z")
    local list = head:new()

    list:push({
      x = "a",
      y = "b",
      z = "c"
    })

    t3:assert_eq("a", list:get_cell(1, "x"))
    t3:assert_eq("b", list:get_cell(1, "y"))
    t3:assert_eq("c", list:get_cell(1, "z"))

    t3:assert_eq(list:size(), 1)
    t3:assert_eq(list:datasize(), 3)

    t3:assert_table_eq({
      x = "a",
      y = "b",
      z = "c",
    }, list:pop())

    t3:assert_eq(list:size(), 0)
    t3:assert_eq(list:datasize(), 0)

    t3:assert_eq(nil, list:pop())

    t3:assert_eq(list:size(), 0)
    t3:assert_eq(list:datasize(), 0)

    list:push({
      x = "a",
      y = "b",
      z = "c"
    })

    t3:assert_eq(list:size(), 1)
    t3:assert_eq(list:datasize(), 3)

    list:push({
      x = "d",
      y = "e",
      z = "f"
    })

    t3:assert_eq(list:size(), 2)
    t3:assert_eq(list:datasize(), 6)

    t3:assert_eq("a", list:get_cell(1, "x"))
    t3:assert_eq("b", list:get_cell(1, "y"))
    t3:assert_eq("c", list:get_cell(1, "z"))

    t3:assert_eq("d", list:get_cell(2, "x"))
    t3:assert_eq("e", list:get_cell(2, "y"))
    t3:assert_eq("f", list:get_cell(2, "z"))

    t3:assert_table_eq({
      x = "d",
      y = "e",
      z = "f",
    }, list:pop())

    t3:assert_eq(list:size(), 1)
    t3:assert_eq(list:datasize(), 3)

    t3:assert_table_eq({
      x = "a",
      y = "b",
      z = "c",
    }, list:pop())

    t3:assert_eq(list:size(), 0)
    t3:assert_eq(list:datasize(), 0)
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
