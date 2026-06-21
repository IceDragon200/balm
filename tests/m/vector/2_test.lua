local Luna = require("balm/luna")
local M = require("balm/m/vector/2")

local case = Luna:new("balm.m.vector2")

case:describe(".new/2", function (t2)
  t2:test("can create a new vector", function (t3)
    local a = M.new(3, 6)

    t3:assert_table_eq({
      x = 3,
      y = 6,
    }, a)
  end)
end)

case:describe(".copy/1", function (t2)
  t2:test("can copy an existing vector", function (t3)
    local a = M.new(3, 6)
    local b = M.copy(a)

    t3:assert_table_eq({
      x = 3,
      y = 6,
    }, b)
  end)
end)

case:describe("#copy/0", function (t2)
  t2:test("can copy the current vector instance", function (t3)
    local a = M.new(3, 6)
    local b = a:copy()

    t3:assert_table_eq({
      x = 3,
      y = 6,
    }, b)
  end)
end)

case:describe(".zero/0", function (t2)
  t2:test("can create a zeroed vector", function (t3)
    local a = M.zero()

    t3:assert_table_eq({
      x = 0,
      y = 0,
    }, a)
  end)
end)

case:describe(".equals", function (t2)
  t2:test("can compare two vectors", function (t3)
    local a = M.new(3, 6)
    local b = M.new(2, 4)
    local c = M.new(a.x, a.y)

    t3:refute(M.equals(a, b))
    t3:assert(M.equals(a, c))
  end)
end)

case:describe(".round/2", function (t2)
  t2:test("can round a vector to nearest integral", function (t3)
    local a = M.new(12.8222, 13.5)
    local b = M.round({}, a)

    t3:assert_table_eq({
      x = 13,
      y = 14,
    }, b)
  end)
end)

case:describe(".round/3", function (t2)
  t2:test("can round a vector to specified decimal places", function (t3)
    local a = M.new(12.8222, 13.5)
    local b = M.round({}, a, 2)

    t3:assert_table_eq({
      x = 12.82,
      y = 13.5,
    }, b)
  end)
end)

case:describe(".slerp/4", function (t2)
  t2:test("slerp two vectors", function (t3)
    local a = M.new(0, 1)
    local b = M.new(1, 0)

    local c = {}
    c = M.slerp(c, a, b, 0)
    t3:assert_table_eq({
      x = 0,
      y = 1,
    }, c)

    c = M.slerp(c, a, b, 0.5)
    t3:assert_table_eq({
      x = 0.7,
      y = 0.7,
    }, M.round(c, c, 2))

    c = M.slerp(c, a, b, 1)
    t3:assert_table_eq({
      x = 1.0,
      y = 0.0,
    }, M.round(c, c, 2))
  end)
end)

case:describe("degrees/1", function (t2)
  t2:test("calculate degrees given a vector", function (t3)
    t3:assert_eq(M.degrees(M.new(1, 0)), 0)
    t3:assert_eq(M.degrees(M.new(0, 1)), 90)
    t3:assert_eq(M.degrees(M.new(-1, 0)), 180)
    t3:assert_eq(M.degrees(M.new(0, -1)), -90)
  end)
end)

case:describe("from_degrees/1", function (t2)
  t2:test("can return a vector2 from given degrees", function (t3)
    t3:assert_vector(M.from_degrees(0), { x = 1.0, y = 0.0 })
    t3:assert_vector(M.from_degrees(90), { x = 0.0, y = 1.0 })
    t3:assert_vector(M.from_degrees(180), { x = -1.0, y = 0.0 })
    t3:assert_vector(M.from_degrees(270), { x = 0.0, y = -1.0 })
    t3:assert_vector(M.from_degrees(360), { x = 1.0, y = 0.0 })
    t3:assert_vector(M.from_degrees(-90), { x = 0.0, y = -1.0 })
    t3:assert_vector(M.from_degrees(-180), { x = -1.0, y = 0.0 })
    t3:assert_vector(M.from_degrees(-270), { x = 0.0, y = 1.0 })
    t3:assert_vector(M.from_degrees(-360), { x = 1.0, y = 0.0 })
  end)
end)

