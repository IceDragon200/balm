local BIT_TABLE = assert(require("balm/u/bit").BIT_TABLE)
local floor = assert(math.floor)
local max = assert(math.max)
local min = assert(math.min)

--- @namespace balm.m.pack
local m = {}

--- @since "2026.6.2"
--- @spec pack_v2(bits: Number, x: Number, y: Number): Number
function m.pack_v2(bits, x, y)
  assert(bits > 1 and bits < 55)
  assert(bits % 2 == 0)
  local hb = floor(bits / 2)
  local s = BIT_TABLE[hb - 1]
  local sb = BIT_TABLE[hb]
  local ux = s + min(max(floor(x), -s), s - 1)
  local uy = s + min(max(floor(y), -s), s - 1)
  return uy * sb + ux
end

--- @since "2026.6.2"
--- @spec unpack_v2(bits: Number, packed: Number): (x: Number, y: Number)
function m.unpack_v2(bits, packed)
  assert(bits > 1 and bits < 55)
  assert(bits % 2 == 0)
  local hb = floor(bits / 2)
  local s = BIT_TABLE[hb - 1]
  local sb = BIT_TABLE[hb]
  local x = floor(packed % sb) - s
  local y = floor(floor(packed / sb) % sb) - s
  return x, y
end

return m
