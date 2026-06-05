local M = require("balm/u/timeline")
local Luna = require("balm/luna")

local case = Luna:new("balm.u.Timeline")

case:describe("general usage", function (t2)
  t2:test("can initialize a new timeline", function (t3)
    local s = M:new()

    local dest = { x = 0 }
    local x = 0

    s
    :new_track(0)
    :new_track(1)
    :set_track_loop(0, true)
    :add_tween(0, dest, 2, { x = 4 }, { x = -4 }, { x = "quad_in" })
    :add_wait(0, 1)
    :add_callback(0, function (track_id, dtime)
      x = x + 1
    end)
    :add_tween(0, dest, 2, { x = 8 }, { x = 4 }, { x = "quad_out" })

    t3:assert_eq(s:is_track_empty(0), false)
    t3:assert_eq(s:is_track_empty(1), true)

    s
    :add_tween(1, { y = 0 }, 10, { y = 18})

    t3:assert_eq(s:is_track_empty(1), false)

    for x = 1,1000 do
      s:update(0.05)
    end

    t3:assert_eq(s:is_track_empty(1), true)
    t3:assert_eq(x, 10)
  end)

  t2:test("can complete a track", function (t3)
    local s = M:new()

    local dest = { x = 0 }

    local x = 0

    s
    :new_track(0)
    :set_track_loop(0, false)
    :add_tween(0, dest, 2, { x = 4 }, { x = -4 }, { x = "quad_in" })
    :add_wait(0, 1)
    :add_callback(0, function (track_id, dtime)
      x = x + 1
    end)
    :add_tween(0, dest, 2, { x = 8 }, { x = 4 }, { x = "quad_out" })

    t3:assert_eq(s:is_track_empty(0), false)

    s:complete_track(0)

    t3:assert_eq(s:is_track_empty(0), true)

    t3:assert_matches(dest, { x = 8 })
    t3:assert_eq(x, 1)
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
