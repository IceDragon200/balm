--- @namespace balm
local setmetatable = setmetatable

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

function Object.__mt:__tostring()
  return "Class<" .. self._name .. ">"
end

function Object.__imt:__tostring()
  return self._class._name .. ":" .. self.__id
end

Object.instance_class._class = Object
Object.__imt.__index = Object.instance_class

--- @spec #initialize(...): void
function Object.instance_class:initialize()
  --
end

--- Helper function for returning the object as a string
--- Reports the class name by default, can be overriden
function Object.instance_class:to_string()
  return self._class._name
end

--- Invokes callback and passes self as the first argument
---
--- @spec tap(callback :: (self) => void, ...args) :: self
function Object.instance_class:tap(callback, ...)
  callback(self, ...)
  return self
end

--- @spec #method(name): Function
function Object.instance_class:method(name)
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
function Object.instance_class:is_instance_of(expected_class)
  return self._class:is_child_of(expected_class)
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
    _super = super_class,
    __mt = {},
    __imt = {},
    name = name,
    instance_class = {},
  }

  klass.instance_class._super = super_class.instance_class
  klass.instance_class._class = klass

  klass.__mt.__index = super_class
  klass.__imt.__index = klass.instance_class

  setmetatable(klass, klass.__mt)
  setmetatable(klass.instance_class, super_class.__imt)

  return klass
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
