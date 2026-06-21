--
-- Object Utilities
--
local assertions = require("balm/m/assertions")
local Object = require("balm/object")

--- @since "2026.5.7"
--- @namespace balm.m.object
local m = {}

--- @since "2026.5.7"
--- @spec is_object(value: Any): Boolean
m.is_object = Object.is_object

--- @since "2026.5.7"
--- @spec construct(Class<T>, Table): T
function m.construct(klass, raw)
  if m.is_object(raw) then
    if raw:is_instance_of(klass) then
      return raw
    end
    error("unexpected object class=" .. tostring(raw._class))
  else
    return klass:new(assertions.is_table(raw))
  end
end

--- @since "2026.5.7"
--- @spec construct_record(Class<T>, Record<ID, Table>): Record<ID, T>
function m.construct_record(klass, record)
  local result = {}
  for key, tab in pairs(record) do
    result[key] = m.construct(klass, tab)
  end
  return result
end

--- @since "2026.6.18"
--- @spec construct_list(Class<T>, Record<ID, Table>): Record<ID, T>
function m.construct_list(klass, list)
  local result = {}
  for key, tab in ipairs(list) do
    result[key] = m.construct(klass, tab)
  end
  return result
end

return m
