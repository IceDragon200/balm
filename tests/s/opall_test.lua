local Luna = require("balm/luna")
local m = require("balm/s/opall")

local case = Luna:new("balm.OPALL")

case:describe("&new/0", function (t2)
  t2:test("can initialize a new OPALL with no arguments", function (t3)
    local subject = m:new()
    t3:assert(subject)
  end)
end)

case:describe("ops", function (t2)
  t2:test("can push a value to the list", function (t3)
    local subject = m:new()

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
    local subject = m:new()

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
end)

case:execute()
case:display_stats()
case:maybe_error()
