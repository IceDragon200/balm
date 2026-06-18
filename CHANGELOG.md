# 2026.6.18

* Added `balm.s.Vector#modulo/2`
* Added `balm.s.Vector#exponent/2`

# 2026.6.11

* Added `balm.u.Tiler` utility class
* Added `balm.m.dyn_vector` module
* Added `balm.u.Spring` utility class

# 2026.6.10

* Replaced `math.pow/2` usage with exponent operator `^`
* Use `math.atan` where `math.atan2` is not available
* Added `balm.m.Vector2#angle/0` and `balm.m.Vector2#degrees/0`

# 2026.6.6

* Bit module will now attempt to lookup and possibly load native bit module
  * This means the lua code is now a fallback and should greatly improve bitops
* Persistence modules refactored
  * Everything has been updated, and tested, it's quite a bit to cover here
* Added `balm.u.Timeline#upsert_track/1` for possibly creating a new track or leaving the existing one alone
* Added `balm.u.Timeline#add_wait_for_others/2`
* Added `balm.u.Properties#keys/0`
* Added `balm.u.RecordTable#keys/0`
* Added `balm.u.RecordTable#values/0`
* Added `balm.m.string.split/3` this is a includes_captures argument which allows capture the segments matched specifically by the pattern
  * The primary usecase is to retain things like spaces when splitting by them

# 2026.6.5

* `balm.u.rect` now has a metatable
* Added `balm.m.color.from_rgba32/4`
* Added `balm.u.Timeline#add_callback/2` add a callback option for Timeline items.
* Added `balm.u.Tweener#calc_remaining_time/0` calculates the remaining time for the tweener to complete.
* Added `balm.m.table.split/2`
* Added `balm.m.table.pop/2`
* Tweener `from` table can now be nil or its values set as true to use whatever the destination's values were at the time of reset, at a glance it seems useless on its own, as Tweener already did this:
  ```lua
  Tweener:new({ x = 0 }, 2, { x = 4 }, nil)
  Tweener:new({ x = -2 }, 2, { x = 4 }, { x = true })

  -- The strength lies primarily when Tweener is used through the Timeline
  -- In the below example we set a track loop that modulates the destination's value between
  -- -2 and 2, but note we don't specific the from values in this context
  -- the first sequence would scale the x from 8 down to -1, when the next tween is ran
  -- it will be scaled from whatever the dest is at the time of reset to x = 2.
  local timeline = Timeline:new()

  local dest = { x = 8 }
  timeline
    :new_track(0)
    :set_track_loop(0, true)
    :add_tween(0, dest, 1, { x = -2 })
    :add_tween(0, dest, 1, { x = 2 })

  -- That's great and all, but you can also tag specific fields that should be modified by reset
  -- In this next example, we're allow x to be taken from its dest, but y should ALWAYS
  -- be -1 or 1 for its origin based on its tween.
  local timeline = Timeline:new()

  local dest = { x = 8, y = -8 }
  timeline
    :new_track(0)
    :set_track_loop(0, true)
    :add_tween(0, dest, 1, { x = -2 }, { x = true, y = -1 })
    :add_tween(0, dest, 1, { x = 2 }, { x = true, y = 1 })
  ```

* Tweener `from` and `to` tables now support functions as the values
  * This allows the Tweener values to be dynamic rather than static, though keep in mind, do note the easer still applies based on the difference between the from and to
  * A new `origin` field exists which contains
  ```lua
  -- In this example, we allow the target x to be controlled by a function which contains a local
  -- variable y.
  -- We skip the usual update functions and quietly apply the tween's maximal state using #apply/1
  -- In the first test, we set it to max for the initial 16 value, then change y to 20 and apply
  -- it again to prove that the x destination indeed changed.
  local y = 16
  local tweener = Tweener:new({ x = 8 }, 2, { x = function (r) return y end })
  tweener:apply(1)
  assert(tweener.dest.x == 16)

  y = 20
  tweener:apply(1)
  assert(tweener.dest.x == 20)

  -- This doesn't seem useful, but it is when you get into something like the screen's height
  local tweener = Tweener:new({ y = 8 }, 2, { y = function (_r) return love.graphics.getHeight() end })

  -- ... do your usual frame update, tweener will scale its y destination based on the screen's height
  tweener:update(0.015)
  ```

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
