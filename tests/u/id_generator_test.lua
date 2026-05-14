local Luna = require("balm/luna")
local Subject = require("balm/u/id_generator")

local case = Luna:new("balm.u.IDGenerator")

case:describe("#initialize/1", function (t2)
  t2:test("can initialize an id generator", function (t3)
    local a = Subject:new()
    t3:assert(a)
  end)
end)

case:describe("#next/1", function (t2)
  t2:test("can generate an id and set a vanity_id", function (t3)
    local a = Subject:new()

    local id = a:next()
    t3:assert_eq(id, 1)
    id = a:next("vanity")
    t3:assert_eq(id, 2)
    t3:assert_eq(a:get_vanity(2), "vanity")
    t3:assert_eq(a:get_id("vanity"), 2)
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
