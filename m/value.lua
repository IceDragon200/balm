local table_concat = assert(table.concat)
local string_format = assert(string.format)
local Limits = require("balm/limits")

--- @namespace balm.m.value
local m = {}

local function inspect_write(self, x)
  self.i = self.i + 1
  self.data[self.i] = x
end

---
--- @since "2026.5.9"
--- @spec inspect(root: Any, ctx: Any, is_raw: Boolean): String
function m.inspect(root, ctx, is_raw)
  if not ctx then
    ctx = {
      ref_id = 0,
      refs = {},
    }
  end

  local buf = {
    i = 0,
    data = {},
    write = inspect_write,
  }

  local function maybe_ref_write(value)
    ref_id = ctx.refs[value]
    if ref_id == nil then
      ctx.ref_id = ctx.ref_id + 1
      ctx.refs[value] = ctx.ref_id
      buf:write("<&")
      buf:write(ctx.ref_id)
      buf:write(">")
      buf:write(m.inspect(value, ctx))
    else
      buf:write("*")
      buf:write(ref_id)
    end
  end

  local ty = type(root)
  if "userdata" == ty then
    return string_format("<$%q>", root)
  elseif "table" == ty  then
    if not is_raw and type(root.inspect) == "function" then
      return root:inspect(ctx)
    end

    local ref_id
    local idx = 0
    buf:write("{")
    for key, value in pairs(root) do
      if idx > 0 then
        buf:write(",")
      end
      idx = idx + 1
      if type(key) == "table" then
        maybe_ref_write(key)
      else
        buf:write(m.inspect(key, ctx))
      end
      buf:write("=")
      if type(value) == "table" then
        maybe_ref_write(value)
      else
        buf:write(m.inspect(value, ctx))
      end
    end
    buf:write("}")
    return table_concat(buf.data, "")
  elseif ty == "function" then
    return string_format("%s", root)
  elseif ty == "number" then
    if root >= Limits.IMIN[52] and root <= Limits.IMAX[52] then
      return string_format("%d", root)
    else
      return string_format("%f", root)
    end
  else
    return string_format("%q", root)
  end
end

--- @since "2024.7.23"
--- @spec is_blank(value: Any): Boolean
function m.is_blank(value)
  if value == nil then
    return true
  elseif value == "" then
    return true
  else
    return false
  end
end

local is_blank = m.is_blank

---
--- Takes a list of arguments, and returns the first non-blank one
---
--- @since "2024.7.23"
--- @spec first_present(...Any): Any
function m.first_present(...)
  for _, value in ipairs({...}) do
    if not is_blank(value) then
      return value
    end
  end
  return nil
end

---
---
--- @since "2024.7.23"
--- @spec deep_equals(Value, Value, depth: Integer, max_depth: Integer = 20): Boolean
local function deep_equals(a, b, depth, max_depth)
  depth = depth or 0
  max_depth = max_depth or 20
  if depth > max_depth then
    error("deep_equals depth exceeded")
  end

  if type(a) == type(b) then
    if type(a) == "table" then
      local keys = {}
      for k, _ in pairs(a) do
        keys[k] = true
      end
      for k, _ in pairs(b) do
        keys[k] = true
      end

      for k, _ in pairs(keys) do
        if not deep_equals(a[k], b[k], depth + 1) then
          return false
        end
      end
      return true
    else
      return a == b
    end
  else
    return false
  end
end

m.deep_equals = deep_equals

--- @since "2026.5.9"
--- @spec matches(lhv: Any, pattern: Any): Boolean
function m.matches(lhv, pattern)
  if rawequal(lhv, pattern) then
    return true
  end
  if type(lhv) == "table" then
    if type(lhv.matches) == "function" then
      return lhv:matches(pattern)
    elseif lhv.matches == false then
      -- always return false
      return false
    end

    return m.rawmatches(lhv, pattern)
  end
  return false
end

--- @since "2026.5.9"
--- @spec rawmatches(lhv: Any, pattern: Any): Boolean
function m.rawmatches(lhv, pattern)
  if type(pattern) == "table" then
    for key, rhp in pairs(pattern) do
      if not m.matches(lhv[key], rhp) then
        return false
      end
    end
    return true
  end
  return false
end

return m
