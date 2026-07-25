--
-- 8 Direction helper
--
local round = require("balm/m/number").round
local table_freeze = require("balm/m/table").freeze
local Vector2 = require("balm/m/vector/2")
local atan2 = assert(math.atan2 or math.atan)

--- @module balm.u.dir8
local Dir8 = {
  DIRECTIONS = {
    [1] = table_freeze(Vector2.new(-1, 1)),
    [2] = table_freeze(Vector2.new(0, 1)),
    [3] = table_freeze(Vector2.new(1, 1)),
    [4] = table_freeze(Vector2.new(-1, 0)),
    [5] = table_freeze(Vector2.new(0, 0)),
    [6] = table_freeze(Vector2.new(1, 0)),
    [7] = table_freeze(Vector2.new(-1, -1)),
    [8] = table_freeze(Vector2.new(0, -1)),
    [9] = table_freeze(Vector2.new(1, -1)),
  },
  DIR4_CW = {
    [8] = 6,
    [6] = 2,
    [2] = 4,
    [4] = 8,
    [5] = 5,
  },

  DIR4_CCW = {
    [8] = 4,
    [4] = 2,
    [2] = 6,
    [6] = 8,
    [5] = 5,
  },

  DIR8_CW = {
    [8] = 9,
    [9] = 6,
    [6] = 3,
    [3] = 2,
    [2] = 1,
    [1] = 4,
    [4] = 7,
    [7] = 8,
    [5] = 5,
  },

  DIR8_CCW = {
    [8] = 7,
    [7] = 4,
    [4] = 1,
    [1] = 2,
    [2] = 3,
    [3] = 6,
    [6] = 9,
    [9] = 8,
    [5] = 5,
  },
}

--- @spec &invert(dir: Number): Number
function Dir8:invert(dir)
  return 10 - dir
end

--- @spec &rotate_cw4(dir: Number): Number
function Dir8:rotate_cw4(dir)
  return self.DIR4_CW[dir]
end

--- @spec &rotate_cw8(dir: Number): Number
function Dir8:rotate_cw8(dir)
  return self.DIR8_CW[dir]
end

--- @spec &rotate_ccw4(dir: Number): Number
function Dir8:rotate_ccw4(dir)
  return self.DIR4_CCW[dir]
end

--- @spec &rotate_ccw8(dir: Number): Number
function Dir8:rotate_ccw8(dir)
  return self.DIR8_CCW[dir]
end

--- @alias rotate_180 = invert
Dir8.rotate_180 = Dir8.invert

--- @spec &get_cardinal_dir(a: Vector2, b: Vector2): Number
function Dir8:get_cardinal_dir(from, to)
  local d = Vector2.sub({ x = 0, y = 0 }, to, from)
  local degs = Vector2.degrees(d)
  --
  --    -90
  -- 180    0
  --    +90
  --
  local q = round(degs / 90.0)
  if q == 0 then
    return 6
  elseif q == 1 then
    return 2
  elseif q == 2 or q == -2 then
    return 4
  elseif q == -1 then
    return 8
  else
    error("Oh snap! " .. q)
  end
end

local CARDINAL_DIR8 = {
  [-8] = 6,
  [-7] = 3,
  [-6] = 2,
  [-5] = 1,
  [-4] = 4,
  [-3] = 7,
  [-2] = 8,
  [-1] = 9,
  [0] = 6,
  [1] = 3,
  [2] = 2,
  [3] = 1,
  [4] = 4,
  [5] = 7,
  [6] = 8,
  [7] = 9,
  [8] = 6,
}

function Dir8:degrees_to_radians(deg)
  return (deg % 360) * math.pi / 180
end

function Dir8:radians_to_degrees(rads)
  return rads * 180 / math.pi
end

--- @since "2026.6.20"
--- @spec &vector2_to_cardinal_dir8(v: Vector2): Number
function Dir8:vector2_to_cardinal_dir8(v)
  if v.x == 0 and v.y == 0 then
    return 5
  end
  local v2 = Vector2.normalize(Vector2.zero(), v)
  local degs = Vector2.degrees(v2) - 22.5
  local q = round((degs % 360) / 45)
  return CARDINAL_DIR8[q]
end

--- @since "2026.6.21"
--- @spec &normal_to_cardinal_dir8(x: Number, y: Number): Number
function Dir8:normal_to_cardinal_dir8(x, y)
  if x == 0 and y == 0 then
    return 5
  end
  local degs = atan2(y, x) * 180 / math.pi - 22.5
  local q = round((degs % 360) / 45)
  return CARDINAL_DIR8[q]
end

--- @spec &project_towards(origin: Vector2, target: Vector2, scale: Vector2 | Number): Vector2
function Dir8:project_towards(origin, target, scale)
  local dir4 = Dir8:get_cardinal_dir(origin, target)

  local offset = self.DIRECTIONS[dir4]
  if scale then
    offset = Vector2.mul({ x = 0, y = 0 }, offset, scale)
  end
  return Vector2.add({ x = 0, y = 0 }, origin, offset)
end

return Dir8
