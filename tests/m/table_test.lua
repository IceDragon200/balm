local Luna = require("balm/luna")
local m = require("balm/m/table")

local case = Luna:new("balm.m.table")

case:describe("concat/1+", function (t2)
  t2:test("can concatenate several array-like tables together", function (t3)
    local tab1 = {1, 2, 3}
    local tab2 = {"a", "b", "c"}

    t3:assert_table_eq({1, 2, 3, "a", "b", "c"}, m.concat(tab1, tab2))
  end)
end)

case:describe("take/2", function (t2)
  t2:test("can pick out pairs from a table by keys", function (t3)
    local tab1 = {
      name = "John Doe",
      age = 1000,
      address = "Somewhere",
      state = "FL",
    }

    t3:assert_table_eq(
      {
        name = "John Doe",
        age = 1000,
      },
      m.take(tab1, { "name", "age" })
    )
  end)
end)

case:describe("drop/2", function (t2)
  t2:test("can drop a list of keys from a table", function (t3)
    local tab1 = {
      name = "John Doe",
      age = 1000,
      address = "Somewhere",
      state = "FL",
    }

    t3:assert_table_eq(
      {
        name = "John Doe",
        age = 1000,
      },
      m.drop(tab1, { "address", "state" })
    )
  end)
end)

case:describe("key_of/2", function (t2)
  t2:test("can lookup a key given only the value", function (t3)
    local tab1 = {
      name = "John Doe",
      age = 1000,
      address = "Somewhere",
      state = "FL",
    }

    t3:assert_table_eq(
      {
        name = "John Doe",
        age = 1000,
      },
      m.drop(tab1, { "address", "state" })
    )
  end)
end)

case:describe("merge/1+", function (t2)
  t2:test("can merge multiple tables together", function (t3)
    local tab1  = {
      name = "John Doe",
      age = 1000,
    }

    local tab2 = {
      address = "Somewhere",
      state = "FL",
    }

    t3:assert_table_eq(
      {
        name = "John Doe",
        age = 1000,
        address = "Somewhere",
        state = "FL",
      },
      m.merge(tab1, tab2)
    )
  end)
end)

case:describe("copy/1", function (t2)
  t2:test("can shallow copy a table", function (t3)
    local tab1 = {
      name = "John Doe",
      age = 1000,
      address = "Somewhere",
      state = "FL",
    }

    local tab2 = m.copy(tab1)

    t3:refute_eq(tab2, tab1)
    t3:assert_table_eq(tab2, tab1)
  end)
end)

case:describe("deep_copy/1", function (t2)
  t2:test("can make a deep copy of a table", function (t3)
    local tab1 = {
      name = "John Doe",
      age = 1000,
      position = {
        x = 1,
        y = 2,
        z = 3,
      },
      meta = {
        address = {
          address1 = "Somewhere",
          state = "MR",
          country_code = "JM",
        },
      },
    }

    local tab2 = m.deep_copy(tab1)

    t3:refute_eq(tab2, tab1)
    t3:refute_eq(tab2.position, tab1.position)
    t3:refute_eq(tab2.meta, tab1.meta)
    t3:refute_eq(tab2.meta.address, tab1.meta.address)

    t3:assert_deep_eq(tab2, tab1)
  end)
end)

case:describe("equals/2", function (t2)
  t2:test("compares 2 tables and determines if they're equal", function (t3)
    t3:assert(m.equals({a = 1}, {a = 1}))
    t3:refute(m.equals({a = 1}, {a = 1, b = 2}))
    t3:refute(m.equals({a = 1}, {a = 2}))
    t3:refute(m.equals({a = 1}, {b = 1}))
  end)

  t2:test("can handle nils", function (t3)
    t3:assert(m.equals(nil, nil))
    t3:refute(m.equals(nil, {a = 1}))
    t3:refute(m.equals({a = 1}, nil))
  end)
end)

case:describe("intersperse/2", function (t2)
  t2:test("will add spacer item between elements in table", function (t3)
    local t = {"a", "b", "c", "d", "e"}
    local r = m.intersperse(t, ",")

    t3:assert_table_eq(r, {"a", ",", "b", ",", "c", ",", "d", ",", "e"})
  end)

  t2:test("will return an empty table given an empty table", function (t3)
    local t = {}
    local r = m.intersperse(t, ",")
    t3:assert_table_eq(r, {})
  end)
end)

case:describe("bury/3", function (t2)
  t2:test("deeply place value into map", function (t3)
    local t = {}

    -- a single key
    m.bury(t, {"a"}, 1)

    t3:assert_eq(t["a"], 1)

    m.bury(t, {"b", "c"}, 2)
    t3:assert(t["b"])
    t3:assert_eq(t["b"]["c"], 2)
  end)
end)

case:describe("is_empty/1", function (t2)
  t2:test("returns true if a table is empty", function (t3)
    t3:assert(m.is_empty({}))
    t3:assert(m.is_empty({a = nil, b = nil, c = nil}))
  end)

  t2:test("returns false if table contains any pairs", function (t3)
    t3:refute(m.is_empty({a = 1}))
    t3:refute(m.is_empty({b = 1, c = nil}))
  end)
end)

case:describe("sample/1", function (t2)
  t2:test("returns nil if no elements are in table", function (t3)
    t3:refute(m.sample({}))
  end)

  t2:test("returns a random key-value pair even if only 1 element is in the table", function (t3)
    local t = {a = 1}

    local k, v = m.sample(t)

    t3:assert_eq(k, "a")
    t3:assert_eq(v, 1)
  end)

  t2:test("returns a random element in table", function (t3)
    local t = {
      a = 1,
      b = 2,
      c = 3,
      d = 4,
      e = 5,
    }

    for _ = 1,5 do
      local k, v = m.sample(t)

      t3:assert_eq(t[k], v)
    end
  end)
end)

case:describe("filter/2", function (t2)
  t2:test("only includes truthy elements from callback", function (t3)
    local t = {
      a = 1,
      b = 2,
      c = 3,
      d = 4,
      e = 5,
      f = 6,
    }

    local new_t =
      m.filter(t, function (_key, value)
        return math.fmod(value, 2) == 0
      end)

    t3:assert(m.equals(
      t,
      {
        a = 1,
        b = 2,
        c = 3,
        d = 4,
        e = 5,
        f = 6,
      }
    ))

    t3:assert(m.equals(
      new_t,
      {
        b = 2,
        d = 4,
        f = 6,
      }
    ))
  end)
end)

case:describe("reject/2", function (t2)
  t2:test("only removes truthy elements from callback", function (t3)
    local t = {
      a = 1,
      b = 2,
      c = 3,
      d = 4,
      e = 5,
      f = 6,
    }

    local new_t =
      m.reject(t, function (_key, value)
        return math.fmod(value, 2) == 0
      end)

    t3:assert(m.equals(
      t,
      {
        a = 1,
        b = 2,
        c = 3,
        d = 4,
        e = 5,
        f = 6,
      }
    ))

    t3:assert(m.equals(
      new_t,
      {
        a = 1,
        c = 3,
        e = 5,
      }
    ))
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
