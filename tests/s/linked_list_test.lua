local Luna = require("balm/luna")
local m = require("balm/s/linked_list")
local List = require("balm/s/list")

local case = Luna:new("balm.s.LinkedList")

case:describe("&new/0", function (t2)
  t2:test("can initialize a new linked list with no arguments", function (t3)
    local ll = m:new()
    t3:assert(ll)
  end)
end)

case:describe("&new/1", function (t2)
  t2:test("can initialize from a POLT", function (t3)
    local ll = m:new({ 1, 2, 3 })

    t3:assert_eq(1, ll:first())
    t3:assert_eq(3, ll:last())
  end)

  t2:test("can initialize from another LinkedList", function (t3)
    local l1 = m:new({ 1, 2, 3 })
    local l2 = m:new(l1)

    t3:assert_eq(1, l2:first())
    t3:assert_eq(3, l2:last())

    l2:push(4)

    t3:assert_eq(1, l1:first())
    t3:assert_eq(3, l1:last())

    t3:assert_eq(1, l2:first())
    t3:assert_eq(4, l2:last())
  end)
end)

case:describe("#copy/0", function (t2)
  t2:test("can copy a linked list", function (t3)
    local ll = m:new({ 1, 2, 3 })
    local other_ll = ll:copy()

    t3:refute_eq(ll, other_ll)
    t3:assert_table_eq(ll:to_table(), other_ll:to_table())
  end)
end)

case:describe("#size/0", function (t2)
  t2:test("can correctly report the size of an empty list", function (t3)
    local ll = m:new()

    t3:assert_eq(0, ll:size())
  end)

  t2:test("can correctly report the size of a populated list", function (t3)
    local ll = m:new({ "a", "b", "c" })

    t3:assert_eq(3, ll:size())
  end)
end)

case:describe("#shift/0", function (t2)
  t2:test("removes the first item and returns it", function (t3)
    local ll = m:new({ "a", "b", "c" })

    t3:assert_eq(3, ll:size())

    t3:assert_eq("a", ll:shift())
    t3:assert_eq(2, ll:size())

    t3:assert_eq("b", ll:shift())
    t3:assert_eq(1, ll:size())

    t3:assert_eq("c", ll:shift())
    t3:assert_eq(0, ll:size())

    t3:assert_eq(nil, ll:shift())
    t3:assert_eq(0, ll:size())
  end)
end)

case:describe("#shift/1", function (t2)
  t2:test("removes requested number of items from the list and returns them", function (t3)
    local ll = m:new({ "a", "b", "c" })

    t3:assert_table_eq({ "a", "b" }, ll:shift(2))
    t3:assert_table_eq({ "c" }, ll:shift(2))
  end)
end)

case:describe("#push/1+", function (t2)
  t2:test("can push values unto the linked list", function (t3)
    local ll = m:new()

    ll:push("a")
    t3:assert_eq("a", ll:first())
    t3:assert_eq("a", ll:last())

    ll:push("b")
    t3:assert_eq("a", ll:first())
    t3:assert_eq("b", ll:last())

    ll:push("c")
    t3:assert_eq("a", ll:first())
    t3:assert_eq("c", ll:last())
  end)
end)

case:describe("#get/1", function (t2)
  t2:test("can retrieve a value at the specified position", function (t3)
    local ll = m:new({ "a", "b", "c" })

    t3:assert_eq(nil, ll:get(0))
    t3:assert_eq("a", ll:get(1))
    t3:assert_eq("b", ll:get(2))
    t3:assert_eq("c", ll:get(3))
    t3:assert_eq(nil, ll:get(4))
  end)
end)

case:describe("#each/1", function (t2)
  t2:test("can iterate an empty list", function (t3)
    local ll = m:new()

    local touched = false
    ll:each(function (_item, _node)
      touched = true
    end)

    t3:refute(touched)
  end)

  t2:test("can iterate over a list", function (t3)
    local ll = m:new({ 1, 2, 3 })

    local seen = {}
    ll:each(function (item, _node)
      table.insert(seen, item)
    end)

    t3:assert_table_eq({ 1, 2, 3 }, seen)
  end)
end)

case:describe("#each/0", function (t2)
  t2:test("will return a valid lua iterator without a callback", function (t3)
    local ll = m:new({ 1, 2, 3 })

    local seen = {}
    local i = 0
    for _node, item in ll:each() do
      i = i + 1
      seen[i] = item
    end

    t3:assert_table_eq({ 1, 2, 3 }, seen)
  end)
end)

case:describe("#to_table/0", function (t2)
  t2:test("can return a table with the underlying data", function (t3)
    local ll = m:new({ 1, 2, 3 })

    local t = ll:to_table()

    t3:assert_table_eq({ 1, 2, 3 }, t)
  end)
end)

case:describe("#to_linked_list/0", function (t2)
  t2:test("should return self", function (t3)
    local ll = m:new({ "a", "b", "c" })
    local other_ll = ll:to_linked_list()

    --- Should be the same ll
    t3:assert_eq(ll, other_ll)
  end)
end)

case:describe("#to_list/0", function (t2)
  t2:test("can convert given linked list to a regular list", function (t3)
    local ll = m:new({ 1, 2, 3 })

    local l = ll:to_list()

    t3:assert(l:is_instance_of(List))
    t3:refute_eq(ll, l)
    t3:assert_table_eq({ 1, 2, 3 }, l:to_table())
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
