local Object = require("balm/object")
local table_copy = require("balm/m/table").copy
local table_insert = assert(table.insert)

--- @since "2026.7.8"
--- @class OrderedSet<T> extends Object
local OrderedSet = Object:extends("balm.u.OrderedSet")
do
  local ic = OrderedSet.instance_class

  --- @spec #initialize(data: T[] | OrderedSet<T>): void
  function ic:initialize(data)
    ic._super.initialize(self)

    if data then
      if type(data) == "table" then
        if Object.is_object(data) then
          if data:is_instance_of(OrderedSet) then
            self:initialize_copy(data)
          elseif data.to_ordered_set then
            self:initialize_copy(data:to_ordered_set())
          else
            error("Expected object to be an instance of OrderedSet")
          end
        else
          self.m_data = {}
          self.m_cursor = 0

          for _, item in ipairs(data) do
            self:insert(item)
          end
        end
      else
        error("Expected a Table")
      end
    else
      self.m_data = {}
      self.m_cursor = 0
    end
  end

  --- @spec #size(): Number
  function ic:size()
    return self.m_cursor
  end

  --- @spec #is_empty(): Boolean
  function ic:is_empty()
    return self.m_cursor == 0
  end

  --- @spec #insert(...: T[]): self
  function ic:insert(...)
    local len = select('#', ...)
    if len > 0 then
      local x
      local y
      local idx
      for i = 1,len do
        x = select(i, ...)
        idx = self.m_cursor + 1
        if self.m_cursor > 0 then
          for j = 1,self.m_cursor do
            y = self.m_data[j]
            if y == x then
              idx = 0
              break
            elseif x < y then
              idx = j
              break
            end
          end
        end

        if idx > 0 then
          self.m_cursor = self.m_cursor + 1
          table_insert(self.m_data, idx, x)
        end
      end
    end
    return self
  end

  --- @spec #get(index: Number): T | nil
  function ic:get(index)
    if self.m_cursor >= index then
      return self.m_data[index]
    end
    return nil
  end
end

return OrderedSet
