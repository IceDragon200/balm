local Luna = require("balm/luna")
local m = require("balm/u/u128")

local case = Luna:new("balm.u.U128")

case:describe("&random/0", function (t2)
  t2:test("can generate a random u128", function (t3)
    local i = m:random()

    t3:assert(i.a >= 0 and i.a < 0x100000000)
    t3:assert(i.b >= 0 and i.b < 0x100000000)
    t3:assert(i.c >= 0 and i.c < 0x100000000)
    t3:assert(i.d >= 0 and i.d < 0x100000000)
  end)
end)

case:describe("#initialize/0", function (t2)
  t2:test("can initialize a new instance", function (t3)
    local _i = m:new()
  end)
end)

case:describe("#to_be128_barray/0", function (t2)
  t2:test("can convert to a big-endian byte array", function (t3)
    local i = m:random()
    local a = i:to_be128_barray()
    t3:assert_eq(#a, 16)
  end)
end)

case:describe("#to_le128_barray/0", function (t2)
  t2:test("can convert to a little-endian byte array", function (t3)
    local i = m:random()
    local a = i:to_le128_barray()
    t3:assert_eq(#a, 16)
  end)
end)

case:describe("math", function (t2)
  t2:test("can mulitple with a native scalar (pow2 test)", function (t3)
    local i = m:new{ a = 1, b = 1, c = 1, d = 1 }
    t3:assert_matches(i:mul(1), { a = 1, b = 1, c = 1, d = 1 }) -- identity
    for x = 1,31 do
      local y = 2 ^ x
      t3:assert_matches(i:mul(2), { a = y, b = y, c = y, d = y }) -- 2^i
    end
  end)

  t2:test("can mulitple with a native scalar (shift test)", function (t3)
    local i = m:new{ a = 1, b = 0, c = 0, d = 0 }
    local y = 2 ^ 32
    t3:assert_matches(i,        { a = 1, b = 0, c = 0, d = 0 })
    t3:assert_matches(i:mul(y), { a = 0, b = 1, c = 0, d = 0 })
    t3:assert_matches(i:mul(y), { a = 0, b = 0, c = 1, d = 0 })
    t3:assert_matches(i:mul(y), { a = 0, b = 0, c = 0, d = 1 })
  end)

  t2:test("can do some math on the number", function (t3)
    local i = m:new()
    t3:assert_matches(i:add(1),           { a = 1, b = 0, c = 0, d = 0 })
    t3:assert_matches(i:sub(1),           { a = 0, b = 0, c = 0, d = 0 })
    t3:assert_matches(i:mul(0),           { a = 0, b = 0, c = 0, d = 0 })
    t3:assert_matches(i:mul(1),           { a = 0, b = 0, c = 0, d = 0 })
    t3:assert_matches(i:add(0x100000000), { a = 0, b = 1, c = 0, d = 0 })
    t3:assert_matches(i:mul(0x100000000), { a = 0, b = 0, c = 1, d = 0 })
    t3:assert_matches(i:mul(0x100000000), { a = 0, b = 0, c = 0, d = 1 })
    t3:assert_matches(i:sub(1),           { a = 0xFFFFFFFF, b = 0xFFFFFFFF, c = 0xFFFFFFFF, d = 0 })
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