case:describe("degrees to and from", function (t2)
  t2:test("can handle full 360", function (t3)
    local v
    for d = -360,360 do
      v = M.from_degrees(d)
      t3:assert_feq(M.degrees(v) % 360, d % 360)
    end
  end)
end)

case:describe("hash", function (t2)
  for x = 4,50 do
    if x % 2 == 0 then
      local s = 2 ^ (math.floor(x / 2) - 1)
      local mx = s - 1
      local mn = -s

      t2:test("can convert a vector2 into a ".. x .." bit hash", function (t3)
        t3:assert_table_eq({ x = mn, y = mn }, M.from_hash({}, x, M.to_hash(M.new(mn, mn), x)))
        t3:assert_table_eq({ x = mn, y = 0  }, M.from_hash({}, x, M.to_hash(M.new(mn, 0), x)))
        t3:assert_table_eq({ x = mn, y = mx }, M.from_hash({}, x, M.to_hash(M.new(mn, mx), x)))
        t3:assert_table_eq({ x = 0, y = mn  }, M.from_hash({}, x, M.to_hash(M.new(0, mn), x)))
        t3:assert_table_eq({ x = 0, y = 0   }, M.from_hash({}, x, M.to_hash(M.new(0, 0), x)))
        t3:assert_table_eq({ x = 0, y = mx  }, M.from_hash({}, x, M.to_hash(M.new(0, mx), x)))
        t3:assert_table_eq({ x = mx, y = mn }, M.from_hash({}, x, M.to_hash(M.new(mx, mn), x)))
        t3:assert_table_eq({ x = mx, y = 0  }, M.from_hash({}, x, M.to_hash(M.new(mx, 0), x)))
        t3:assert_table_eq({ x = mx, y = mx }, M.from_hash({}, x, M.to_hash(M.new(mx, mx), x)))
      end)
    end
  end
end)

case:describe("#-~", function (t2)
  t2:test("can negate a vector", function (t3)
    local a = M.new(2, -4)

    t3:assert_table_eq({
      x = -2,
      y = 4,
    }, -a)
  end)
end)

case:describe("#==", function (t2)
  t2:test("can compare two vectors", function (t3)
    local a = M.new(3, 6)
    local b = M.new(2, 4)
    local c = M.new(a.x, a.y)

    t3:refute(a == b)
    t3:assert(a == c)
  end)
end)

case:describe("#+", function (t2)
  t2:test("can add 2 vectors together", function (t3)
    local a = M.new(3, 6)
    local b = M.new(2, 4)

    local c = a + b

    t3:assert_table_eq({
      x = 5,
      y = 10,
    }, c)
  end)
end)

case:describe("#-", function (t2)
  t2:test("can subtract 2 vectors", function (t3)
    local a = M.new(3, 6)
    local b = M.new(2, 4)

    local c = a - b

    t3:assert_table_eq({
      x = 1,
      y = 2,
    }, c)
  end)
end)

case:describe("#*", function (t2)
  t2:test("can multiply 2 vectors", function (t3)
    local a = M.new(3, 6)
    local b = M.new(2, 4)

    local c = a * b

    t3:assert_table_eq({
      x = 6,
      y = 24,
    }, c)
  end)
end)

case:describe("#/", function (t2)
  t2:test("can divide 2 vectors", function (t3)
    local a = M.new(6, 12)
    local b = M.new(3, 4)

    local c = a / b

    t3:assert_table_eq({
      x = a.x / b.x,
      y = a.y / b.y,
    }, c)
  end)
end)

case:describe("#%", function (t2)
  t2:test("can divide 2 vectors", function (t3)
    local a = M.new(6, 12)
    local b = M.new(4, 5)

    local c = a % b

    t3:assert_table_eq({
      x = a.x % b.x,
      y = a.y % b.y,
    }, c)
  end)
end)

case:describe("#^", function (t2)
  t2:test("can divide 2 vectors", function (t3)
    local a = M.new(6, 12)
    local b = M.new(3, 4)

    local c = a ^ b

    t3:assert_table_eq({
      x = a.x ^ b.x,
      y = a.y ^ b.y,
    }, c)
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
