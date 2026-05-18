local table_freeze = assert(require("balm/m/table").freeze)

local IMIN = {}
local IMAX = {}
local UMIN = {}
local UMAX = {}
for i = 1,54 do
  if i > 1 then
    IMIN[i] = -math.pow(2, i - 1)
    IMAX[i] = math.pow(2, i - 1) - 1
  end
  UMIN[i] = 0
  UMAX[i] = math.pow(2, i) - 1
end

return table_freeze({
  IMIN = table_freeze(IMIN),
  IMAX = table_freeze(IMAX),
  UMIN = table_freeze(UMIN),
  UMAX = table_freeze(UMAX),
})
