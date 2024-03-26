local Luna = require("balm/luna")
local m = require("balm/m/string")

local case = Luna:new("balm.m.string")

case:describe("unescape", function (t2)
  t2:test("hex unescape a string", function (t3)
    t3:assert_eq("", m.unescape(""))
    t3:assert_eq("Hello\000\128\255World", m.unescape("Hello\\x00\\x80\\xFFWorld"))
    t3:assert_eq("\000\016\128\255", m.unescape("\\x00\\x10\\x80\\xFF"))
  end)

  t2:test("dec unescape a string", function (t3)
    t3:assert_eq("", m.unescape(""))
    t3:assert_eq("Hello\000\128\255World", m.unescape("Hello\\000\\128\\255World"))
    t3:assert_eq("\000\010\128\255", m.unescape("\\000\\010\\128\\255"))
  end)
end)

case:describe("starts_with/2", function (t2)
  t2:test("returns true if the given string starts with the prefix", function (t3)
    t3:assert(m.starts_with("Hello, World", "Hello"))
    t3:refute(m.starts_with("Hello, World", "Helloo"))
    t3:refute(m.starts_with("Hello, World", "World"))
  end)
end)

case:describe("ends_with/2", function (t2)
  t2:test("returns true if the given string ends with the postfix", function (t3)
    t3:assert(m.ends_with("Hello, World", "World"))
    t3:refute(m.ends_with("Hello, World", "Worldo"))
    t3:refute(m.ends_with("Hello, World", "Hello"))
  end)
end)

case:describe("trim_leading/2", function (t2)
  t2:test("removes the leading specified string", function (t3)
    t3:assert_eq(", World", m.trim_leading("Hello, World", "Hello"))
    t3:assert_eq("Hello, World", m.trim_leading("Hello, World", "Helloo"))
    t3:assert_eq("Hello, World", m.trim_leading("Hello, World", "Greetings"))
  end)
end)

case:describe("trim_trailing/2", function (t2)
  t2:test("removes the trailing specified string", function (t3)
    t3:assert_eq("Hello, ", m.trim_trailing("Hello, World", "World"))
    t3:assert_eq("Hello, World", m.trim_trailing("Hello, World", "Worldo"))
    t3:assert_eq("Hello, World", m.trim_trailing("Hello, World", "Galaxy"))
  end)
end)

case:describe("split", function (t2)
  t2:test("can split a string", function (t3)
    t3:assert_table_eq({}, m.split(""))
    t3:assert_table_eq({}, m.split("", ""))
    t3:assert_table_eq({}, m.split("", ","))
    -- split by each character, default behaviour
    t3:assert_table_eq({"a", "b", "c", "d", "e"}, m.split("abcde"))
    t3:assert_table_eq({"a", "b", "c", "d", "e"}, m.split("abcde", ""))
    t3:assert_table_eq({"H", "e", "l", "l", "o"}, m.split("Hello"))
    t3:assert_table_eq({"H", "e", "l", "l", "o"}, m.split("Hello", ""))

    -- split by a char
    t3:assert_table_eq({"a", "b", "c", "d", "e"}, m.split("a,b,c,d,e", ","))
    t3:assert_table_eq(
      {"Hello", "dying", "world", "of", "ice"},
      m.split("Hello,dying,world,of,ice", ",")
    )

    -- split by a word
    t3:assert_table_eq(
      {"a", "b", "c", "d", "e"},
      m.split("a_splitter_b_splitter_c_splitter_d_splitter_e", "_splitter_")
    )

    -- split by a char that doesn't exist
    t3:assert_table_eq({"a|b|c|d|e"}, m.split("a|b|c|d|e", "%."))

    -- split by a word that doesn't exist
    t3:assert_table_eq({"a", "b", "c", "d", "e"}, m.split("a..b..c..d..e", "%.%."))
  end)

  t2:test("can split a string line by line", function (t3)
    t3:assert_table_eq({}, m.split("", "\n"))
    t3:assert_table_eq({"ABC"}, m.split("ABC", "\n"))
    t3:assert_table_eq({"A", "B", "C", ""}, m.split("A\nB\nC\n", "\n"))
  end)
end)

case:describe("sub_join", function (t2)
  t2:test("splits a given string by columns and then joins the lines together", function (t3)
    t3:assert_eq("ABC\nDEF\nGH", m.sub_join("ABCDEFGH", 3, "\n"))
  end)
end)

case:describe("rsub", function (t2)
  t2:test("can return a substring of string starting from the end", function (t3)
    t3:assert_eq("", m.rsub("", 1))
    t3:assert_eq("A", m.rsub("A", 1))
    t3:assert_eq("END", m.rsub("THE END", 3))
    t3:assert_eq("D", m.rsub("D", 2))
  end)
end)

case:describe("remove_spaces", function (t2)
  t2:test("removes all spaces, newlines and return characters in string", function (t3)
    t3:assert_eq("ABC", m.remove_spaces(" A  B  C"))
    t3:assert_eq("ABC", m.remove_spaces(" A \n B \r C   \t"))
  end)
end)

case:describe("each_char", function (t2)
  t2:test("can iterate over each character in a string", function (t3)
    local idx = 0
    local result = {}
    m.each_char("ABC", function (char)
      idx = idx + 1
      result[idx] = char
    end)
    t3:assert_table_eq(result, {"A", "B", "C"})
  end)
end)

case:describe("binary_splice", function (t2)
  t2:test("can splice a byte into a string", function (t3)
    t3:assert_eq("\x04\x01\x02", m.binary_splice("\x00\x01\x02", 1, 1, 4))
    t3:assert_eq("\x00\x04\x02", m.binary_splice("\x00\x01\x02", 2, 1, 4))
    t3:assert_eq("\x00\x01\x04", m.binary_splice("\x00\x01\x02", 3, 1, 4))
  end)

  t2:test("can splice a string into another string", function (t3)
    t3:assert_eq("\x04\x01\x02", m.binary_splice("\x00\x01\x02", 1, 1, "\x04"))
    t3:assert_eq("\x00\x04\x02", m.binary_splice("\x00\x01\x02", 2, 1, "\x04"))
    t3:assert_eq("\x00\x01\x04", m.binary_splice("\x00\x01\x02", 3, 1, "\x04"))
  end)

  t2:test("will substring the input value to match the requested byte count", function (t3)
    t3:assert_eq("\x04\x01\x02", m.binary_splice("\x00\x01\x02", 1, 1, "\x04\x02\x03"))
    t3:assert_eq("\x00\x04\x02", m.binary_splice("\x00\x01\x02", 2, 1, "\x04\x02\x03"))
    t3:assert_eq("\x00\x01\x04", m.binary_splice("\x00\x01\x02", 3, 1, "\x04\x02\x03"))
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
