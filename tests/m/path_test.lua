local Luna = require("balm/luna")
local m = require("balm/m/path")

local case = Luna:new("balm.m.path")

case:describe("join/+", function (t2)
  t2:test("can join a path", function (t3)
    t3:assert_eq("a/b/c", m.join("a", "b", "c"))
  end)
end)

case:describe("extname/1", function (t2)
  t2:test("can return the extension name of a file", function (t3)
    t3:assert_eq(".lua", m.extname("a.lua"))
    t3:assert_eq(".xyz", m.extname("a.exe.xyz"))
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
