local string_split = require("balm/m/string").split
local Object = require("balm/object")

local NaiveDateTime = Object:extends("balm.u.NaiveDateTime")
local ic = NaiveDateTime.instance_class

function ic:initialize(year, month, day, hour, minute, second)
  self.year = year or 1960
  self.month = month or 1
  self.day = day or 1
  self.hour = hour or 0
  self.minute = minute or 0
  self.second = second or 0
end

function NaiveDateTime:utc_now()
  local d = os.date("%Y %m %d %H %M %S %z")

  local c = string_split(d, " ")
  local zone = c[7]
  -- FIXME: adjust datetime by zone offset
  return self:new(
          tonumber(c[1]), tonumber(c[2]), tonumber(c[3]), -- Y m d
          tonumber(c[4]), tonumber(c[5]), tonumber(c[6])  -- H M s
        )
end

return NaiveDateTime
