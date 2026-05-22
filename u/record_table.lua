local assertions = require("balm/m/assertions")
local table_copy = assert(require("balm/m/table").copy)
local ID128Generator = require("balm/u/id128_generator")
local Object = require("balm/object")

--- @namespace balm.u

--- Record tables are simple structures for holding in-game objects with an incrementing ID.
--- Optionally "records" can have a vanity_id which is a known name.
--- @class RecordTable<T>
local RecordTable = Object:extends("balm.u.RecordTable")
do
  local ic = RecordTable.instance_class

  --- @override
  --- @spec #initialize(options: Table): void
  function ic:initialize(options)
    options = options or {}
    ic._super.initialize(self)

    --- @member id_generator: IDGenerator
    self.id_generator = ID128Generator:new(options.id_generator)

    --- @member id_generator: Record<ID, T>
    self.data = options.data and table_copy(options.data) or {}
  end

  --- @override
  --- @spec #initialize_copy(other: RecordTable): void
  function ic:initialize_copy(other)
    ic._super.initialize_copy(self, other)

    self.id_generator = other.id_generator:copy()
    self.data = table_copy(other.data)
  end

  --- Copies not only the record table, but also its data deeply.
  --- @spec #deep_copy(): void
  function ic:deep_copy()
    local other = self:copy()
    local data = other.data
    other.data = {}
    for id, obj in pairs(data) do
      if type(obj.deep_copy) == "function" then
        other.data[id] = obj:deep_copy()
      elseif type(obj.copy) == "function" then
        other.data[id] = obj:copy()
      else
        other.data[id] = table_copy(obj)
      end
    end
    return other
  end

  --- @spec #reset(): void
  function ic:reset()
    self.id_generator:reset()
    self.data = {}
  end

  --- @spec #put(id: ID, vanity_id: String, subject: T): T
  function ic:put(id, vanity_id, subject)
    self.id_generator:add_vanity(id, vanity_id)
    subject.id = id
    subject.vanity_id = vanity_id
    self.data[id] = subject
    return subject
  end

  --- @spec #add(vanity_id: String, subject: T): T
  function ic:add(vanity_id, subject)
    if not self.id_generator then
      error("cannot add records to this table without an id generator, try #put/2 intsead")
    end
    local id = self.id_generator:next(vanity_id)
    subject.id = id
    subject.vanity_id = vanity_id
    self.data[subject.id] = subject
    return subject
  end

  --- @spec #import(record: Record<ID, T>): self
  function ic:import(record)
    if next(self.data) then
      error("cannot import if data is not empty")
    end
    for key, value in pairs(record) do
      assertions.is_number(key)
      self.id_generator.x = math.max(self.id_generator.x, key)
      self.data[key] = value
    end
    return self
  end

  --- @spec #remove_by_id(id: ID): T | nil
  function ic:remove_by_id(id)
    local subject = self.data[id]
    if subject then
      self.data[id] = nil
      self.id_generator:remove_id(id)
      return subject
    end
    return nil
  end

  --- @spec #remove_by_vanity_id(vanity_id: ID): T | nil
  function ic:remove_by_vanity_id(vanity_id)
    local id = self.id_generator.vanity[vanity_id]
    if id then
      local subject = self.data[id]
      if subject then
        self.data[id] = nil
        self.id_generator:remove_id(id)
        return subject
      end
    end
    return nil
  end

  --- @spec #get_id(vanity_id: String): ID | nil
  function ic:get_id(vanity_id)
    return self.id_generator:get_id(vanity_id)
  end

  --- @spec #get(id: ID): T | nil
  function ic:get(id)
    return self.data[id]
  end

  --- @spec #get_by_vanity_id(vanity_id: String): T | nil
  function ic:get_by_vanity_id(vanity_id)
    local id = self.id_generator:get_id(vanity_id)
    if id then
      return self.data[id]
    end
    return nil
  end

  --- @spec #fetch_id(vanity_id: String): ID | nil
  function ic:fetch_id(vanity_id)
    local id = self.id_generator:get_id(vanity_id)
    if id then
      return id
    end
    error("no id for vanity_id=" .. vanity_id)
  end

  --- @spec #fetch(id: ID): T
  function ic:fetch(id)
    local subject = self.data[id]
    if not subject then
      error("record does not exist id=" .. id)
    end
    return subject
  end

  --- @spec #fetch_by_vanity_id(vanity_id: String): T
  function ic:fetch_by_vanity_id(vanity_id)
    local id = self.id_generator.vanity[vanity_id]
    if not id then
      error("record does not exist vanity_id=" .. vanity_id)
    end
    local subject = self.data[id]
    if not subject then
      error("CRITICAL: record does not exist id=" .. id)
    end
    return subject
  end

  --- @spec #has_id(id: ID): Boolean
  function ic:has_id(id)
    return self.data[id] ~= nil
  end

  --- @since "2026.5.21"
  --- @spec #each(callback: Function/2): self
  function ic:each(callback)
    for id, entry in pairs(self.data) do
      callback(entry, id)
    end
    return self
  end
end

return RecordTable
