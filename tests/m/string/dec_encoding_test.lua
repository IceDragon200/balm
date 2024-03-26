local Luna = require("balm/luna")
local m = require("balm/m/string/dec_encoding")

local case = Luna:new("balm.m.string/dec_encoding")

case:describe("dec_encode", function (t2)
  t2:test("can encode a string has a series of decimal digits", function (t3)
    t3:assert_eq("", m.dec_encode(""))
    t3:assert_eq("000127128255", m.dec_encode("\x00\x7F\x80\xFF"))
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
