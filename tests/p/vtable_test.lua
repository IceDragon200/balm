local Luna = require("balm/luna")
-- local M = require("balm/p/vtable")

local case = Luna:new("balm.p.VTable")

case:describe("#initialize/1", function (t2)
  t2:test("can initialize", function (t3)
    -- local s = M:new({})
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
