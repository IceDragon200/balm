--- @namespace balm.m.enum

local m = {}

--- Creates a new string enum where the keys are the same as their values.
--- @spec new(...: String[]): Record<String, String>
function m.new(...)
  local result = {}
  local len = select('#', ...)
  local v
  if len > 0 then
    for i = 1,len do
      v = select(i, ...)
      result[v] = v
    end
  end
  return result
end

return m
