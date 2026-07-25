--- @namespace balm
local SYS = require("balm/sys")
local Value = require("balm/m/value")
local rawmatches = assert(Value.rawmatches)
local inspect = assert(Value.inspect)
local setmetatable = setmetatable

local inherited_metamethods = {
  "__tostring",
  -- Math
  "__add",
  "__sub",
  "__mul",
  "__div",
  "__unm",
  "__mod",
  "__pow",
  "__idiv", -- 5.3
  -- Logical Operators
  "__eq",
  "__lt",
  "__gt",
  -- Misc
  "__concat",
  "__len",
  -- Invocation
  "__call",
}

--- @class Object
local Object = {
  _super = nil,
  _is_class = true,
  _name = "Object",
  __mt = {},
  __imt = {},
  instance_class = {
    _is_instance_class = true,
  }
}

setmetatable(Object, Object.__mt)

Object.instance_class._class = Object
Object.__imt.__index = Object.instance_class

local default_inspect
local default_class_to_string
local default_instance_to_string

if string.format then
  local string_format = assert(string.format)

  if SYS.capabilities.string_format_p then
    --- @since "2026.5.9"
    function default_inspect(self, ctx)
      return string_format("#<%s:%p %s>", self._class._name, self, inspect(self, ctx, true))
    end

    --- @since "2026.5.9"
    function default_class_to_string(self)
      return string_format("Class<%s:%p>", self._name, self)
    end

    --- @since "2026.5.9"
    function default_instance_to_string(self)
      return string_format("#<%s:%p>", self._class._name, self)
    end
  else
    --- @since "2026.5.9"
    function default_inspect(self, ctx)
      return string_format("#<%s:X %s>", self._class._name, inspect(self, ctx, true))
    end

    --- @since "2026.5.9"
    function default_class_to_string(self)
      return string_format("Class<%s:X>", self._name)
    end

    --- @since "2026.5.9"
    function default_instance_to_string(self)
      return string_format("#<%s:X>", self._class._name)
    end
  end
end

do
  --- @since "2026.5.9"
  --- @spec &%__tostring(): String
  Object.__mt.__tostring = default_class_to_string

  --- @since "2026.5.9"
  --- @spec %__tostring(): String
  function Object.__imt:__tostring()
    if type(self.__tostring) == "function" then
      return self:__tostring()
    elseif type(self.to_string) == "function" then
      return self:to_string()
    end
    return default_instance_to_string(self)
  end

  --- @since "2026.5.9"
  --- @spec %__eq(): Boolean
  function Object.__imt:__eq(other)
    if type(self.equals) == "function" then
      return self:equals(other)
    end
    return false
  end
end

do
  local ic = Object.instance_class


  --- Initializes the properties of a new object, note this is not called for copied objects
  --- see #initialize_copy/1 instead.
  ---
  --- @overridable
  --- @spec #initialize(...): void
  function ic:initialize()
    --
  end

  --- Called when an object is to be copied, the `other` will be the original object that is being
  --- copied.
  ---
  --- @overridable
  --- @spec #initialize_copy(other: self): void
  function ic:initialize_copy(other)
    for key, value in pairs(other) do
      rawset(self, key, value)
    end
  end

  --- Creates a copy of the object.
  ---
  --- @spec #copy(): self
  function ic:copy()
    local other = self._class:alloc()
    other:initialize_copy(self)
    return other
  end

  --- Compares two objects and attempts a simple equality test.
  --- This is just a least effort equality check and can be incorrect.
  --- When in doubt, override this function yourself.
  --- @overridable
  --- @spec #equals(other): Boolean
  function ic:equals(other)
    if rawequal(self, other) then
      return true
    end
    if Object.is_object(other, self._class) then
      for key, value in pairs(other) do
        if self[key] ~= value then
          return false
        end
      end
      return true
    end
    return false
  end

  --- Compares two objects and attempts a simple equality test.
  --- This is just a least effort equality check and can be incorrect.
  --- When in doubt, override this function yourself.
  --- @overridable
  --- @spec #matches(pattern): Boolean
  ic.matches = rawmatches

  --- Helper function for returning the object as a string
  --- Reports the class name by default, can be overriden
  --- @since "2026.5.9"
  --- @spec #to_string(): String
  ic.to_string = default_instance_to_string

  --- @spec #inspect(): String
  ic.inspect = default_inspect

  --- Invokes callback and passes self as the first argument
  ---
  --- @spec tap(callback :: (self) => void, ...args) :: self
  function ic:tap(callback, ...)
    callback(self, ...)
    return self
  end

  --- @spec #method(name): Function
  function ic:method(name)
    local func = self[name]
    if type(func) == "function" then
      local target = self
      return function (...)
        return func(target, ...)
      end
    else
      error("expected a function named `" .. name .. "` (got a `" .. type(func) .. "` instead)")
    end
  end

  --- Determines if the object is an instance of the given class
  ---
  --- @spec #is_instance_of(expected_class: Object): Boolean
  function ic:is_instance_of(expected_class)
    return self._class:is_child_of(expected_class)
  end
end

--- Determines if this class inherits from ancestor, or is the same class.
--- Returns true if the class is inherits from ancestor, or is the same class.
--- Returns false otherwise.
---
--- @spec &is_child_of(ancestor: Object): Boolean
function Object:is_child_of(ancestor)
  local klass = self
  while klass do
    if klass == ancestor then
      return true
    end
    klass = klass._super
  end
  return false
end

--- @spec &ancestors(): Object[]
function Object:ancestors()
  local klass = self
  local result = {}
  local i = 0
  while klass do
    i = i + 1
    result[i] = klass
    klass = klass._super
  end
  return result
end

--- @spec &extends(String): Object
function Object.extends(super_class, name)
  local klass = {
    _name = name,
    _super = super_class,
    __mt = {},
    __imt = {},
    instance_class = {},
  }

  klass.instance_class._super = super_class.instance_class
  klass.instance_class._class = klass

  for _, mm in ipairs(inherited_metamethods) do
    rawset(klass.__mt, mm, rawget(super_class.__mt, mm))
  end
  klass.__mt.__index = super_class

  for _, mm in ipairs(inherited_metamethods) do
    rawset(klass.__imt, mm, rawget(super_class.__imt, mm))
  end
  klass.__imt.__index = klass.instance_class

  setmetatable(klass, klass.__mt)
  setmetatable(klass.instance_class, super_class.__imt)

  return klass
end

--- @spec &bind_metatable(instance: Table): Any
function Object:bind_metatable(instance)
  setmetatable(instance, self.__imt)
  return instance
end

--- @spec &alloc(): Any
function Object:alloc()
  local instance = {}
  setmetatable(instance, self.__imt)
  return instance
end

--- @spec &new(): Any
function Object:new(...)
  local instance = self:alloc()
  if instance.initialize then
    instance:initialize(...)
  end
  return instance
end

--- @spec &tap(): Any
function Object:tap(callback)
  callback(self)
  return self
end

--- Determines if the given object is some kind of instance class object.
--- Optionally the class can be specified as well to perform an is_instance_of/1
--- check as well.
---
--- @spec is_object(Any, klass?: Object): Boolean
function Object.is_object(object, klass)
  if type(object) == "table" then
    if object._class then
      if klass then
        return object:is_instance_of(klass)
      end
      return true
    end
  end

  return false
end

return Object
