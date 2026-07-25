local PrettyUnits = require("balm/m/pretty_units")

--- @namespace balm.m.units
local m = {}

--- @const BINARY_UNITS: { [name: String]: Number }
m.BINARY_UNITS = {}
for _, row in ipairs(PrettyUnits.BINARY_PREFIXES) do
  m.BINARY_UNITS[row[1]] = row[3]
  m.BINARY_UNITS[row[2]] = row[3]
end

--- @const METRIC_UNITS: { [name: String]: Number }
m.METRIC_UNITS = {}
for _, row in ipairs(PrettyUnits.METRIC_PREFIXES) do
  m.METRIC_UNITS[row[1]] = row[3]
  m.METRIC_UNITS[row[2]] = row[3]
end

--- @spec from_binary(value: Number, unit: String): Number
function m.from_binary(value, unit)
  local scale = m.BINARY_UNITS[unit]
  if not scale then
    error("unit not found unit=" .. unit)
  end
  return value * scale
end

--- @spec to_binary(value: Number, unit: String): Number
function m.to_binary(value, unit)
  local scale = m.BINARY_UNITS[unit]
  if not scale then
    error("unit not found unit=" .. unit)
  end
  return value / scale
end

--- @spec from_metric(value: Number, unit: String): Number
function m.from_metric(value, unit)
  local scale = m.METRIC_UNITS[unit]
  if not scale then
    error("unit not found unit=" .. unit)
  end
  return value * scale
end

--- @spec to_metric(value: Number, unit: String): Number
function m.to_metric(value, unit)
  local scale = m.METRIC_UNITS[unit]
  if not scale then
    error("unit not found unit=" .. unit)
  end
  return value / scale
end

return m
