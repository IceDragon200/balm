local Luna = require("balm/luna")
local m = require("balm/m/easers")

local case = Luna:new("balm.m.easers")

for name, func in pairs(m) do
  case:describe(name, function (t2)
    case:test("execute", function (t3)
      for i = 1,1000 do
        t3:assert(func(i / 1000))
      end
    end)
  end)
end

case:execute()
case:display_stats()
case:maybe_error()
