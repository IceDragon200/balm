local Luna = require("balm/luna")
local m = require("balm/s/vector")

local case = Luna:new("balm.s.Vector")

case:describe("#initialize/1", function (t2)
  t2:test("can initialize a new vector", function (t3)
    local v = m:new()
    t3:assert_eq(v:size(), 0)
    t3:assert_eq(v:is_empty(), true)
  end)
end)

case:describe("copying", function (t2)
  t2:test("can copy a vector", function (t3)
    local v = m:new{ size = 10 }
    v:random(10, -10)

    local v2 = v:copy()
    local v3 = m:new{ size = 10 }

    t3:refute_raw_eq(v, v2)
    t3:assert_eq(v, v2)
    t3:refute_eq(v, v3)
    t3:refute_eq(v2, v3)
  end)
end)

case:describe("accessors", function (t2)
  t2:test("can get and put values in vector", function (t3)
    local v = m:new{ size = 10 }

    for i = 1,v.m_size do
      local x = math.random()
      v:put(i, x)
      t3:assert_eq(v:get(i), x)
    end
  end)

  t2:test("will handle out of bounds quietly", function (t3)
    local v = m:new{ size = 10 }

    --- should return the default
    t3:assert_eq(v:get(-1), 0)
    v:put(11, 20)
    --- should just return the default
    t3:assert_eq(v:get(11), 0)
  end)
end)

case:describe("#resize/1", function (t2)
  t2:test("can resize a vector", function (t3)
    local v = m:new{ size = 10, default = -1 }
    v:random(10, 1)
    for i = 1,v.m_size do
      t3:assert(v:get(i) > 0)
      t3:assert(v:get(i) <= 10)
    end
    v:resize(20)
    t3:assert_eq(v:size(), 20)
    t3:assert_eq(v:get(11), -1)
    v:put(11, 20)
    t3:assert_eq(v:get(11), 20)
    v:resize(5)
    t3:assert_eq(v:size(), 5)
    t3:assert_eq(v:get(11), -1)
    t3:assert_eq(v:get(6), -1)
    v:put(5, 20)
    t3:assert_eq(v:get(5), 20)
  end)
end)

case:describe("#add/2", function (t2)
  t2:test("can add two vectors", function (t3)
    local v = m:new{ size = 10 }
    v:random(10, -10)
    local v2 = m:new{ size = 10 }
    v2:random(10, -10)

    local dest = m:new{ size = 10 }
    dest:add(v, v2)

    t3:assert_eq(dest.m_size, 10)
    for i = 1,dest.m_size do
      t3:assert_eq(dest.m_data[i], v.m_data[i] + v2.m_data[i])
    end
  end)
end)

case:describe("#subtract/2", function (t2)
  t2:test("can subtract two vectors", function (t3)
    local v = m:new{ size = 10 }
    v:random(10, -10)
    local v2 = m:new{ size = 10 }
    v2:random(10, -10)

    local dest = m:new{ size = 10 }
    dest:subtract(v, v2)

    t3:assert_eq(dest.m_size, 10)
    for i = 1,dest.m_size do
      t3:assert_eq(dest.m_data[i], v.m_data[i] - v2.m_data[i])
    end
  end)
end)

case:describe("#multiply/2", function (t2)
  t2:test("can multiply two vectors", function (t3)
    local v = m:new{ size = 10 }
    v:random(10, -10)
    local v2 = m:new{ size = 10 }
    v2:random(10, -10)

    local dest = m:new{ size = 10 }
    dest:multiply(v, v2)

    t3:assert_eq(dest.m_size, 10)
    for i = 1,dest.m_size do
      t3:assert_eq(dest.m_data[i], v.m_data[i] * v2.m_data[i])
    end
  end)
end)

case:describe("#divide/2", function (t2)
  t2:test("can divide two vectors", function (t3)
    local v = m:new{ size = 10 }
    v:random(10, 1)
    local v2 = m:new{ size = 10 }
    v2:random(10, 1)

    local dest = m:new{ size = 10 }
    dest:divide(v, v2)

    t3:assert_eq(dest.m_size, 10)
    for i = 1,dest.m_size do
      t3:assert_eq(dest.m_data[i], v.m_data[i] / v2.m_data[i])
    end
  end)
end)

case:describe("#modulo/2", function (t2)
  t2:test("can divide two vectors", function (t3)
    local v = m:new{ size = 10 }
    v:random(10, 1)
    local v2 = m:new{ size = 10 }
    v2:random(10, 1)

    local dest = m:new{ size = 10 }
    dest:modulo(v, v2)

    t3:assert_eq(dest.m_size, 10)
    for i = 1,dest.m_size do
      t3:assert_eq(dest.m_data[i], v.m_data[i] % v2.m_data[i])
    end
  end)
end)

case:describe("#exponent/2", function (t2)
  t2:test("can divide two vectors", function (t3)
    local v = m:new{ size = 10 }
    v:random(10, 1)
    local v2 = m:new{ size = 10 }
    v2:random(10, 1)

    local dest = m:new{ size = 10 }
    dest:exponent(v, v2)

    t3:assert_eq(dest.m_size, 10)
    for i = 1,dest.m_size do
      t3:assert_eq(dest.m_data[i], v.m_data[i] ^ v2.m_data[i])
    end
  end)
end)

