--- @namespace balm.m.string
local m = {}

local encoding_tables = require("balm/encoding_tables")

local HEX_BYTE_TO_DEC = assert(encoding_tables.HEX_BYTE_TO_DEC)
local HEX_TABLE = assert(encoding_tables.HEX_TABLE)

local function byte_to_escaped_hex(byte)
  local hinibble = math.floor(byte / 16)
  local lonibble = byte % 16
  return "\\x" .. HEX_TABLE[hinibble] .. HEX_TABLE[lonibble]
end

function m.byte_to_hexpair(byte)
  assert(byte >= 0 and byte <= 255, "expected byte to be between 0..255")
  local hinibble = math.floor(byte / 16)
  local lonibble = byte % 16
  return HEX_TABLE[hinibble] .. HEX_TABLE[lonibble]
end

function m.nibble_to_hex(nibble)
  assert(nibble >= 0 and nibble <= 15, "expected nibble to be between 0..15")
  return HEX_TABLE[nibble]
end

--- Removes any non-hex characters
---
--- @spec hex_clean(String): String
function m.hex_clean(str)
  local result = {}
  local bytes = {string.byte(str, 1, -1)}

  local j = 1
  local i = 1
  local len = #bytes
  while i < len do
    local byte = bytes[i]
    if HEX_BYTE_TO_DEC[byte] then
      result[j] = string.char(byte)
      j = j + 1
    end
    i = i + 1
  end

  return table.concat(result)
end

--- Decode a hex nibble string as a plain byte
---
--- @spec hex_nibble_to_byte(String): Integer
--- @example hex_nibble_to_byte("F") -- => 255
function m.hex_nibble_to_byte(hex)
  local nibble = string.byte(hex, 1) or 0
  return HEX_BYTE_TO_DEC[nibble]
end

--- Decode a hexpair string as a plain byte
---
--- @spec hex_pair_to_byte(String): Integer
--- @example hex_pair_to_byte("FF") -- => 255
function m.hex_pair_to_byte(pair)
  local hinibble = string.byte(pair, 1) or 0
  local lonibble = string.byte(pair, 2) or 0
  return HEX_BYTE_TO_DEC[hinibble] * 16 + HEX_BYTE_TO_DEC[lonibble]
end

function m.lua_hex_decode(str)
  local result = {}
  local bytes = {string.byte(str, 1, -1)}

  local j = 1
  local i = 1
  local len = #bytes
  while i < len do
    local hinibble = bytes[i + 0] or 0
    local lonibble = bytes[i + 1] or 0
    local byte = HEX_BYTE_TO_DEC[hinibble] * 16 + HEX_BYTE_TO_DEC[lonibble]
    result[j] = string.char(byte)
    i = i + 2
    j = j + 1
  end

  return table.concat(result)
end

function m.lua_hex_encode(str, spacer)
  local result = {}
  local bytes = {string.byte(str, 1, -1)}

  local j = 1
  local len = #bytes

  for i, byte in ipairs(bytes) do
    local hinibble = math.floor(byte / 16)
    local lonibble = byte % 16
    result[j] = HEX_TABLE[hinibble]
    result[j + 1] = HEX_TABLE[lonibble]
    j = j + 2
    if spacer then
      if i < len then
        result[j] = spacer
        j = j + #spacer
      end
    end
  end

  return table.concat(result)
end

function m.lua_hex_escape(str, mode)
  mode = mode or "non-ascii"

  local result = {}
  local bytes = {string.byte(str, 1, -1)}

  for i, byte in ipairs(bytes) do
    if mode == "non-ascii" then
      -- 92 \
      if byte == 92 then
        result[i] = "\\\\"
      elseif byte >= 32 and byte < 127  then
        result[i] = string.char(byte)
      else
        result[i] = byte_to_escaped_hex(byte)
      end
    else
      result[i] = byte_to_escaped_hex(byte)
    end
  end

  return table.concat(result)
end

function m.handle_escaped_hex(i, j, bytes, result)
  local hinibble = bytes[i + 2]
  local lonibble = bytes[i + 3]
  if HEX_BYTE_TO_DEC[hinibble] and HEX_BYTE_TO_DEC[lonibble] then
    local hi = HEX_BYTE_TO_DEC[hinibble]
    local lo = HEX_BYTE_TO_DEC[lonibble]
    result[j] = string.char(hi * 16 + lo)
  else
    -- something isn't right, skip over this
    result[j] = string.char(bytes[1])
    result[j + 1] = "x"
    result[j + 2] = string.char(hinibble)
    result[j + 3] = string.char(lonibble)
    j = j + 3
  end
  i = i + 4

  return i, j
end

--- Resolves all hex encoded values in the string
---
--- @spec lua_hex_unescape(String): String
---
--- Example:
---   "\\x00\x00\\x01\\x02" > "\x00\x00\x01\x02"
---   The above describes a literal string with the value \x00\x00\x01\x02
---   This function will unescape that sequence and produce the actual bytes 0 0 1 2
function m.lua_hex_unescape(str)
  local result = {}
  local bytes = {string.byte(str, 1, -1)}

  local i = 1
  local len = #bytes
  local j = 1

  while i <= len do
    local byte = bytes[i]

    -- 92 \
    if byte == 92 then
      -- 120 x
      if bytes[i + 1] == 120 then
        i, j = m.handle_escaped_hex(i, j, bytes, result)
      -- 92 \
      elseif bytes[i + 1] == 92 then
        result[j] = "\\"
        i = i + 1
      -- other
      else
        result[j] = bytes[i + 1]
        i = i + 1
      end
    else
      result[j] = string.char(byte)
      i = i + 1
    end
    j = j + 1
  end

  return table.concat(result)
end

--- @spec hex_decode(String): String
m.hex_decode =
  m.hex_decode or m.lua_hex_decode
--- @spec hex_encode(String): String
m.hex_encode =
  m.hex_encode or m.lua_hex_encode
--- @spec hex_escape(String): String
m.hex_escape =
  m.hex_escape or m.lua_hex_escape
--- @spec hex_unescape(String): String
m.hex_unescape =
  m.hex_unescape or m.lua_hex_unescape

return m
