local byte_buf = require("balm/p/byte_buf").LE
local Object = require("balm/object")

local Bytes = Object:extends("Bytes")
local ic = Bytes.instance_class

function ic:initialize(length)
  self.length = length
end

--- @spec #write(File, data: String | nil): (Integer, err: String | nil)
function ic:write(file, data)
  assert(file, "expected a file")
  data = data or ""
  local payload = string.sub(data, 1, self.length)
  local actual_length = #payload
  local padding_needed = self.length - actual_length
  assert(padding_needed >= 0, "length error")
  local bytes_written, err = byte_buf:write(file, payload)
  if err then
    return bytes_written, err
  end
  for _ = 1,padding_needed do
    byte_buf:w_u8(file, 0)
  end
  return self.length, nil
end

function ic:read(file)
  return byte_buf:read(file, self.length)
end

return Bytes
