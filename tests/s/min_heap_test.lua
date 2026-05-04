local Luna = require("balm/luna")
local m = require("balm/s/list")
local m = require("balm/s/min_heap")

local case = Luna:new("balm.MinHeap")

case:describe("&new/0", function (t2)
  t2:test("can initialize a new minheap with no arguments", function (t3)
    local subject = m:new()
    t3:assert(subject)
  end)
end)

case:describe("#insert/2", function (t2)
  t2:test("can insert an item into the heap", function (t3)
    local subject = m:new()

    subject:insert("World", 3)
    subject:insert("Joe", 1)
    subject:insert("Hello", 2)

    local item
    local weight

    item, weight = subject:pop_min()

    t3:assert_eq(item, "Joe")
    t3:assert_eq(weight, 1)

    item, weight = subject:pop_min()

    t3:assert_eq(item, "Hello")
    t3:assert_eq(weight, 2)

    item, weight = subject:pop_min()

    t3:assert_eq(item, "World")
    t3:assert_eq(weight, 3)
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
