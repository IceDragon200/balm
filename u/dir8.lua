--
-- 8 Direction helper
--
local Vec2 = require("balm/m/vector/2")

local Dir8 = {
  DIRECTIONS = {
    [5] = Vec2.new(0, 0),
    [1] = Vec2.new(-1, 1),
    [2] = Vec2.new(0, 1),
    [3] = Vec2.new(1, 1),
    [4] = Vec2.new(-1, 0),
    [5] = Vec2.new(0, 0),
    [6] = Vec2.new(1, 0),
    [7] = Vec2.new(-1, -1),
    [8] = Vec2.new(0, -1),
    [9] = Vec2.new(1, -1),
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

function Dir8:invert(dir)
  return 10 - dir
end

function Dir8:rotate_cw4(dir)
  return self.DIR4_CW[dir]
end

function Dir8:rotate_cw8(dir)
  return self.DIR8_CW[dir]
end

function Dir8:rotate_ccw4(dir)
  return self.DIR4_CCW[dir]
end

function Dir8:rotate_ccw8(dir)
  return self.DIR8_CCW[dir]
end

function Dir8:rotate_180(dir)
  return 10 - dir
end

function Dir8:determine_facing_dir4(a, b)
  local d = Vec2.sub(b, a)
  local degs = Vec2.degrees(d)
  --
  --    -90
  -- 180    0
  --    +90
  --
  local q = lily.math.round(degs / 90.0)
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

function Dir8:adjacent_from_dir4(target, origin, scale)
  local dir4 = Dir8:determine_facing_dir4(target, origin)

  local a = self.DIRECTIONS[dir4]
  if scale then
    a = Vec2.mul(a, scale)
  end
  return Vec2.add(target, a)
end

return Dir8
