local table_freeze = assert(require("balm/m/table").freeze)

local IMIN = {}
local IMAX = {}
local UMIN = {}
local UMAX = {}
local FMIN = {}
local FMAX = {}

for i = 1,54 do
  if i > 1 then
    IMIN[i] = -math.pow(2, i - 1)
    IMAX[i] = math.pow(2, i - 1) - 1
  end
  UMIN[i] = 0
  UMAX[i] = math.pow(2, i) - 1
end

FMAX[32] = (2 - math.pow(2, -23)) * math.pow(2, 127)
FMAX[64] = (2 - math.pow(2, -52)) * math.pow(2, 1023)
FMIN[32] = -FMAX[32]
FMIN[64] = -FMAX[64]

return table_freeze({
  IMIN = table_freeze(IMIN),
  IMAX = table_freeze(IMAX),
  UMIN = table_freeze(UMIN),
  UMAX = table_freeze(UMAX),
  FMIN = table_freeze(FMIN),
  FMAX = table_freeze(FMAX),
})
