local Object = require("balm/object")

--- @namespace balm.s

---
--- A data matrix is a 3 dimnensional data map.
--- The data itself is stored linearly as a massive table encoded in the order: z (plane) y (column) x (row)
---
--- @since "2024.7.23"
--- @class DataMatrix<T>
local DataMatrix = Object:extends("balm.DataMatrix")

do
  local ic = DataMatrix.instance_class

  --- @spec #initialize(w: Integer, h: Integer, d: Integer, callback: Function): void
  --- @spec #initialize(w: Integer, h: Integer, d: Integer, default: Any): void
  function ic:initialize(w, h, d, default_or_callback)
    ic._super.initialize(self)

    self.m_w = w
    self.m_h = h
    self.m_d = d
    self.m_size = 0

    self:_validate_declared_size()
    self:_initialize_data(default_or_callback)
  end

  function ic:_validate_declared_size()
    assert(self.m_w > 0, "width must be greater than 0")
    assert(self.m_h > 0, "height must be greater than 0")
    assert(self.m_d > 0, "depth must be greater than 0")

    self.m_size = self.m_w * self.m_h * self.m_d
  end

  function ic:_initialize_data(default_or_callback)
    if default_or_callback == nil then
      self.m_data = {}
    elseif type(default_or_callback) == "function" then
      self:_initialize_data_with_function(default_or_callback)
    else
      self:_initialize_data_with_default(default_or_callback)
    end
  end

  --- @spec #_initialize_data_with_function(Function/4): void
  function ic:_initialize_data_with_function(callback)
    self.m_data = {}
    self:fill_lazy(callback)
  end

  --- @spec #_initialize_data_with_default(Any): void
  function ic:_initialize_data_with_default(default)
    self.m_data = {}
    self:fill(default)
  end

  --- Reports the size in cells of the data matrix
  ---
  --- @spec #size(): Integer
  function ic:size()
    return self.m_size
  end

  --- @spec #fill(Any): void
  function ic:fill(value)
    for i1 = 1,self.m_size do
      self.m_data[i1] = value
    end
  end

  --- @spec #fill_lazy(Function/4): void
  function ic:fill_lazy(callback)
    local x
    local y
    local z
    local i
    for i1 = 1,self.m_size do
      i = i1 - 1
      x = math.floor(i % self.m_w)
      y = math.floor((i / self.m_w) % self.m_h)
      z = math.floor((i / self.m_y) / self.m_w)

      self.m_data[i1] = callback(x, y, z, i)
    end
  end
end

return DataMatrix
