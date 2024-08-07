--- @namespace balm.m
local m = {}

local unpack = assert(table.unpack or unpack)

local encoding_tables = require("balm/encoding_tables")
local HEX_TABLE = assert(encoding_tables.HEX_TABLE)
local CROCKFORD_BASE32_ENCODE_TABLE = assert(encoding_tables.CROCKFORD_BASE32_ENCODE_TABLE)

--- Encode an integer as a big-endian binary, len is the length of the string in bytes
---
--- @spec integer_be_encode(Integer, len: Integer): String
function m.integer_be_encode(integer, len)
  local result = {}
  for i = 0,len-1 do
    result[len - i] = integer % 256
    integer = math.floor(integer / 256)
  end
  return string.char(unpack(result))
end

--- Encode an integer as a little-endian binary, len is the length of the string in bytes
---
--- @spec integer_le_encode(Integer, len: Integer): String
function m.integer_le_encode(integer, len)
  local result = {}
  for i = 1,len do
    result[i] = integer % 256
    integer = math.floor(integer / 256)
  end
  return string.char(unpack(result))
end

--- Encode an integer as a big-endian hex string, len is the byte length of the integer
---
--- Usage:
---     integer_hex_be_encode(0xDEADBEEF) -- => DEADBEEF
---
--- @spec integer_hex_be_encode(Integer, len: Integer): String
function m.integer_hex_be_encode(integer, len)
  local result = {}
  local byte
  local lonibble
  local hinibble
  local j = len * 2
  for _ = 1,len do
    byte = integer % 256
    lonibble = byte % 16
    hinibble = math.floor(byte / 16) % 16
    result[j] = HEX_TABLE[lonibble]
    result[j - 1] = HEX_TABLE[hinibble]
    integer = math.floor(integer / 256)
    j = j - 2
  end
  return table.concat(result)
end

--- Encodes an integer in base16 with big-endian ordering
---
--- @spec integer_base16_be_encode(Integer, len: Integer): String
function m.integer_base16_be_encode(integer, len)
  local segments = len * 2
  local result = {}

  for i = 0,segments-1 do
    result[segments - i] = HEX_TABLE[integer % 16]
    integer = math.floor(integer / 16)
  end

  return table.concat(result)
end

--- Encodes an integer in base16 with little-endian ordering
---
--- @spec integer_base16_le_encode(Integer, len: Integer): String
function m.integer_base16_le_encode(integer, len)
  local segments = len * 2
  local result = {}

  for i = 1,segments do
    result[i] = HEX_TABLE[integer % 16]
    integer = math.floor(integer / 16)
  end

  return table.concat(result)
end

--- @spec integer_crockford_base32_be_encode(Integer, len: Integer, return_table?: Boolean): String
function m.integer_crockford_base32_be_encode(integer, len, return_table)
  local bits = len * 8
  local segments = math.ceil(bits / 5)
  local result = {}
  local value

  for i = 0,segments-1 do
    value = integer % 32
    result[segments - i] = CROCKFORD_BASE32_ENCODE_TABLE[value]
    integer = math.floor(integer / 32)
  end

  if return_table then
    return result
  else
    return table.concat(result)
  end
end

--- @spec integer_crockford_base32_le_encode(Integer, len: Integer, return_table?: Boolean): String
function m.integer_crockford_base32_le_encode(integer, len, return_table)
  local bits = len * 8
  local segments = math.ceil(bits / 5)
  local result = {}
  local value

  for i = 1,segments do
    value = integer % 32
    result[i] = CROCKFORD_BASE32_ENCODE_TABLE[value]
    integer = math.floor(integer / 32)
  end

  if return_table then
    return result
  else
    return table.concat(result)
  end
end

--- @spec round(num: Number): Integer
--- @spec round(num: Number, places: Integer): Integer
function m.round(num, places)
  if places and places > 0 then
    local pow = math.pow(10, places)
    local floor = math.floor(num * pow)
    local norm = num - floor

    if norm >= 0.5 then
      return (floor + 1) / pow
    else
      return floor / pow
    end
  else
    local floor = math.floor(num)
    local norm = num - floor
    if norm >= 0.5 then
      return floor + 1
    else
      return floor
    end
  end
end

--- @spec sign(Number): Integer
function m.sign(num)
  if num > 0 then
    return 1
  elseif num < 0 then
    return -1
  else
    return 0
  end
end

--- @spec lerp(a: Number, b: Number, t: Number): Number
function m.lerp(a, b, t)
  return a + (b - a) * t
end

--- Interpolate between 2 numbers by a fixed amount.
--- see `lerp` for linear interpolation.
---
--- @spec interpolate(a: Number, b: Number, amt: Number): Number
function m.interpolate(a, b, amt)
  if a < b then
    return math.min(a + amt, b)
  elseif a > b then
    return math.max(a - amt, b)
  end
  return a
end

return m
