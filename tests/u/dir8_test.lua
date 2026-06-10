local Luna = require("balm/luna")
local Vector2 = require("balm/m/vector/2")
local M = require("balm/u/dir8")

local case = Luna:new("balm.u.dir8")

case:describe("&project_towards/2", function (t2)
  t2:test("can project from an origin point to a target point", function (t3)
    local n = 100
    local origin = Vector2.new(math.random(-n, n), math.random(-n, n))
    local target = Vector2.new(math.random(-n, n), math.random(-n, n))

    local dist = Vector2.distance(origin, target)
    local projected = M:project_towards(origin, target, dist * 0.5)

    t3:assert_feq(Vector2.distance(origin, projected), dist * 0.5)
    t3:assert(Vector2.distance(projected, target) < dist)
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
