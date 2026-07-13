local assertions = require("balm/m/assertions")
local ScalarTypes = require("balm/p/bin_types/scalars")
local Object = require("balm/object")

--- @class balm.p.bin_types.ArrayType
local ArrayType = Object:extends("balm.p.bin_types.ArrayType")
do
  local ic = ArrayType.instance_class

  --- @spec #initialize(value_type: Any, len: Number): void
  function ic:initialize(value_type, len)
    ic._super.initialize(self)
    self.value_type = ScalarTypes.normalize_type(value_type)
    self.len = assertions.is_number(len)
  end

  --- @spec #write(byte_buf: ByteBuf, stream: Stream, data: Number):
  ---   (bytes_written: Number, err: Any)
  function ic:write(byte_buf, stream, data)
    assert(data, "expected data")
    local abw = 0
    local bw
    local err
    local len
    if self.len >= 0 then
      len = self.len
    else
      len = #data
      bw, err = byte_buf:w_u32(stream, len)
      abw = abw + bw
      if err then
        return abw, err
      end
    end
    local item
    for i = 1,len do
      item = data[i]
      bw, err = self.value_type:write(byte_buf, stream, item)
      abw = abw + bw
      if err then
        return abw, err
      end
    end
    return abw, nil
  end

  --- @spec #read(byte_buf: ByteBuf, stream: Stream): (result: Any[], bytes_read: Number)
  function ic:read(byte_buf, stream)
    local abr = 0
    local br
    local len
    if self.len >= 0 then
      len = self.len
    else
      local v
      v, br = byte_buf:r_u32(stream)
      abr = abr + br
      len = v
    end
    local result = {}
    local item
    for i = 1,len do
      item, br = self.value_type:read(byte_buf, stream)
      abr = abr + br
      result[i] = item
    end
    return result, abr
  end
end

return ArrayType
