local table_copy = assert(require("balm/m/table").copy)
local Object = require("balm/object")

--- @class IDGenerator
local IDGenerator = Object:extends("balm.u.IDGenerator")
do
  local ic = IDGenerator.instance_class

  --- @override
  --- @spec #initialize(options: Table): void
  function ic:initialize(options)
    options = options or {}
    self._super.initialize(self)
    if self.x == false then
      self.x = false
    else
      self.x = options.x or 0
    end
    self.vanity = options.vanity and table_copy(options.vanity) or {}
    self.id_to_vanity = options.id_to_vanity and table_copy(options.id_to_vanity) or {}

    for vanity_id, id in pairs(self.vanity) do
      self.id_to_vanity[id] = vanity_id
    end
    for id, vanity_id in pairs(self.id_to_vanity) do
      self.vanity[vanity_id] = id
    end
  end

  --- Now normally, you shouldn't be copying an ID generator just make a new one.
  --- But in the ODD case that you do, this is to protect you from utterly screwing up.
  --- @override
  --- @spec #initialize_copy(other: IDGenerator): void
  function ic:initialize_copy(other)
    ic._super.initialize(self, other)
    self.vanity = table_copy(other.vanity)
    self.id_to_vanity = table_copy(other.id_to_vanity)
  end

  --- @spec #disable(): self
  function ic:disable()
    self.x = false
    return self
  end

  --- @spec #reset(): void
  function ic:reset()
    if self.x ~= false then
      self.x = 0
    end
    self.vanity = {}
    self.id_to_vanity = {}
  end

  --- Generates the next ID in sequence, optionally a vanity_id can be passed in to save the
  --- specific id with a known name.
  --- @spec #next(vanity_id?: String): ID
  function ic:next(vanity_id)
    if vanity_id then
      if self.vanity[vanity_id] then
        error("vanity id already exists")
      end
    end
    if self.x == false then
      error("cannot retrieve next id, as accumulator is disabled")
    end
    self.x = self.x + 1
    if vanity_id then
      self:add_vanity(self.x, vanity_id)
    end
    return self.x
  end

  --- @spec #add_vanity(id: ID, vanity_id: String): self
  function ic:add_vanity(id, vanity_id)
    if self.vanity[vanity_id] then
      error("vanity id already exists")
    end
    self.vanity[vanity_id] = id
    self.id_to_vanity[id] = vanity_id
    return self
  end

  --- Removes any associated vanity ids for the given id.
  --- @spec #remove_id(id: ID): void
  function ic:remove_id(id)
    local vanity_id = self.id_to_vanity[id]
    if vanity_id then
      self.vanity[vanity_id] = nil
      self.id_to_vanity[id] = nil
    end
  end

  --- @spec #get_vanity(id: ID): String | nil
  function ic:get_vanity(id)
    return self.id_to_vanity[id]
  end

  --- @spec #get_id(vanity_id: String): ID | nil
  function ic:get_id(vanity_id)
    return self.vanity[vanity_id]
  end
end

return IDGenerator
