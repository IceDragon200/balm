local assertions = require("balm/m/assertions")
local Object = require("balm/object")
local HEXL = assert(require("balm/encoding_tables").HEX_LOWERCASE_ENCODE_TABLE)
local string_char = assert(string.char)
local floor = assert(math.floor)
local table_concat = assert(table.concat)
local math_random = assert(math.random)

local U32 = 0x100000000
local U16 = 0x10000
local U8 = 0x100
local U4 = 0x10

--- @namespace balm.s

--- Unsigned 128-bit integer utility for LuaJIT.
--- @since "2026.5.18"
--- @class U128
local U128 = Object:extends("balm.s.U128")
do
  local ic = U128.instance_class

  --- @override
  --- @spec #initialize(options: Table): void
  function ic:initialize(options)
    options = options or {}
    ic._super.initialize(self)
    self.a = options.a or 0
    self.b = options.b or 0
    self.c = options.c or 0
    self.d = options.d or 0
  end

  --- Converts the number to a big-endian byte array.
  --- @spec #to_be128_barray(): String[]
  function ic:to_be128_barray()
    local r = self:to_le128_barray()
    r[1],  r[16] = r[16], r[1]
    r[2],  r[15] = r[15], r[2]
    r[3],  r[14] = r[14], r[3]
    r[4],  r[13] = r[13], r[4]
    r[5],  r[12] = r[12], r[5]
    r[6],  r[11] = r[11], r[6]
    r[7],  r[10] = r[10], r[7]
    r[8],  r[9]  = r[9],  r[8]
    return r
  end

  --- Converts the number to a big-endian ordered string.
  --- @spec #to_be128_string(): String
  function ic:to_be128_string()
    return table_concat(self:to_be128_barray())
  end

  --- Converts the number to a little-endian byte array.
  --- @spec #to_le128_barray(): String[]
  function ic:to_le128_barray()
    local r = {}
    local x = self.a
    -- curse you 1-index, ruined my plans!
    r[0x01] = string_char(x % U8); x = floor(x / U8)
    r[0x02] = string_char(x % U8); x = floor(x / U8)
    r[0x03] = string_char(x % U8); x = floor(x / U8)
    r[0x04] = string_char(x % U8)
    x = self.b
    r[0x05] = string_char(x % U8); x = floor(x / U8)
    r[0x06] = string_char(x % U8); x = floor(x / U8)
    r[0x07] = string_char(x % U8); x = floor(x / U8)
    r[0x08] = string_char(x % U8)
    x = self.c
    r[0x09] = string_char(x % U8); x = floor(x / U8)
    r[0x0A] = string_char(x % U8); x = floor(x / U8)
    r[0x0B] = string_char(x % U8); x = floor(x / U8)
    r[0x0C] = string_char(x % U8)
    x = self.d
    r[0x0D] = string_char(x % U8); x = floor(x / U8)
    r[0x0E] = string_char(x % U8); x = floor(x / U8)
    r[0x0F] = string_char(x % U8); x = floor(x / U8)
    r[0x10] = string_char(x % U8)
    return r
  end

  --- Converts the number to a little-endian ordered string.
  --- @spec #to_le128_string(): String
  function ic:to_le128_string()
    return table_concat(self:to_le128_barray())
  end

  --- Converts the number to a GUID.
  --- @spec #to_guid(): String
  function ic:to_guid()
    local r = {}
    local x = self.d
    -- big-endian, so don't worry about the weird starting position
    r[0x09] = "-"
    r[0x08] = HEXL[x % U4]; x = floor(x / U4)
    r[0x07] = HEXL[x % U4]; x = floor(x / U4)
    r[0x06] = HEXL[x % U4]; x = floor(x / U4)
    r[0x05] = HEXL[x % U4]; x = floor(x / U4)
    r[0x04] = HEXL[x % U4]; x = floor(x / U4)
    r[0x03] = HEXL[x % U4]; x = floor(x / U4)
    r[0x02] = HEXL[x % U4]; x = floor(x / U4)
    r[0x01] = HEXL[x % U4]
    x = self.c
    r[0x13] = "-"
    r[0x12] = HEXL[x % U4]; x = floor(x / U4)
    r[0x11] = HEXL[x % U4]; x = floor(x / U4)
    r[0x10] = HEXL[x % U4]; x = floor(x / U4)
    r[0x0F] = HEXL[x % U4]; x = floor(x / U4)
    r[0x0E] = "-"
    r[0x0D] = HEXL[x % U4]; x = floor(x / U4)
    r[0x0C] = HEXL[x % U4]; x = floor(x / U4)
    r[0x0B] = HEXL[x % U4]; x = floor(x / U4)
    r[0x0A] = HEXL[x % U4]
    x = self.b
    r[0x1C] = HEXL[x % U4]; x = floor(x / U4)
    r[0x1B] = HEXL[x % U4]; x = floor(x / U4)
    r[0x1A] = HEXL[x % U4]; x = floor(x / U4)
    r[0x19] = HEXL[x % U4]; x = floor(x / U4)
    r[0x18] = "-"
    r[0x17] = HEXL[x % U4]; x = floor(x / U4)
    r[0x16] = HEXL[x % U4]; x = floor(x / U4)
    r[0x15] = HEXL[x % U4]; x = floor(x / U4)
    r[0x14] = HEXL[x % U4]
    x = self.a
    r[0x24] = HEXL[x % U4]; x = floor(x / U4)
    r[0x23] = HEXL[x % U4]; x = floor(x / U4)
    r[0x22] = HEXL[x % U4]; x = floor(x / U4)
    r[0x21] = HEXL[x % U4]; x = floor(x / U4)
    r[0x20] = HEXL[x % U4]; x = floor(x / U4)
    r[0x1F] = HEXL[x % U4]; x = floor(x / U4)
    r[0x1E] = HEXL[x % U4]; x = floor(x / U4)
    r[0x1D] = HEXL[x % U4]
    return table_concat(r)
  end

  --- @spec #add(other: Number | U128): U128
  function ic:add(other)
    if Object.is_object(other, U128) then
      local carry = 0

      local sum_a = self.a + other.a + carry
      self.a = sum_a % U32
      carry = floor(sum_a / U32)

      local sum_b = self.b + other.b + carry
      self.b = sum_b % U32
      carry = floor(sum_b / U32)

      local sum_c = self.c + other.c + carry
      self.c = sum_c % U32
      carry = floor(sum_c / U32)

      local sum_d = self.d + other.d + carry
      self.d = sum_d % U32

    else
      assertions.is_number(other)

      if other < 0 then
        return self:sub(-other)
      end

      local o_a = other % U32
      local carry = floor(other / U32)
      local o_b = carry % U32
      carry = floor(carry / U32)
      local o_c = carry % U32
      local o_d = floor(carry / U32) % U32

      local sum_a = self.a + o_a
      self.a = sum_a % U32
      carry = floor(sum_a / U32)

      local sum_b = self.b + o_b + carry
      self.b = sum_b % U32
      carry = floor(sum_b / U32)

      local sum_c = self.c + o_c + carry
      self.c = sum_c % U32
      carry = floor(sum_c / U32)

      local sum_d = self.d + o_d + carry
      self.d = sum_d % U32
    end

    return self
  end

  --- @spec #subtract(other: Number | U128): U128
  function ic:subtract(other)
    if Object.is_object(other, U128) then
      local borrow = 0

      local diff_a = self.a - other.a - borrow
      if diff_a < 0 then
        diff_a = diff_a + U32
        borrow = 1
      else
        borrow = 0
      end
      self.a = diff_a

      local diff_b = self.b - other.b - borrow
      if diff_b < 0 then
        diff_b = diff_b + U32
        borrow = 1
      else
        borrow = 0
      end
      self.b = diff_b

      local diff_c = self.c - other.c - borrow
      if diff_c < 0 then
        diff_c = diff_c + U32
        borrow = 1
      else
        borrow = 0
      end
      self.c = diff_c

      local diff_d = self.d - other.d - borrow
      if diff_d < 0 then
        diff_d = diff_d + U32
      end
      self.d = diff_d

    else
      assertions.is_number(other)

      if other < 0 then
        return self:add(-other)
      end

      local o_a = other % U32
      local carry = floor(other / U32)
      local o_b = carry % U32
      carry = floor(carry / U32)
      local o_c = carry % U32
      local o_d = floor(carry / U32) % U32

      local borrow = 0

      local diff_a = self.a - o_a
      if diff_a < 0 then
        diff_a = diff_a + U32
        borrow = 1
      else
        borrow = 0
      end
      self.a = diff_a

      local diff_b = self.b - o_b - borrow
      if diff_b < 0 then
        diff_b = diff_b + U32
        borrow = 1
      else
        borrow = 0
      end
      self.b = diff_b

      local diff_c = self.c - o_c - borrow
      if diff_c < 0 then
        diff_c = diff_c + U32
        borrow = 1
      else
        borrow = 0
      end
      self.c = diff_c

      local diff_d = self.d - o_d - borrow
      if diff_d < 0 then
        diff_d = diff_d + U32
      end
      self.d = diff_d
    end

    return self
  end

  ic.sub = ic.subtract

  local function mul32x32(x, y)
    local x_low = x % U16
    local x_high = floor(x / U16)
    local y_low = y % U16
    local y_high = floor(y / U16)

    local p0 = x_low * y_low
    local p1 = x_low * y_high + x_high * y_low
    local p2 = x_high * y_high

    local low = p0 + (p1 % U16) * U16
    local carry = floor(p0 / U32) + floor(p1 / U16) + p2

    low = low % U32
    return low, carry
  end

  --- @spec #multiply(other: U128): U128
  function ic:multiply(other)
    if not Object.is_object(other, U128) then
      assertions.is_number(other)
      assert(other >= 0, "expected a positive integer")

      other = U128:new({
        a = other % U32,
        b = floor(other / U32) % U32,
        c = 0,
        d = 0,
      })
    end

    local r_a, r_b, r_c, r_d = 0, 0, 0, 0
    local low, carry

    low, carry = mul32x32(self.a, other.a); r_a = r_a + low; r_b = r_b + carry
    low, carry = mul32x32(self.a, other.b); r_b = r_b + low; r_c = r_c + carry
    low, carry = mul32x32(self.a, other.c); r_c = r_c + low; r_d = r_d + carry
    low, carry = mul32x32(self.a, other.d); r_d = r_d + low

    low, carry = mul32x32(self.b, other.a); r_b = r_b + low; r_c = r_c + carry
    low, carry = mul32x32(self.b, other.b); r_c = r_c + low; r_d = r_d + carry
    low, carry = mul32x32(self.b, other.c); r_d = r_d + low

    low, carry = mul32x32(self.c, other.a); r_c = r_c + low; r_d = r_d + carry
    low, carry = mul32x32(self.c, other.b); r_d = r_d + low

    low, carry = mul32x32(self.d, other.a); r_d = r_d + low

    local carry_v = 0
    r_a = r_a + carry_v; carry_v = floor(r_a / U32); self.a = r_a % U32
    r_b = r_b + carry_v; carry_v = floor(r_b / U32); self.b = r_b % U32
    r_c = r_c + carry_v; carry_v = floor(r_c / U32); self.c = r_c % U32
    r_d = r_d + carry_v; self.d = r_d % U32

    return self
  end

  ic.mul = ic.multiply
end

do
  --- @spec &random(): U128
  function U128:random()
    local i = self:alloc()
    i.a = math_random(U32) - 1
    i.b = math_random(U32) - 1
    i.c = math_random(U32) - 1
    i.d = math_random(U32) - 1
    return i
  end
end

do
  local mt = U128.__imt

  --- @spec #+(other: U128): U128
  function mt:__add(other)
    return self:copy():add(other)
  end

  --- @spec #-(other: U128): U128
  function mt:__sub(other)
    return self:copy():subtract(other)
  end

  --- @spec #*(other: U128): U128
  function mt:__mul(other)
    return self:copy():multiply(other)
  end
end

return U128
