-- Originally a class taking from project "breeder", but should be generally useful.
local assertions = require("balm/m/assertions")
local Object = require("balm/object")
local Table = require("balm/m/table")
local table_copy = assert(Table.copy)
local table_equals = assert(Table.equals)

--- Properties is a simple bag structure for storing simple scalars.
---
--- @class Properties
local Properties = Object:extends("balm.u.Properties")
do
  local ic = Properties.instance_class

  --- @override
  --- @spec #initialize(data?: Table | Properties): void
  function ic:initialize(data)
    ic._super.initialize(self)

    --- The raw underlying properties, do not access this normally, use the utility functions
    --- when possible.
    --- @member data: Table
    if Object.is_object(data, Properties) then
      self.data = table_copy(data.data)
    else
      self.data = assertions.is_table(data or {})
    end
  end

  --- @override
  --- @spec #initialize_copy(other: self): void
  function ic:initialize_copy(other)
    ic._super.initialize_copy(self, other)
    self.data = table_copy(other.data)
  end

  --- @override
  --- @spec #equals(other: Properties): void
  function ic:equals(other)
    if rawequal(self, other) then
      return true
    end
    if Object.is_object(other, Properties) then
      return table_equals(self.data, other.data)
    end
    return false
  end

  --- @since "2026.6.6"
  --- @spec #keys(): ID[]
  function ic:keys()
    local i = 0
    local result = {}
    for key, _ in pairs(self.data) do
      i = i + 1
      result[i] = key
    end
    return result
  end

  --- @mutative
  --- @spec #put(key: String, value: Any): self
  function ic:put(key, value)
    self.data[key] = value
    return self
  end

  --- @mutative
  --- @spec #put_new(key: String, value: Any): self
  function ic:put_new(key, value)
    if self.data[key] == nil then
      self.data[key] = value
    end
    return self
  end

  --- @since "2026.5.21"
  --- @mutative
  --- @spec #put_new_lazy(key: String, value: Any): self
  function ic:put_new_lazy(key, value)
    if self.data[key] == nil then
      self.data[key] = value
    end
    return self
  end

  --- @mutative
  --- @spec #add(key: String, value: Number, default: Number): Number
  function ic:add(key, value, default)
    local result = (self.data[key] or default) + value
    self.data[key] = result
    return result
  end

  --- @mutative
  --- @spec #subtract(key: String, value: Number, default: Number): Number
  function ic:subtract(key, value, default)
    local result = (self.data[key] or default) - value
    self.data[key] = result
    return result
  end

  --- @mutative
  --- @spec #multiply(key: String, value: Number, default: Number): Number
  function ic:multiply(key, value, default)
    local result = (self.data[key] or default) * value
    self.data[key] = result
    return result
  end

  --- @mutative
  --- @spec #divide(key: String, value: Number, default: Number): Number
  function ic:divide(key, value, default)
    local result = (self.data[key] or default) / value
    self.data[key] = result
    return result
  end

  --- @mutative
  --- @spec #apply(key: String, mapper: Function/1): Any
  function ic:apply(key, mapper, default)
    local result = mapper(self.data[key] or default)
    self.data[key] = result
    return result
  end

  --- @mutative
  --- @spec #insert(tab: Table): self
  function ic:insert(tab)
    for key, value in pairs(tab) do
      self.data[key] = value
    end
    return self
  end

  --- @mutative
  --- @spec #merge(other: Properties): self
  function ic:merge(other)
    return self:insert(other.data)
  end

  --- @mutative
  --- @spec #insert_apply(tab: Table, mapper: Function/2): self
  function ic:insert_apply(tab, mapper)
    for key, value in pairs(tab) do
      self.data[key] = mapper(self.data[key], value)
    end
    return self
  end

  --- @mutative
  --- @spec #merge_apply(other: Properties, mapper: Function/2): self
  function ic:merge_apply(other, mapper)
    return self:insert_apply(other.data, mapper)
  end

  --- @mutative
  --- @spec #clear(): self
  function ic:clear()
    self.data = {}
    return self
  end

  --- @mutative
  --- @spec #delete(key: String): self
  function ic:delete(key)
    self.data[key] = nil
    return self
  end

  --- @mutative
  --- @spec #drop(...: String[]): self
  function ic:drop(...)
    local len = select('#', ...)
    if len > 0 then
      local x
      for i = 1,len do
        x = select(i, ...)
        self.data[x] = nil
      end
    end
    return self
  end

  --- @mutative
  --- @spec #pop(key: String): Any
  function ic:pop(key)
    local value = self.data[key]
    self.data[key] = nil
    return value
  end

  --- @mutative
  --- @spec #take(...: String[]): Table
  function ic:take(...)
    local len = select('#', ...)
    local result = {}
    if len > 0 then
      local x
      local y
      for i = 1,len do
        x = select(i, ...)
        y = self.data[x]
        if y ~= nil then
          self.data[x] = nil
          result[x] = y
        end
      end
    end

    return result
  end

  --- @spec #get(key: String, default: Any): Any
  function ic:get(key, default)
    local value = self.data[key]
    if value == nil then
      return default
    end
    return value
  end

  --- @since "2026.5.21"
  --- @spec #get_lazy(key: String, callback: Function/0): Any
  function ic:get_lazy(key, callback)
    local value = self.data[key]
    if value == nil then
      return callback()
    end
    return value
  end

  --- @spec #has_key(key: String): Boolean
  function ic:has_key(key)
    return self.data[key] ~= nil
  end

  --- @spec is_empty(): Boolean
  function ic:is_empty()
    return next(self.data) == nil
  end
end

return Properties
