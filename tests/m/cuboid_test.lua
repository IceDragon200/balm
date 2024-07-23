local Luna = require("balm/luna")
local m = require("balm/m/cuboid")
local vec3 = require("balm/m/vector/3")

local case = Luna:new("balm.m.cuboid")

case:describe("new/0", function (t2)
  t2:test("can return a zeroed rect", function (t3)
    local s = m.new()

    t3:assert_table_eq({ x = 0, y = 0, z = 0, w = 0, h = 0, d = 0 }, s)
  end)
end)

case:describe("new/6", function (t2)
  t2:test("can create rectangle with specified coords", function (t3)
    local s = m.new(2, 4, 6, 22, 30, 42)

    t3:assert_table_eq({ x = 2, y = 4, z = 6, w = 22, h = 30, d = 42 }, s)
  end)
end)

case:describe("new_from_vec3/2", function (t2)
  t2:test("can create cuboid from position and size vectors", function (t3)
    local pos = vec3.random()
    local size = vec3.random()
    local s = m.new_from_vec3(pos, size)

    t3:assert_table_eq({ x = pos.x, y = pos.y, z = pos.z, w = size.x, h = size.y, d = size.z }, s)
  end)
end)

case:describe("new_from_extents/2", function (t2)
  t2:test("can create cuboid from position and size vectors", function (t3)
    local pos = vec3.random()
    local pos2 = vec3.random()
    local s = m.new_from_extents(pos, pos2)

    local x1 = math.min(pos.x, pos2.x)
    local x2 = math.max(pos.x, pos2.x)
    local y1 = math.min(pos.y, pos2.y)
    local y2 = math.max(pos.y, pos2.y)
    local z1 = math.min(pos.z, pos2.z)
    local z2 = math.max(pos.z, pos2.z)

    t3:assert_table_eq({ x = x1, y = y1, z = z1, w = x2 - x1, h = y2 - y1, d = z2 - z1 }, s)
  end)
end)

case:describe("copy/1", function (t2)
  t2:test("can copy a cuboid", function (t3)
    local pos = vec3.random()
    local size = vec3.random()
    local s = m.new_from_vec3(pos, size)

    t3:assert_table_eq(s, m.copy(s))
  end)
end)

case:describe("position/1", function (t2)
  t2:test("returns the position of the cuboid as a vector3", function (t3)
    local pos = vec3.random()
    local size = vec3.random()
    local s = m.new_from_vec3(pos, size)

    t3:assert_table_eq(pos, m.position(s))
  end)
end)

case:describe("size/1", function (t2)
  t2:test("returns the size or dimneions of the cuboid as a vector3", function (t3)
    local pos = vec3.random()
    local size = vec3.random()
    local s = m.new_from_vec3(pos, size)

    t3:assert_table_eq(size, m.size(s))
  end)
end)

case:describe("volume/1", function (t2)
  t2:test("returns the volume of the cuboid", function (t3)
    local pos = vec3.random()
    local size = vec3.random()
    local s = m.new_from_vec3(pos, size)

    t3:assert_eq(size.x * size.y * size.z, m.volume(s))
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
