local Luna = require("balm/luna")
local M = require("balm/s/opall")

local case = Luna:new("balm.s.OPALL")

case:describe("&new/0", function (t2)
  t2:test("can initialize a new OPALL with no arguments", function (t3)
    local subject = M:new()
    t3:assert(subject)
  end)
end)

case:describe("#merge/1", function (t2)
  t2:test("can merge two OPALLs together", function (t3)
    local s = M:new()
    local s2 = M:new()

    s:insert("Hello", 0)
    s:insert("Goodbye", 2)
    s2:insert("World", 1)
    s2:insert("Universe", 3)

    s:merge(s2)

    local result = s:reduce({}, function (entry, _weight, acc)
      table.insert(acc, entry)
      return acc
    end)

    t3:assert_table_eq({ "Hello", "World", "Goodbye", "Universe" }, result)
  end)
end)

case:describe("ops", function (t2)
  t2:test("can push a value to the list", function (t3)
    local subject = M:new()

    subject:insert({ 1, 2, 3 }, 2)
    t3:assert_eq(subject:size(), 1)
    subject:insert({ "A", "B", "C" }, 1)
    t3:assert_eq(subject:size(), 2)
    subject:insert({ "X", "Y", "Z" }, 3)
    t3:assert_eq(subject:size(), 3)
    subject:insert(true, 4)
    t3:assert_eq(subject:size(), 4)

    local head = subject.next
    t3:assert_matches(head, {data = { "A", "B", "C" }})
    head = head.next
    t3:assert_matches(head, {data = { 1, 2, 3 }})
    head = head.next
    t3:assert_matches(head, {data = { "X", "Y", "Z" }})
    head = head.next
    t3:assert_matches(head, {data = true})
    t3:assert_eq(head.next, false)

    t3:assert_matches(subject:pop_at(-1), {data = true})
    t3:assert_eq(subject:size(), 3)
    t3:assert_matches(subject:pop_at(2), {data = { 1, 2, 3 }})
    t3:assert_eq(subject:size(), 2)

    subject:clear()

    t3:assert_eq(subject:size(), 0)
    t3:assert_eq(subject.next, false)
  end)
end)

case:describe("fuzz", function (t2)
  t2:test("can handle continous insert and ordering", function (t3)
    local subject = M:new()

    for i = 1,100 do
      local size = 6+math.random(120)
      for x = 1,size do
        local weight = math.random(-100, 100)
        subject:insert(x, weight)
      end
      t3:assert_eq(subject:size(), size)

      local prev = subject.next
      local head = prev.next
      for x = 1,size-1 do
        t3:assert(prev.weight <= head.weight)
        prev = head
        head = prev.next
      end
      t3:assert_eq(head, false)
      subject:clear()
      t3:assert_eq(subject:size(), 0)
    end
  end)

  t2:test("merge correctly handles randomize source", function (t3)
    local src = {}
    local n = 100
    for i = 1,n do
      src[i] = math.random(1, 120)
    end

    local a = M:new()
    local b = M:new()

    for i = 1,n do
      if math.random(2) == 1 then
        a:insert(src[i], i)
      else
        b:insert(src[i], i)
      end
    end

    a:merge(b)

    local result = a:reduce({}, function (entry, _weight, acc)
      table.insert(acc, entry)
      return acc
    end)

    t3:assert_table_eq(src, result)
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
