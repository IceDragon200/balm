# 2026.6.5

* Added `balm.u.Timeline#add_callback/2` add a callback option for Timeline items.
* Added `balm.u.Tweener#calc_remaining_time/0` calculates the remaining time for the tweener to complete.
* Added `balm.m.table.split/2`
* Added `balm.m.table.pop/2`

# 2026.6.4

* Added `balm.u.Timeline` class, this object is used to schedule tweens over time
* Added `balm.u.Tweener` class, an object used to apply a tweening operation on an object over time
* Fixed `balm.m.value.inspect` throwing up when given a function
* Fixed `balm.m.value.inspect` over-quoting numbers

# 2026.6.2

* Added `balm.u.RecordTable#size/0`
* Added Wave module
* Fixed issues with Easers module
  * `quad_in_out` was misnamed as simply `in_out`
  * `sine_in` used `sin` instead of `cos` causing a snapping effect when k = 1
  * `sine_in_out` was missing it's variable k
* Color now has a metatable, and can be used as a pseudo object
* Added `balm.m.pack.pack_v2` extracted from Vector2's to_hash
* Added `balm.m.pack.unpack_v2` extracted from Vector2 from_hash

# 2026.5.30

* Added `balm.m.Rect.merge_into/2+` To merge multiple rectangles into one destination rectangle
* Added `balm.m.Rect.contains_point/2` to determine if the given coordinates are inside the rectangle

# 2026.5.23

* Added `balm.s.Deque#clear/0`

# 2026.5.22

* Added `balm.Object&bind_metatable/1` For setting the metatable from a class on an existing Table
* Added `balm.s.OPALL` Ordered, Pooled, Linked-List a specialized structure that combines a LinkedList and a MinHeap

# 2026.5.21

* Added `Properties#put_new_lazy/2`
* Added `Properties#get_lazy/2`
* Added `RecordTable#each/1`

# 2026.5.18

* Added limits module which just contains some hardcoded integer values
* Added `balm.u.U128` a simple 128 bit integer object
* Added ID128Generator to return `U128#to_le128_string/0` strings as the ID
* Fixed potential metatable corruption from `table_freeze/1`
* Added `balm.HEX_LOWERCASE_ENCODE_TABLE`
* Froze all balm encoding tables and other static lookup tables

# 2026.5.16

* Added `balm.utf8.next_scalar/2`

# 2026.5.15

* Ported `balm.s.WeightedList` from foundation (lua)
* Ported `balm.s.Deque` from Maje (js)

# 2026.5.14

* Ported `IDGenerator` from project
* Ported `RecordTable` from project
* Ported `Properties` from project
* Added `balm.s.Vector` as a general purpose vector
* Added `balm.s.List#shuffle/0` to shuffle the values in a list

# 2026.5.9

* Rewrote `balm.m.value.inspect/1`
* Added `balm.m.value.matches/2` function for pattern matching
* Added `balm.m.value.rawmatches/2` function for pattern matching

## Object

* General improvement to object inspection, string and meta method passing
* Added `#equals/1`
* Added `#matches/1`
* Added `#inspect/0`
* `Object:extends/1` now copies meta methods to child class, note this is not typical prototype or meta inheritance, a class gets a copy of its parent's meta tables AT the time of extension.
* `Object#to_string/0` is now used by the metamethod `__tostring/0`

## Luna

* Added `#assert_raw_eq/3`
* Added `#assert_raw_neq/3`
* Added `#refute_raw_eq/3`
* Added `#refute_raw_neq/3`
* Added `#refute_neq/3`

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
* Added `balm.u.Quadmap`, based on my older "Grid" helper class
* Added `balm.s.List#sort/0`
* Added `balm.s.List#sort_by/1`

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
