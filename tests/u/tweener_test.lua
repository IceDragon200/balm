local M = require("balm/u/tweener")
local Easers = require("balm/m/easers")
local Luna = require("balm/luna")

local case = Luna:new("balm.u.Tweener")

case:describe("&new/3+", function (t2)
  t2:test("can initialize given only the dest, duration and target or to values", function (t3)
    local s = M:new({ n = 0, x = 0 }, 4, { x = 4 })

    t3:assert_eq(0.5, s:run(0.5))
    t3:assert_matches(s.dest, { n = 0, x = 0.5 })
    t3:assert_eq(0.5, s:run(0.5))
    t3:assert_matches(s.dest, { n = 0, x = 1 })
    t3:assert_eq(0.5, s:run(0.5))
    t3:assert_matches(s.dest, { n = 0, x = 1.5 })
    t3:assert_eq(0.5, s:run(0.5))
    t3:assert_matches(s.dest, { n = 0, x = 2 })
    t3:assert_eq(2.0, s:run(2.5))
    t3:assert_matches(s.dest, { n = 0, x = 4 })
  end)

  t2:test("can provide an initial table", function (t3)
    local s = M:new({ n = 0, x = 0 }, 4, { x = 2 }, { x = -2 })

    t3:assert_eq(0.5, s:run(0.5))
    t3:assert_matches(s.dest, { n = 0, x = -1.5 })

    s:complete()
    t3:assert_matches(s.dest, { n = 0, x = 2 })
    t3:assert(s:is_done())
  end)

  t2:test("can provide an easers by name", function (t3)
    local s = M:new({ n = 0, x = 0 }, 4, { x = 2 }, { x = -2 }, { x = "quad_in" })

    t3:assert_eq(s.easers.x, Easers.quad_in)

    s:complete()
    t3:assert_matches(s.dest, { n = 0, x = 2 })
    t3:assert(s:is_done())
  end)
end)

case:describe("#clear/0", function (t2)
  t2:test("can clear a tweener", function (t3)
    local s = M:new({ n = 0, x = 0 }, 4, { x = 2 }, { x = -2 })

    s:clear()

    t3:assert_eq(s.dest, nil)
    t3:assert_eq(s.to, nil)
    t3:assert_eq(s.from, nil)
    t3:assert_eq(s.easers, nil)
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
