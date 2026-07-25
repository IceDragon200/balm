local Luna = require("balm/luna")
local Object = require("balm/object")
local m = require("balm/m/object")

local TestObject = Object:extends("TestObject"):tap(function (klass)
  local ic = klass.instance_class

  function ic:initialize(opts)
    ic._super.initialize(self)

    self.id = opts.id
    self.name = opts.name
  end
end)

local case = Luna:new("balm.m.object")

case:describe("construct/2", function (t2)
  t2:test("can reconstruct an object", function (t3)
    local subject = m.construct(TestObject, {
      id = "id",
      name = "object_name",
    })

    t3:assert(Object.is_object(subject))
    t3:assert(subject:is_instance_of(TestObject))

    local subject2 = m.construct(TestObject, subject)

    t3:assert_eq(subject, subject2)
  end)
end)

case:describe("construct_record/2", function (t2)
  t2:test("can reconstruct a record of objects", function (t3)
    local subject = m.construct_record(TestObject, {
      x = {
        id = "id",
        name = "object_name",
      },
      y = {
        id = "id2",
        name = "object_name2",
      }
    })

    t3:refute(Object.is_object(subject))
    t3:assert_eq(type(subject), "table")
    t3:assert(Object.is_object(subject.x))
    t3:assert(Object.is_object(subject.y))
    t3:assert(subject.x:is_instance_of(TestObject))
    t3:assert(subject.y:is_instance_of(TestObject))

    local subject2 = m.construct_record(TestObject, subject)

    t3:assert_table_eq(subject, subject2)
  end)
end)

case:execute()
case:display_stats()
case:maybe_error()
