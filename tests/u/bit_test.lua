local Luna = require("balm/luna")
local Subject = require("balm/u/bit")

local case = Luna:new("balm.u.bit")

for key, value in pairs(Subject._imports) do
  print("BIT", key, value)
end

case:execute()
case:display_stats()
case:maybe_error()
