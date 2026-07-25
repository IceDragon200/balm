--- @namespace balm.sys
local m = {}

--- @const capabilities: Table
m.capabilities = {}
m.capabilities.string_format = pcall(function ()
  string.format("%s", "test")
  return true
end)
m.capabilities.string_format_p = pcall(function ()
  string.format("%p", {})
  return true
end)

--- @spec can_require(name: String): (exists: true, path: String) | (exists: false, err: Any)
function m.can_require(name)
  if package.loaded[name] ~= nil then
    return true
  end

  local path, err = package.searchpath(name, package.path)

  if path then
    return true, path
  else
    return false, err
  end
end

local has_global_warning = false

function m.setup_global_warning()
  if has_global_warning then
    return
  end

  local debug_getinfo, rawset = debug.getinfo, rawset

  local meta = {}
  local declared = {}
  -- Key is source file, line, and variable name; separated by NULs
  local warned = {}

  function meta:__newindex(name, value)
    rawset(self, name, value)
    if declared[name] then
      return
    end
    local info = debug_getinfo(2, "Sl")
    if info ~= nil then
      local desc = ("%s:%d"):format(info.short_src, info.currentline)
      local warn_key = ("%s\0%d\0%s"):format(info.source, info.currentline, name)
      if not warned[warn_key] and info.what ~= "main" and info.what ~= "C" then
        error(("Assignment to undeclared global %q inside a function at %s.")
            :format(name, desc))
        warned[warn_key] = true
      end
    end
    declared[name] = true
  end

  function meta:__index(name)
    if declared[name] then
      return
    end
    local info = debug_getinfo(2, "Sl")
    if info == nil then
      return
    end
    local warn_key = ("%s\0%d\0%s"):format(info.source, info.currentline, name)
    if not warned[warn_key] and info.what ~= "C" then
      error(("Undeclared global variable %q accessed at %s:%s")
          :format(name, info.short_src, info.currentline))
      warned[warn_key] = true
    end
  end

  setmetatable(_G, meta)
  has_global_warning = true
end

return m
