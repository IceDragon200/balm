--- @namespace balm.m.path
local m = {}

--- @namespace m
local String = require("balm/m/string")

m.DIR_DELIM = rawget(_G, "DIR_DELIM") or "/"

--- @since 2025.3.26
--- @spec components(a: String): String[]
function m.components(a)
  if a == "" then
    return {}
  else
    local parts = String.split(a, m.DIR_DELIM)
    local result = {}
    local i = 0
    local was_blank = false
    for j,part in pairs(parts) do
      if part == "" then
        if not was_blank then
          was_blank = true
          i = i + 1
          result[i] = part
        end
      else
        was_blank = false
        i = i + 1
        result[i] = part
      end
    end

    return result
  end
end

--- @since 2025.3.26
--- @spec dirname(a: String): String
function m.dirname(a)
  local components = m.components(a)

  if components[2] then
    -- it has 2 or more components
    components[#components] = nil
    if components[2] then
      return table.concat(components, m.DIR_DELIM)
    else
      if components[1] == "" then
        return "/"
      else
        return components[1]
      end
    end
  else
    -- has an initial component
    if components[1] then
      return "/" .. components[1]
    else
      return "."
    end
  end
end

--- @since 2025.3.26
--- @spec basename(a: String): String
function m.basename(a)
  local components = m.path_components(a)
  if components[1] then
    local item = components[#components]
    if item == "" then
      return ""
    end
    return item
  end
  return ""
end

--- @since 2025.3.26
--- @spec join(...: String[]): String
function m.join(...)
  local segments = {...}
  for i,segment in ipairs(segments) do
    if i > 1 then
      segment = String.trim_leading(segment, m.DIR_DELIM)
    end
    segments[i] = String.trim_trailing(segment, m.DIR_DELIM)
  end

  return table.concat(segments, m.DIR_DELIM)
end

--- @since 2025.3.26
--- @spec extname(path: String): String
function m.extname(path)
  local s, e = string.find(path, "%.[%w_%-]+$")
  if s then
    return string.sub(path, s, e)
  else
    return ""
  end
end

return m
