local Sys = require("balm/sys")
local BIT_LUA = require("balm/u/bit/lua")
local BIT_NATIVE
if Sys.can_require("bit") then
  BIT_NATIVE = require("bit")
end

local m = {
  _imports = {},
}
for key, value in pairs(BIT_LUA) do
  m._imports[key] = "lua"
  m[key] = BIT_LUA[key]
  if BIT_NATIVE then
    local fn = BIT_NATIVE[key]
    if fn then
      m._imports[key] = "native"
      m[key] = fn
    end
  end
end
return m
