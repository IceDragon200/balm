local Luna = require("balm/luna")
local BIT_TABLE = assert(require("balm/u/bit").BIT_TABLE)
local M = require("balm/m/pack")

local case = Luna:new("balm.m.pack")

for bits = 4,52 do
  if bits % 2 == 0 then
    local hb = math.floor(bits / 2)

    case:describe("v2 (bits=" .. bits .. ")", function (t2)
      t2:test("can pack two integers into a single integer by bit length", function (t3)
        local mn = -BIT_TABLE[hb - 1]
        local mx = BIT_TABLE[hb - 1] - 1
        for z = 1,1000 do
          local a = math.random(mn, mx)
          local b = math.random(mn, mx)

          local w = M.pack_v2(bits, a, b)
          local a2, b2 = M.unpack_v2(bits, w)

          t3:assert_eq(a2, a)
          t3:assert_eq(b2, b)
        end
      end)
    end)
  end

  if bits % 3 == 0 then
    local tb = math.floor(bits / 3)

    case:describe("v3 (bits=" .. bits .. ")", function (t2)
      t2:test("can pack four integers into a single integer by bit length", function (t3)
        local mn = -BIT_TABLE[tb - 1]
        local mx = BIT_TABLE[tb - 1] - 1
        for z = 1,1000 do
          local a = math.random(mn, mx)
          local b = math.random(mn, mx)
          local c = math.random(mn, mx)

          local w = M.pack_v3(bits, a, b, c)
          local a2, b2, c2 = M.unpack_v3(bits, w)

          t3:assert_eq(a2, a)
          t3:assert_eq(b2, b)
          t3:assert_eq(c2, c)
        end
      end)
    end)
  end

  if bits % 4 == 0 then
    local qb = math.floor(bits / 4)

    case:describe("v4 (bits=" .. bits .. ")", function (t2)
      t2:test("can pack four integers into a single integer by bit length", function (t3)
        local mn = -BIT_TABLE[qb - 1]
        local mx = BIT_TABLE[qb - 1] - 1
        for z = 1,1000 do
          local a = math.random(mn, mx)
          local b = math.random(mn, mx)
          local c = math.random(mn, mx)
          local d = math.random(mn, mx)

          local w = M.pack_v4(bits, a, b, c, d)
          local a2, b2, c2, d2 = M.unpack_v4(bits, w)

          t3:assert_eq(a2, a)
          t3:assert_eq(b2, b)
          t3:assert_eq(c2, c)
          t3:assert_eq(d2, d)
        end
      end)
    end)
  end
end

case:execute()
case:display_stats()
case:maybe_error()
