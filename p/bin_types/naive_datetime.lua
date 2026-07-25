local BinSchema = require("balm/p/bin_schema")
local Object = require("balm/object")

local NaiveDateTimeSchema0 = BinSchema:new({
  {"year", "u16"},
  {"month", "u8"},
  {"day", "u8"},
  {"hour", "u8"},
  {"minute", "u8"},
  {"second", "u8"},
})

local NaiveDateTime = Object:extends("NaiveDateTimeBinType")
do
  local ic = NaiveDateTime.instance_class

  function ic:write(byte_buf, file, datetime)
    local abw = 0
    local bw
    local err
    -- Datetime Version, in case the format needs to change
    bw, err = byte_buf:w_u32(file, 0)
    abw = abw + bw
    if err then
      return abw, err
    end
    bw, err = NaiveDateTimeSchema0:write(file, datetime)
    abw = abw + bw
    return abw, err
  end

  function ic:read(byte_buf, file)
    local value, br = byte_buf:r_u32(file)
    if value == 0 then
      return NaiveDateTimeSchema0:read(file), br
    else
      error("invalid naive_datetimme version")
    end
  end
end

return NaiveDateTime
