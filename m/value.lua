--- @namespace balm.m.value

local m = {}

--- Similar to minetest's dump/1, but doesn't make it pretty, in other words, it's junked output.
---
--- @since "2024.7.23"
--- @spec inspect(Any, depth: Integer, max_depth: Integer): String
function inspect(value, depth, max_depth)
  depth = depth or 0
  max_depth = max_depth or 20
  if depth > max_depth then
    return "&recursive?"
  end

  local ty = type(value)
  if ty == "table" then
    local result = {}
    for key, value in pairs(value) do
      table.insert(
        result,
        inspect(key, depth + 1) ..
        "=" ..
        inspect(value, depth + 1)
      )
    end
    return "{" .. table.concat(result, ",") .. "}"
  elseif ty == "string" then
    --- TODO: do this properly, bleh
    return "\"" .. tostring(value) .. "\""
  -- elseif ty == "boolean" or ty == "boolean" or ty == "number" then
  else
    return tostring(value)
  end
end

m.inspect = inspect

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

return m
