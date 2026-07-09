local Luna = require("balm/luna")
local M = require("balm/s/ordered_set")

local case = Luna:new("balm.s.OrderedSet")

case:describe("#initialize/0", function (t2)
  t2:test("can initialize an empty set", function (t3)
    local subject = M:new()

    t3:assert(subject:is_empty())
    t3:assert_eq(0, subject:size())
  end)
end)

case:describe("#initialize/1", function (t2)
  t2:test("can initialize an ordered set from a table", function (t3)
    local subject = M:new({ 3, 2, 1 })

    t3:refute(subject:is_empty())
    t3:assert_eq(3, subject:size())

    t3:assert_eq(1, subject:get(1))
    t3:assert_eq(2, subject:get(2))
    t3:assert_eq(3, subject:get(3))
  end)
end)

case:describe("#insert/1+", function (t2)
  t2:test("can insert an item into the set", function (t3)
    local subject = M:new({ 3, 2, 1 })
    t3:assert_eq(3, subject:size())
    subject:insert(0)
    subject:insert(4)
    t3:assert_eq(5, subject:size())
    t3:assert_eq(0, subject:get(1))
    t3:assert_eq(4, subject:get(5))
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
