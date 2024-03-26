local Luna = require("balm/luna")
local m = require("balm/m/string/bin_encoding")

local case = Luna:new("balm.m.string/bin_encoding")

case:describe("bin_encode", function (t2)
  t2:test("can encode a string has a series of binary digits", function (t3)
    t3:assert_eq("00000000" ..
                 "01111111" ..
                 "10000000" ..
                 "11111111", m.bin_encode("\x00\x7F\x80\xFF"))

    t3:assert_eq("00000001" ..
                 "00000010" ..
                 "00000100" ..
                 "00001000" ..
                 "00010000" ..
                 "00100000" ..
                 "01000000" ..
                 "10000000", m.bin_encode("\x01\x02\x04\x08\x10\x20\x40\x80"))
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
