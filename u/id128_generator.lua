local IDGenerator = require("balm/u/id_generator")
local U128 = require("balm/u/u128")

--- @class ID128Generator
local ID128Generator = IDGenerator:extends("balm.u.ID128Generator")
do
  local ic = ID128Generator.instance_class

  --- @override
  --- @spec #initialize_copy(other: ID128Generator): void
  function ic:initialize_copy(other)
    ic._super.initialize_copy(self, other)
    self.x = other.x:copy()
  end

  --- @override
  --- @spec #init_x(x: Any): U128
  function ic:init_x(x)
    return U128:new(x)
  end

  --- @override
  --- @spec #next_id(): String
  function ic:next_id()
    return self.x:add(1):to_le128_string()
  end
end

return ID128Generator
