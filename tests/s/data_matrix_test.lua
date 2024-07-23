local Luna = require("balm/luna")
local m = require("balm/s/data_matrix")

local case = Luna:new("balm.s.DataMatrix")

case:describe("#initialize/3", function (t2)
  t2:test("can initialize a data matrix with dimneions", function (t3)
    local s = m:new(5, 4, 3)

    t3:assert_eq(60, s:volume())
    t3:assert_eq(5, s:width())
    t3:assert_eq(4, s:height())
    t3:assert_eq(3, s:depth())
    t3:assert_table_eq({ x = 5, y = 4, z = 3 }, s:size())
  end)
end)

case:describe("#initialize/4", function (t2)
  t2:test("can initialize a data matrix given a callback function", function (t3)
    local called = false
    local w, h, d = 5, 4, 3
    local volume = w * h * d
    local s = m:new(w, h, d, function (x, y, z, i)
      t3:assert(x >= 0 and x < w)
      t3:assert(y >= 0 and y < h)
      t3:assert(z >= 0 and z < d)
      t3:assert(i >= 0 and i < volume, "expected to be less than volume")
      called = true
      return math.random()
    end)

    t3:assert(called, "expected callback to have been executed")
  end)
end)

case:describe("#get/3,4 & put/4,5", function (t2)
  t2:test("can retrieve data at specified cell", function (t3)
    local s = m:new(5, 4, 3)

    s:put(0, 0, 0, "a")
    s:put(4, 3, 2, "z")

    t3:assert_eq("a", s:get(0, 0, 0))
    t3:assert_eq("z", s:get(4, 3, 2))
  end)

  t2:test("can correctly address every cell", function (t3)
    local s = m:new(5, 4, 3)

    local data = {}
    local i
    for z = 0,2 do
      for y = 0,3 do
        for x = 0,4 do
          i = 1 + z * 4 * 5 + y * 5 + x
          data[i] = math.random()
          s:put(x, y, z, data[i])
        end
      end
    end

    for z = 0,2 do
      for y = 0,3 do
        for x = 0,4 do
          i = 1 + z * 4 * 5 + y * 5 + x
          t3:assert_eq(data[i], s:get(x, y, z))
        end
      end
    end
  end)
end)

case:describe("#put_lazy/5", function (t2)
  t2:test("can put a value returned from the function call", function (t3)
    local s = m:new(5, 4, 3)

    s:put_lazy(0, 0, 0, function () return "a" end)
    s:put_lazy(4, 3, 2, function () return "z" end)

    t3:assert_eq("a", s:get(0, 0, 0))
    t3:assert_eq("z", s:get(4, 3, 2))
  end)
end)

case:describe("#copy/0", function (t2)
  t2:test("can make a copy of the matrix", function (t3)
    local w, h, d = 5, 4, 3
    local s = m:new(w, h, d, function (--[[ x, y, z, i ]])
      return math.random()
    end)

    local other = s:copy()

    t3:assert_eq(s:width(), other:width())
    t3:assert_eq(s:height(), other:height())
    t3:assert_eq(s:depth(), other:depth())
    t3:assert_table_eq(s:data(), other:data())
  end)
end)

case:describe("#sub_matrix/2", function (t2)
  t2:test("can extract a sub matrix from parent", function (t3)
    local w, h, d = 5, 4, 3
    local s = m:new(w, h, d, function (--[[ x, y, z, i ]])
      return math.random()
    end)

    local other = s:sub_matrix({
      x = 0,
      y = 0,
      z = 0,
      w = 3,
      h = 2,
      d = 1,
    })

    t3:assert_eq(other:width(), 3)
    t3:assert_eq(other:height(), 2)
    t3:assert_eq(other:depth(), 1)

    for z = 0,other:depth()-1 do
      for y = 0,other:height()-1 do
        for x = 0,other:width()-1 do
          t3:assert_eq(s:get(x, y, z), other:get(x, y, z))
        end
      end
    end
  end)
end)

case:describe("#map/1", function (t2)
  t2:test("can map over every cell in the matrix", function (t3)
    local w, h, d = 5, 4, 3
    local s = m:new(w, h, d, function (--[[ x, y, z, i ]])
      return math.random()
    end)

    local org = s:copy()

    s:map(function (x, y, z, i, d)
      return d + 1
    end)

    for i = 1,s:volume() do
      t3:assert_eq(org.m_data[i] + 1, s.m_data[i])
    end
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
