--- @namespace balm
local assertions = require("balm/m/assertions")
local table_copy = require("balm/m/table").copy
local Object = require("balm/object")

--- Record data instance, created with RecordsHead#new.
---
--- @since "2026.5.4"
--- @class RecordsList
local RecordsList = Object:extends("balm.RecordsList")
do
  local ic = RecordsList.instance_class

  --- @spec #initialize(head: RecordsHead): void
  function ic:initialize(head)
    ic._super.initialize(self)

    --- @member head: RecordsHead
    self.m_head = head

    --- @member data: Table
    self.m_data = {}

    --- @member dsize: Integer
    self.m_dsize = 0

    --- @member size: Integer
    self.m_size = 0
  end

  --- @spec #initialize_copy(other: self): void
  function ic:initialize_copy(other)
    ic._super.initialize_copy(self, other)
    self.m_data = {}
    if other.m_size > 0 then
      for i = 1,other.m_size do
        self.m_data[i] = other.m_data[i]
      end
    end
  end

  --- @spec #size(): Integer
  function ic:size()
    return self.m_size
  end

  --- @spec #datasize(): Integer
  function ic:datasize()
    return self.m_dsize
  end

  --- @spec #clear(): void
  function ic:clear()
    self.m_data = {}
    self.m_size = 0
    self.m_dsize = 0
  end

  function ic:_push_datum(item)
    self.m_dsize = self.m_dsize + 1
    self.m_data[self.m_dsize] = item
  end

  --- @spec #push(Table): void
  function ic:push(row)
    assertions.is_table(row)
    for _, key in ipairs(self.m_head.m_headers) do
      self:_push_datum(row[key])
    end
    self.m_size = self.m_size + 1
  end

  --- @spec #pop(): Table | nil
  function ic:pop()
    if self.m_size > 0 then
      self.m_size = self.m_size - 1
      self.m_dsize = self.m_dsize - self.m_head.m_size
      local result = {}
      local x
      for i, key in ipairs(self.m_head.m_headers) do
        x = self.m_dsize + i
        result[key] = self.m_data[x]
        self.m_data[x] = nil
      end
      return result
    end
    return nil
  end

  --- @spec #get_cell(idx: Integer, key: String): Any
  function ic:get_cell(idx, key)
    if idx > 0 and idx <= self.m_size then
      local ci = self.m_head.m_h2i[key]
      if ci then
        return self.m_data[(idx - 1) * self.m_head.m_size + ci]
      end
    end
    return nil
  end
end

--- @class RecordsHead
local RecordsHead = Object:extends("balm.RecordsHead")
do
  local ic = RecordsHead.instance_class

  --- @spec #initialize(...: String[]): void
  function ic:initialize(...)
    ic._super.initialize(self)
    self.m_size = select('#', ...)
    self.m_headers = {...}
    assert(self.m_size > 0, "expected headers")
    self.m_h2i = {}
    for i, key in ipairs(self.m_headers) do
      self.m_h2i[key] = i
    end
  end

  --- Creates a new RecordsList instance which can accept rows.
  ---
  --- @spec #new(): RecordsList
  function ic:new()
    return RecordsList:new(self)
  end

  --- @spec #col(idx: Integer): String | nil
  function ic:col(idx)
    return self.m_headers[idx]
  end

  --- @spec #keys(): Table
  function ic:keys()
    return table_copy(self.m_headers)
  end
end

return RecordsHead
