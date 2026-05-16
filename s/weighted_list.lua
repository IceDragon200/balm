local Object = require("balm/object")
local table_copy = require("balm/m/table").copy

--- @namespace balm.s

--- @since "2026.5.15"
--- @class WeightedList<T>
local WeightedList = Object:extends("balm.s.WeightedList")
do
  local ic = assert(WeightedList.instance_class)
  --- @override
  --- @spec #initialize(): void
  function ic:initialize()
    ic._super.initialize(self)

    self.m_weights = {}
    self.m_weight_at_index = {}
    self.m_data = {}
    self.m_size = 0
    self.m_total_weight = 0
  end

  --- @override
  --- @spec #initialize_copy(other: WeightedList): void
  function ic:initialize_copy(other)
    ic._super.initialize_copy(self, other)
    self.m_weights = table_copy(other.m_weights)
    self.m_weight_at_index = table_copy(other.m_weight_at_index)
    self.m_data = table_copy(other.m_data)
  end

  --- @spec #size(): Number
  function ic:size()
    return self.m_size
  end

  --- @spec #total_weight(): Number
  function ic:total_weight()
    return self.m_total_weight
  end

  ---
  --- Push item with specific weight unto the list
  ---
  --- @spec #push(item: T, weight: Integer): self
  function ic:push(item, weight)
    assert(type(weight) == "number", "expected weight value to be a number")
    assert(weight > 0, "weight must be greater than 0")

    self.m_size = self.m_size + 1

    self.m_data[self.m_size] = item
    self.m_weights[self.m_size] = weight
    self.m_total_weight = self.m_total_weight + weight
    self.m_weight_at_index[self.m_size] = self.m_total_weight

    return self
  end

  ---
  --- Retrieve item in weight value
  ---
  --- @spec #get_item_within_weight(expected_weight: Integer): (value: T, index: Integer)
  function ic:get_item_within_weight(expected_weight)
    assert(type(expected_weight) == "number", "expected number for expected_weight")

    if expected_weight < 1 then
      return nil
    elseif expected_weight > self.m_total_weight then
      return nil
    end

    -- Binary search
    local lo = 1
    local hi = self.m_size
    local idx
    local weight
    local prev_weight

    while lo <= hi do
      idx = lo + math.floor((hi - lo) / 2)
      weight = self.m_weight_at_index[idx]
      prev_weight = self.m_weight_at_index[idx - 1] or 0

      if expected_weight > weight then
        -- the expected is higher than the current
        lo = idx + 1
      elseif expected_weight <= prev_weight then
        -- the expected is less than the current
        hi = idx - 1
      else
        -- within range
        return self.m_data[idx], idx
      end
    end

    return nil, nil
  end

  ---
  --- Randomly select an item from the list
  ---
  --- @spec #random(): T
  function ic:random()
    if self.m_total_weight > 0 then
      local weight = math.random(self.m_total_weight)
      return self:get_item_within_weight(weight)
    else
      return nil
    end
  end

  ---
  --- Retrieve a list of random items
  ---
  --- @spec #random_list(Integer): T[]
  function ic:random_list(count)
    local t = {}
    for i = 1,count do
      t[i] = self:random()
    end
    return t
  end
end

return WeightedList
