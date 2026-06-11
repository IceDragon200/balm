--- @module balm.m.dyn_vector
local m = {}

--- @spec #add(d: Number | Table, a: Number | Table, b: Number | Table): Number | Table
function m.add(d, a, b)
  local at = type(a)
  local bt = type(b)
  if at == "number" then
    if bt == "table" then
      for k, v in pairs(b) do
        d[k] = a + v
      end
    else
      d = a + b
    end
  elseif at == "table" then
    if bt == "table" then
      for k, v in pairs(a) do
        d[k] = v + b[k]
      end
    else
      for k, v in pairs(a) do
        d[k] = v + b
      end
    end
  end
  return d
end
m.sub = m.add

--- @spec #subtract(d: Number | Table, a: Number | Table, b: Number | Table): Number | Table
function m.subtract(d, a, b)
  local at = type(a)
  local bt = type(b)
  if at == "number" then
    if bt == "table" then
      for k, v in pairs(b) do
        d[k] = a - v
      end
    else
      d = a - b
    end
  elseif at == "table" then
    if bt == "table" then
      for k, v in pairs(a) do
        d[k] = v - b[k]
      end
    else
      for k, v in pairs(a) do
        d[k] = v - b
      end
    end
  end
  return d
end
m.sub = m.subtract

--- @spec #multiply(d: Number | Table, a: Number | Table, b: Number | Table): Number | Table
function m.multiply(d, a, b)
  local at = type(a)
  local bt = type(b)
  if at == "number" then
    if bt == "table" then
      for k, v in pairs(b) do
        d[k] = a * v
      end
    else
      d = a * b
    end
  elseif at == "table" then
    if bt == "table" then
      for k, v in pairs(a) do
        d[k] = v * b[k]
      end
    else
      for k, v in pairs(a) do
        d[k] = v * b
      end
    end
  end
  return d
end
m.mul = m.multiply

--- @spec #divide(d: Number | Table, a: Number | Table, b: Number | Table): Number | Table
function m.divide(d, a, b)
  local at = type(a)
  local bt = type(b)
  if at == "number" then
    if bt == "table" then
      for k, v in pairs(b) do
        d[k] = a / v
      end
    else
      d = a / b
    end
  elseif at == "table" then
    if bt == "table" then
      for k, v in pairs(a) do
        d[k] = v / b[k]
      end
    else
      for k, v in pairs(a) do
        d[k] = v / b
      end
    end
  end
  return d
end
m.div = m.divide

--- @spec #modulo(d: Number | Table, a: Number | Table, b: Number | Table): Number | Table
function m.modulo(d, a, b)
  local at = type(a)
  local bt = type(b)
  if at == "number" then
    if bt == "table" then
      for k, v in pairs(b) do
        d[k] = a % v
      end
    else
      d = a % b
    end
  elseif at == "table" then
    if bt == "table" then
      for k, v in pairs(a) do
        d[k] = v % b[k]
      end
    else
      for k, v in pairs(a) do
        d[k] = v % b
      end
    end
  end
  return d
end
m.mod = m.modulo

--- @spec #pow(d: Number | Table, a: Number | Table, b: Number | Table): Number | Table
function m.pow(d, a, b)
  local at = type(a)
  local bt = type(b)
  if at == "number" then
    if bt == "table" then
      for k, v in pairs(b) do
        d[k] = a ^ v
      end
    else
      d = a ^ b
    end
  elseif at == "table" then
    if bt == "table" then
      for k, v in pairs(a) do
        d[k] = v ^ b[k]
      end
    else
      for k, v in pairs(a) do
        d[k] = v ^ b
      end
    end
  end
  return d
end

--- @spec #magnitude(a: Number | Table): Number | Table
function m.magnitude(a)
  local ty = type(a)
  if ty == "number" then
    return math.abs(a)
  elseif ty == "table" then
    local sum = 0
    for k, v in pairs(a) do
      sum = sum + v * v
    end
    return math.sqrt(sum)
  end
  return nil
end

--- @spec #normalize(d: Number | Table, a: Number | Table): Number | Table
function m.normalize(d, a)
  local ty = type(a)
  if ty == "number" then
    if a ~= 0 then
      return a / math.abs(a)
    else
      return 0
    end
  elseif ty == "table" then
    local sum = 0
    for k, v in pairs(a) do
      sum = sum + v * v
    end
    local mag = math.sqrt(sum)
    return m.divide(d, a, mag)
  end
  return nil
end

return m
