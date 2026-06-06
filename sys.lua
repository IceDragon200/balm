--- @namespace balm.sys
local m = {}

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

return m
