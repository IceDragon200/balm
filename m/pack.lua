local BIT_TABLE = assert(require("balm/u/bit").BIT_TABLE)
local floor = assert(math.floor)
local max = assert(math.max)
local min = assert(math.min)

--- @namespace balm.m.pack
local m = {}

--- @since "2026.6.2"
--- @spec pack_v2(bits: Number, a: Number, b: Number): Number
function m.pack_v2(bits, a, b)
  assert(bits > 1 and bits < 55)
  assert(bits % 2 == 0)
  local hb = floor(bits / 2)
  local s = BIT_TABLE[hb - 1]
  local sb = BIT_TABLE[hb]
  local ua = s + min(max(floor(a), -s), s - 1)
  local ub = s + min(max(floor(b), -s), s - 1)
  return ub * sb + ua
end

--- @since "2026.6.2"
--- @spec unpack_v2(bits: Number, packed: Number): (a: Number, b: Number)
function m.unpack_v2(bits, packed)
  assert(bits > 1 and bits < 55)
  assert(bits % 2 == 0)
  local hb = floor(bits / 2)
  local s = BIT_TABLE[hb - 1]
  local sb = BIT_TABLE[hb]
  local a = floor(packed % sb) - s
  local b = floor(floor(packed / sb) % sb) - s
  return a, b
end

--- @since "2026.6.2"
--- @spec pack_v3(bits: Number, a: Number, b: Number, c: Number): Number
function m.pack_v3(bits, a, b, c, d)
  assert(bits > 1 and bits < 55)
  assert(bits % 3 == 0)
  local tb = floor(bits / 3)
  local s = BIT_TABLE[tb - 1]
  local sb = BIT_TABLE[tb]
  local ua = s + min(max(floor(a), -s), s - 1)
  local ub = s + min(max(floor(b), -s), s - 1)
  local uc = s + min(max(floor(c), -s), s - 1)
  return uc * sb ^ 2 + ub * sb + ua
end

--- @since "2026.6.2"
--- @spec unpack_v3(bits: Number, packed: Number): (a: Number, b: Number, c: Number)
function m.unpack_v3(bits, packed)
  assert(bits > 1 and bits < 55)
  assert(bits % 3 == 0)
  local tb = floor(bits / 3)
  local s = BIT_TABLE[tb - 1]
  local sb = BIT_TABLE[tb]
  local a = floor(packed % sb) - s
  local b = floor(floor(packed / sb) % sb) - s
  local c = floor(floor(packed / (sb ^ 2)) % sb) - s
  return a, b, c
end

--- @since "2026.6.2"
--- @spec pack_v4(bits: Number, a: Number, b: Number, c: Number, d: Number): Number
function m.pack_v4(bits, a, b, c, d)
  assert(bits > 1 and bits < 55)
  assert(bits % 4 == 0)
  local qb = floor(bits / 4)
  local s = BIT_TABLE[qb - 1]
  local sb = BIT_TABLE[qb]
  local ua = s + min(max(floor(a), -s), s - 1)
  local ub = s + min(max(floor(b), -s), s - 1)
  local uc = s + min(max(floor(c), -s), s - 1)
  local ud = s + min(max(floor(d), -s), s - 1)
  return ud * sb ^ 3 + uc * sb ^ 2 + ub * sb + ua
end

--- @since "2026.6.2"
--- @spec unpack_v4(bits: Number, packed: Number): (a: Number, b: Number, c: Number, d: Number)
function m.unpack_v4(bits, packed)
  assert(bits > 1 and bits < 55)
  assert(bits % 4 == 0)
  local qb = floor(bits / 4)
  local s = BIT_TABLE[qb - 1]
  local sb = BIT_TABLE[qb]
  local a = floor(packed % sb) - s
  local b = floor(floor(packed / sb) % sb) - s
  local c = floor(floor(packed / (sb ^ 2)) % sb) - s
  local d = floor(floor(packed / (sb ^ 3)) % sb) - s
  return a, b, c, d
end

return m