case:describe("#apply/3", function (t2)
  t2:test("can apply a function to two vectors", function (t3)
    local v = m:new{ size = 10 }
    v:random(10, -10)
    local v2 = m:new{ size = 10 }
    v2:random(10, -10)

    local dest = m:new{ size = 10 }
    dest:apply(v, v2, function (a, b)
      return a * a + b * b
    end)

    t3:assert_eq(dest.m_size, 10)
    for i = 1,dest.m_size do
      local a = v.m_data[i]
      local b = v2.m_data[i]
      t3:assert_eq(dest.m_data[i], a * a + b * b)
    end
  end)
end)

case:describe("#+/1", function (t2)
  t2:test("can add two vectors into a new vector", function (t3)
    local v = m:new{ size = 10 }
    v:random(10, -10)
    local v2 = m:new{ size = 10 }
    v2:random(10, -10)

    local dest = v + v2
    t3:assert_eq(dest.m_size, 10)
    for i = 1,dest.m_size do
      t3:assert_eq(dest.m_data[i], v.m_data[i] + v2.m_data[i])
    end
  end)
end)

case:describe("#-/1", function (t2)
  t2:test("can subtract two vectors into a new vector", function (t3)
    local v = m:new{ size = 10 }
    v:random(10, -10)
    local v2 = m:new{ size = 10 }
    v2:random(10, -10)

    local dest = v - v2
    t3:assert_eq(dest.m_size, 10)
    for i = 1,dest.m_size do
      t3:assert_eq(dest.m_data[i], v.m_data[i] - v2.m_data[i])
    end
  end)
end)

case:describe("#*/1", function (t2)
  t2:test("can multiply two vectors into a new vector", function (t3)
    local v = m:new{ size = 10 }
    v:random(10, -10)
    local v2 = m:new{ size = 10 }
    v2:random(10, -10)

    local dest = v * v2
    t3:assert_eq(dest.m_size, 10)
    for i = 1,dest.m_size do
      t3:assert_eq(dest.m_data[i], v.m_data[i] * v2.m_data[i])
    end
  end)
end)

case:describe("#'/'/1", function (t2)
  t2:test("can divide two vectors into a new vector", function (t3)
    local v = m:new{ size = 10 }
    v:random(10, 1)
    local v2 = m:new{ size = 10 }
    v2:random(10, 1)

    local dest = v / v2
    t3:assert_eq(dest.m_size, 10)
    for i = 1,dest.m_size do
      t3:assert_eq(dest.m_data[i], v.m_data[i] / v2.m_data[i])
    end
  end)
end)

case:describe("#'%'/1", function (t2)
  t2:test("can modulo two vectors into a new vector", function (t3)
    local v = m:new{ size = 10 }
    v:random(10, 1)
    local v2 = m:new{ size = 10 }
    v2:random(10, 1)

    local dest = v % v2
    t3:assert_eq(dest.m_size, 10)
    for i = 1,dest.m_size do
      t3:assert_eq(dest.m_data[i], v.m_data[i] % v2.m_data[i])
    end
  end)
end)

case:describe("#'^'/1", function (t2)
  t2:test("can divide two vectors into a new vector", function (t3)
    local v = m:new{ size = 10 }
    v:random(10, 1)
    local v2 = m:new{ size = 10 }
    v2:random(10, 1)

    local dest = v ^ v2
    t3:assert_eq(dest.m_size, 10)
    for i = 1,dest.m_size do
      t3:assert_eq(dest.m_data[i], v.m_data[i] ^ v2.m_data[i])
    end
  end)
end)

case:describe("#-@/1", function (t2)
  t2:test("can negate a vector into a new vector", function (t3)
    local v = m:new{ size = 10 }
    v:random(10, -10)

    local dest = -v
    t3:assert_eq(dest.m_size, 10)
    for i = 1,dest.m_size do
      t3:assert_eq(dest.m_data[i], -v.m_data[i])
    end
  end)
end)

case:describe("#floor/1", function (t2)
  t2:test("can floor the values of the vector", function (t3)
    local v = m:new{ size = 10 }
    v:randomf(10, -10)

    local dest = v:copy():floor(v)
    t3:assert_eq(dest.m_size, 10)
    for i = 1,dest.m_size do
      t3:assert_eq(dest.m_data[i], math.floor(v.m_data[i]))
    end
  end)
end)

case:describe("#ceil/1", function (t2)
  t2:test("can ceil the values of the vector", function (t3)
    local v = m:new{ size = 10 }
    v:randomf(10, -10)

    local dest = v:copy():ceil(v)
    t3:assert_eq(dest.m_size, 10)
    for i = 1,dest.m_size do
      t3:assert_eq(dest.m_data[i], math.ceil(v.m_data[i]))
    end
  end)
end)

case:describe("#abs/1", function (t2)
  t2:test("can abs the values of the vector", function (t3)
    local v = m:new{ size = 10 }
    v:randomf(10, -10)

    local dest = v:copy():abs(v)
    t3:assert_eq(dest.m_size, 10)
    for i = 1,dest.m_size do
      t3:assert_eq(dest.m_data[i], math.abs(v.m_data[i]))
    end
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
