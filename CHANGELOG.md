# 2026.5.7

* Added `balm.m.object` module for additional object helper functions
  * Added `balm.m.object.construct/2` for reconstructing an object from a simple table or instance
  * Added `balm.m.object.construct_record/2` for constructing a record of objects from a table
* Added `balm.m.vector2.to_hash/2`
* Added `balm.m.vector2.from_hash/3`
* Added `balm.m.vector2.negate/2`
* Added `balm.m.vector2.relative/2`
* Added `Luna#assert_matches/3`
* Added `balm.m.rect.is_rect_like/1`

# 2026.5.4

* Added `balm.s.MinHeap` from foundation
* Added `balm.s.Records`
* Added `balm.Object#copy/0` This means objects have a copy method by default now, objects are expected to override the `initialize_copy/1` method to add their own copy logic for their fields.

# 2025.3.27

* Added `balm.m.color`

# 2024.7.23

* Added `balm.m.ansi.ansi_format_lazy/2`
* Added `balm.m.value.inspect/1`
* Added `balm.m.value.is_blank/1`
* Added `balm.m.value.first_present/1`
* Added `balm.m.value.deep_equals/1`
* Added `balm.m.cuboid` module
* Added `balm.s.DataMatrix`
* Added `balm.m.vector2.random/0`
* Added `balm.m.vector3.random/0`
* Added `balm.m.vector4.random/0`
