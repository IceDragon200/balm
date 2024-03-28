--
-- Little Endian - Byte Decoder
--
local bit = require("balm/u/bit")

local INT_MAX = {
  [1] = math.floor(math.pow(2, 8)),
  [2] = math.floor(math.pow(2, 16)),
  [3] = math.floor(math.pow(2, 24)),
  [4] = math.floor(math.pow(2, 32)),
  [5] = math.floor(math.pow(2, 40)),
  [6] = math.floor(math.pow(2, 48)),
  [7] = math.floor(math.pow(2, 56)),
  [8] = math.floor(math.pow(2, 64)),
}

--- @namespace balm.p.ByteDecoder
local E = {}
do
  function E:d_i64(bytes)
    return self:d_iv(bytes, 8)
  end

  function E:d_i56(bytes)
    return self:d_iv(bytes, 7)
  end

  function E:d_i48(bytes)
    return self:d_iv(bytes, 6)
  end

  function E:d_i40(bytes)
    return self:d_iv(bytes, 5)
  end

  function E:d_i32(bytes)
    return self:d_iv(bytes, 4)
  end

  function E:d_i24(bytes)
    return self:d_iv(bytes, 3)
  end

  function E:d_i16(bytes)
    return self:d_iv(bytes, 2)
  end

  function E:d_i8(bytes)
    return self:d_iv(bytes, 1)
  end

  function E:d_u64(bytes)
    return self:d_uv(bytes, 8)
  end

  function E:d_u56(bytes)
    return self:d_uv(bytes, 7)
  end

  function E:d_u48(bytes)
    return self:d_uv(bytes, 6)
  end

  function E:d_u40(bytes)
    return self:d_uv(bytes, 5)
  end

  function E:d_u32(bytes)
    return self:d_uv(bytes, 4)
  end

  function E:d_u24(bytes)
    return self:d_uv(bytes, 3)
  end

  function E:d_u16(bytes)
    return self:d_uv(bytes, 2)
  end

  function E:d_u8(bytes)
    return self:d_uv(bytes, 1)
  end
end

-- Little Endian - Encoder
local LE = {}
do
  setmetatable(LE, { __index = E })

  --- @spec &d_iv(String, len: Integer): (result: Integer, len: Integer)
  function LE:d_iv(bytes, len)
    local result = 0

    for i = 1,(len - 1) do
      local byte = string.byte(bytes, i)
      byte = bit.lshift(byte, 8 * (i - 1))
      result = bit.bor(result, byte)
    end
    local byte = string.byte(bytes, len)
    if bit.band(byte, 128) == 128 then
      local bits = 8 * (len - 1)
      local high_byte = bit.lshift(byte, bits) - INT_MAX[len]
      result = bit.bor(high_byte, result)
      return result, len
    else
      result = bit.bor(result, bit.lshift(bit.band(byte, 127), 8 * (len - 1)))
      return result, len
    end
  end

  --- @spec &d_uv(String, len: Integer): (result: Integer, len: Integer)
  function LE:d_uv(bytes, len)
    local result = 0

    for i = 1,len do
      local byte = string.byte(bytes, i)
      byte = bit.lshift(byte, 8 * (i - 1))
      result = bit.bor(byte, result)
    end
    return result, len
  end
end

-- Big Endian - Encoder
local BE = {}
do
  setmetatable(BE, { __index = E })

  --- @spec &d_iv(String, len: Integer): (result: Integer, len: Integer)
  function BE:d_iv(bytes, len)
    error("not implemented")
    -- local result = 0

    -- for i = 1,(len - 1) do
    --   local byte = string.byte(bytes, i)
    --   byte = bit.lshift(byte, 8 * (i - 1))
    --   result = bit.bor(result, byte)
    -- end
    -- local byte = string.byte(bytes, len)
    -- if bit.band(byte, 128) == 128 then
    --   local bits = 8 * (len - 1)
    --   local high_byte = bit.lshift(byte, bits) - INT_MAX[len]
    --   result = bit.bor(high_byte, result)
    --   return result, len
    -- else
    --   result = bit.bor(result, bit.lshift(bit.band(byte, 127), 8 * (len - 1)))
    --   return result, len
    -- end
  end

  --- @spec &d_uv(String, len: Integer): (result: Integer, len: Integer)
  function BE:d_uv(bytes, len)
    error("not implemented")
    -- local result = 0

    -- for i = 1,len do
    --   local byte = string.byte(bytes, i)
    --   byte = bit.lshift(byte, 8 * (i - 1))
    --   result = bit.bor(byte, result)
    -- end
    -- return result, len
  end
end

return {
  LE = LE,
  BE = BE,
}
