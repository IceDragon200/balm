local Luna = require("balm/luna")
local M = require("balm/u/spring")

local case = Luna:new("balm.u.Spring")

case:describe("#initialize/0", function (t2)
  t2:test("can initialize a new spring object without parameters", function (t3)
    local s = M:new()
  end)
end)

case:describe("#initialize/1", function (t2)
  t2:test("can initialize a new spring object with steering mode", function (t3)
    local s = M:new({
      mode = "steering",
      max_speed = 350,
      max_force = 15,
      current = { x = 0, y = 0 },
      target = { x = 120, y = 80 },
    })
    t3:assert_eq(s.mode, "steering")

    for x = 0,1000 do
      s:update(0.1)
    end

    t3:assert(s:is_close())
  end)

  t2:test("can initialize a new spring object with damping mode", function (t3)
    local s = M:new({
      mode = "damping",
      max_speed = 350,
      stiffness = 4.0,
      damping = 0.95,
      current = { x = 0, y = 0 },
      target = { x = 120, y = 80 },
    })

    t3:assert_eq(s.mode, "damping")
    for x = 0,1000 do
      s:update(0.1)
      if s:is_close() then
        break
      end
    end

    t3:assert(s:is_close())
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
