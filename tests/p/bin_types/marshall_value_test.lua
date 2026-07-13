local Luna = require("balm/luna")
local StringBuffer = require("balm/u/string_buffer")
local ByteBuf = require("balm/p/byte_buf")
local Limits = require("balm/limits")
local M = require("balm/p/bin_types/marshall_value")

local BB = ByteBuf.LE

local case = Luna:new("balm.p.bin_types.MarshallValue")

case:describe("#write_integer/3", function (t2)
  t2:test("can write an integer to stream, detecting best length", function (t3)
    local s = StringBuffer:new("", "w")
    local mv = M:new()

    local samples = {
      {Limits.UMIN[8], "b"},
      {Limits.UMAX[8], "B"},
      {Limits.IMIN[8], "b"},
      {Limits.IMAX[8], "b"},

      {Limits.UMIN[16], "b"}, -- cause it's 0
      {Limits.UMAX[16], "S"},
      {Limits.IMIN[16], "s"},
      {Limits.IMAX[16], "s"},

      {Limits.UMIN[32], "b"}, -- cause it's 0
      {Limits.UMAX[32], "I"},
      {Limits.IMIN[32], "i"},
      {Limits.IMAX[32], "i"},

      {Limits.UMIN[48], "b"}, -- cause it's 0
      {Limits.UMAX[48], "T"},
      {Limits.IMIN[48], "t"},
      {Limits.IMAX[48], "t"},
    }

    local bw
    local err
    for _,item in ipairs(samples) do
      bw, err = mv:write(BB, s, item[1])
      -- we have no idea what it did, but it should write something greater than 1
      t3:assert(bw > 1)
      t3:refute(err)
    end
    s:open("r")
    local code
    local v
    local br
    for _,item in ipairs(samples) do
      code = BB:read(s, 1)
      t3:assert_eq(code, item[2])
      if code == "b" then
        v, br = BB:r_i8(s)
        t3:assert_eq(br, 1)
      elseif code == "B" then
        v, br = BB:r_u8(s)
        t3:assert_eq(br, 1)
      elseif code == "s" then
        v, br = BB:r_i16(s)
        t3:assert_eq(br, 2)
      elseif code == "S" then
        v, br = BB:r_u16(s)
        t3:assert_eq(br, 2)
      elseif code == "i" then
        v, br = BB:r_i32(s)
        t3:assert_eq(br, 4)
      elseif code == "I" then
        v, br = BB:r_u32(s)
        t3:assert_eq(br, 4)
      elseif code == "t" then
        v, br = BB:r_i48(s)
        t3:assert_eq(br, 6)
      elseif code == "T" then
        v, br = BB:r_u48(s)
        t3:assert_eq(br, 6)
      else
        error("unexpected code=" .. code)
      end
      t3:assert_eq(item[1], v)
    end
  end)
end)

case:describe("#write/3", function (t2)
  t2:test("can write nils", function (t3)
    local s = StringBuffer:new("", "w")

    local mv = M:new()
    mv:write(BB, s, nil)
    s:open("r")
    t3:assert_eq(mv:read(BB, s), nil)
  end)

  t2:test("can write integers", function (t3)
    local s = StringBuffer:new("", "w")

    local mv = M:new()
    local samples = {
      -- there are all technically 0
      Limits.UMIN[8],
      Limits.UMIN[16],
      Limits.UMIN[32],
      Limits.UMIN[48],
      -- here are some real values now
      Limits.UMAX[8],
      Limits.UMAX[16],
      Limits.UMAX[32],
      Limits.UMAX[48],
      -- unto signed
      Limits.IMIN[8],
      Limits.IMIN[16],
      Limits.IMIN[32],
      Limits.IMIN[48],
      Limits.IMAX[8],
      Limits.IMAX[16],
      Limits.IMAX[32],
      Limits.IMAX[48],
    }

    for i = 1,256 do
      table.insert(samples, math.random(Limits.IMIN[48], Limits.IMAX[48]))
    end

    local bw
    local err
    for _,item in ipairs(samples) do
      bw, err = mv:write(BB, s, item)
      -- we have no idea what it did, but it should write something greater than 1
      t3:assert(bw > 1)
      t3:refute(err)
    end
    s:open("r")
    for _,item in ipairs(samples) do
      t3:assert_eq(item, mv:read(BB, s))
    end
  end)

  t2:test("can write strings", function (t3)
    local s = StringBuffer:new("", "w")

    local mv = M:new()
    local samples = {
      "",
      "\0",
      "Hello, World",
    }

    local bw
    local err
    for _,item in ipairs(samples) do
      bw, err = mv:write(BB, s, item)
      -- we have no idea what it did, but it should write something greater than 1
      t3:assert(bw > 1)
      t3:refute(err)
    end
    s:open("r")
    for _,item in ipairs(samples) do
      t3:assert_eq(item, mv:read(BB, s))
    end
  end)

  t2:test("can write tables", function (t3)
    local s = StringBuffer:new("", "w")

    local mv = M:new()
    local samples = {
      {},
      { 1, 2, 3, 4, 5 },
      { x = "A", y = { 1, 2, 3 }, z = false },
    }

    local bw
    local err
    for _,item in ipairs(samples) do
      bw, err = mv:write(BB, s, item)
      -- we have no idea what it did, but it should write something greater than 1
      t3:assert(bw > 1)
      t3:refute(err)
    end
    s:open("r")
    for _,item in ipairs(samples) do
      t3:assert_deep_eq(item, mv:read(BB, s))
    end
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
