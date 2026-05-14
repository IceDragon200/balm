--
-- General Purpose Vector
--
local assertions = require("balm/m/assertions")
local Object = require("balm/object")

local min = assert(math.min)
local max = assert(math.max)
local abs = assert(math.abs)
local floor = assert(math.floor)
local ceil = assert(math.ceil)
local sqrt = assert(math.sqrt)
local random = assert(math.random)

--- @namespace balm.s

--- @since "2026.5.14"
--- @class Vector
local Vector = Object:extends("balm.s.Vector")
do
  local ic = Vector.instance_class

  --- Args:
  --- * options [Table]
  ---   * size [Number] - the initialize size of the vector it will be backfilled
  ---                     with the default value or 0
  ---   * default [Number] - when backfilling, this overrides the default value (default: 0)
  --- @override
  --- @spec #initialize(options: Table): void
  function ic:initialize(options)
    options = options or {}
    ic._super.initialize(self)

    --- @member m_size: Number
    self.m_size = 0

    --- @member m_data: Table
    self.m_data = {}

    --- @member m_default: Number
    self.m_default = assertions.is_number(options.default or 0)

    self:resize(assertions.is_number(options.size or 0))
  end

  --- @override
  --- @spec #initialize_copy(other: Vector): void
  function ic:initialize_copy(other)
    ic._super.initialize_copy(self, other)
    self.m_data = {}
    if self.m_size > 0 then
      for i = 1,self.m_size do
        self.m_data[i] = other.m_data[i]
      end
    end
  end

  --- @override
  --- @spec #equals(other: Any): void
  function ic:equals(other)
    if Object.is_object(other, Vector) then
      if self.m_size == other.m_size then
        if self.m_size > 0 then
          for i = 1,self.m_size do
            if self.m_data[i] ~= other.m_data[i] then
              return false
            end
          end
        end
        return true
      end
    end
    return false
  end

  --- @spec #size(): Integer
  function ic:size()
    return self.m_size
  end

  --- @spec #is_empty(): Boolean
  function ic:is_empty()
    return self.m_size <= 0
  end

  --- @spec #clear(): self
  function ic:clear()
    self.m_size = 0
    self.m_data = {}
    return self
  end

  --- @spec #resize(size: Number): self
  function ic:resize(size)
    if self.m_size > size then
      for i = size+1,self.m_size do
        self.m_data[i] = nil
      end
    elseif self.m_size < size then
      for i = self.m_size+1,size do
        self.m_data[i] = self.m_default
      end
    end
    self.m_size = size
    return self
  end

  --- @spec #fill(value: Number): self
  function ic:fill(value)
    if self.m_size > 0 then
      for i = 1,self.m_size do
        self.m_data[i] = value
      end
    end
    return self
  end

  --- @spec #random(max: Number, min?: Number): self
  function ic:random(mx, mn)
    mn = mn or 0
    local d = (mx - mn) + 1
    if self.m_size > 0 then
      for i = 1,self.m_size do
        self.m_data[i] = mn + random(d) - 1
      end
    end
    return self
  end

  --- @spec #randomf(max: Number, min?: Number): self
  function ic:randomf(mx, mn)
    mn = mn or 0
    local d = mx - mn
    if self.m_size > 0 then
      for i = 1,self.m_size do
        self.m_data[i] = mn + random() * d
      end
    end
    return self
  end

  --- @spec #get(idx: Number): Number
  function ic:get(idx)
    if idx > 0 and idx <= self.m_size then
      return self.m_data[idx]
    end
    return self.m_default
  end

  --- @spec #put(idx: Number, x: Number): self
  function ic:put(idx, x)
    if idx > 0 and idx <= self.m_size then
      self.m_data[idx] = x
    end
    return self
  end

  --- Adds two vectors together, storing the result in the callee.
  --- @spec #add(a: Vector, b: Vector): self
  function ic:add(a, b)
    local len = min(min(self.m_size, a.m_size), b.m_size)
    if len > 0 then
      for i = 1,len do
        self.m_data[i] = a.m_data[i] + b.m_data[i]
      end
    end
    return self
  end

  --- Subtracts vector b from a, storing its result in the callee.
  --- @spec #subtract(a: Vector, b: Vector): self
  function ic:subtract(a, b)
    local len = min(min(self.m_size, a.m_size), b.m_size)
    if len > 0 then
      for i = 1,len do
        self.m_data[i] = a.m_data[i] - b.m_data[i]
      end
    end
    return self
  end

  --- @alias sub = subtract
  ic.sub = ic.subtract

  --- Multiplies vector a by b and stores the result in the callee.
  --- @spec #multiply(a: Vector, b: Vector): self
  function ic:multiply(a, b)
    local len = min(min(self.m_size, a.m_size), b.m_size)
    if len > 0 then
      for i = 1,len do
        self.m_data[i] = a.m_data[i] * b.m_data[i]
      end
    end
    return self
  end

  --- @alias mul = multiply
  ic.mul = ic.multiply

  --- Divides vector a by b and stores the result in the callee.
  --- @spec #divide(a: Vector, b: Vector): self
  function ic:divide(a, b)
    local len = min(min(self.m_size, a.m_size), b.m_size)
    if len > 0 then
      for i = 1,len do
        self.m_data[i] = a.m_data[i] / b.m_data[i]
      end
    end
    return self
  end

  --- @alias div = divide
  ic.div = ic.divide

  --- Determines the minimum values between vectors a and b and stores the result in the callee.
  --- @spec #min(a: Vector, b: Vector): self
  function ic:min(a, b)
    local len = min(min(self.m_size, a.m_size), b.m_size)
    if len > 0 then
      for i = 1,len do
        self.m_data[i] = min(a.m_data[i], b.m_data[i])
      end
    end
    return self
  end

  --- Determines the maximum values between vectors a and b and stores the result in the callee.
  --- @spec #max(a: Vector, b: Vector): self
  function ic:max(a, b)
    local len = min(min(self.m_size, a.m_size), b.m_size)
    if len > 0 then
      for i = 1,len do
        self.m_data[i] = max(a.m_data[i], b.m_data[i])
      end
    end
    return self
  end

  --- Adds two vectors together, storing the result in the callee.
  --- @spec #apply(a: Vector, b: Vector, callback: Function/2): self
  function ic:apply(a, b, callback)
    local len = min(min(self.m_size, a.m_size), b.m_size)
    if len > 0 then
      for i = 1,len do
        self.m_data[i] = callback(a.m_data[i], b.m_data[i])
      end
    end
    return self
  end

  --- @spec #reverse(): self
  function ic:reverse()
    if self.m_size > 0 then
      local x = 1
      local y = self.m_size
      while x < y do
        self.m_data[y], self.m_data[x] = self.m_data[x], self.m_data[y]
        x = x + 1
        y = y - 1
      end
    end
    return self
  end

  --- @spec #negate(): self
  function ic:negate()
    if self.m_size > 0 then
      for i = 1,self.m_size do
        self.m_data[i] = -self.m_data[i]
      end
    end
    return self
  end

  --- @spec #floor(): self
  function ic:floor()
    if self.m_size > 0 then
      for i = 1,self.m_size do
        self.m_data[i] = floor(self.m_data[i])
      end
    end
    return self
  end

  --- @spec #ceil(): self
  function ic:ceil()
    if self.m_size > 0 then
      for i = 1,self.m_size do
        self.m_data[i] = ceil(self.m_data[i])
      end
    end
    return self
  end

  --- @spec #abs(): self
  function ic:abs()
    if self.m_size > 0 then
      for i = 1,self.m_size do
        self.m_data[i] = abs(self.m_data[i])
      end
    end
    return self
  end

  --- Calculates the Euclidean magnitude (length) of this vector.
  --- @spec #magnitude(): Number
  function ic:magnitude()
    local sum = 0
    if self.m_size > 0 then
      for i = 1, self.m_size do
        local val = self.m_data[i]
        sum = sum + (val * val)
      end
    end
    return sqrt(sum)
  end

  --- @alias length = magnitude
  ic.length = ic.magnitude

  --- Calculates the Euclidean distance between this vector and another.
  --- @spec #distance(other: Vector): Number
  function ic:distance(other)
    local len = min(self.m_size, other.m_size)
    local sum = 0
    if len > 0 then
      for i = 1, len do
        local diff = self.m_data[i] - other.m_data[i]
        sum = sum + (diff * diff)
      end
    end
    return sqrt(sum)
  end

  --- Returns a random number in the vector.
  --- Returns nil if the vector is empty.
  --- @spec #sample(): Number | nil
  function ic:sample()
    if self.m_size > 0 then
      return self.m_data[random(self.m_size)]
    end
    return self.m_default
  end
end

do
  local mt = Vector.__imt

  --- @spec #+(other: Vector): Vector
  function mt:__add(other)
    local dest = Vector:alloc()
    dest.m_size = self.m_size
    dest.m_data = {}
    return dest:add(self, other)
  end

  --- @spec #-(other: Vector): Vector
  function mt:__sub(other)
    local dest = Vector:alloc()
    dest.m_size = self.m_size
    dest.m_data = {}
    return dest:subtract(self, other)
  end

  --- @spec #*(other: Vector): Vector
  function mt:__mul(other)
    local dest = Vector:alloc()
    dest.m_size = self.m_size
    dest.m_data = {}
    return dest:multiply(self, other)
  end

  --- @spec #/(other: Vector): Vector
  function mt:__div(other)
    local dest = Vector:alloc()
    dest.m_size = self.m_size
    dest.m_data = {}
    return dest:divide(self, other)
  end

  --- @spec #-@(): Vector
  function mt:__unm()
    return self:copy():negate()
  end
end

return Vector
