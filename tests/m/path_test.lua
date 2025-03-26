local Luna = require("balm/luna")
local m = require("balm/m/path")

local case = Luna:new("balm.m.path")

case:describe("join/+", function (t2)
  t2:test("can join a path", function (t3)
    t3:assert_eq("a/b/c", m.join("a", "b", "c"))
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
