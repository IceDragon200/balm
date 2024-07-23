local number_round = require("balm/m/number").round
local number_floor = math.floor
local number_ceil = math.ceil
local Vector3 = require("balm/m/vector/3")

--- |y+ (h)   ,x+ (w)
--- |       .
--- |     ,
--- |   .
--- | ,
---   ,
---     .
---       ,
---         .
---           ,z+ (d)
---
--- Cuboid module
--- * `x` runs from left to right of the screen, left being -x and right being +x
--- * `y` runs from bottom to top of the screen (in other words, like 3d space), -y is down, +y is up
--- * `z` is the xy plane's depth, -z is further into the screen and +z is further out of the screen
---
--- @namespace balm.m.cuboid
local m = {}

do
  --- @spec new(x: Number, y: Number, z: Number, w: Number, h: Number, d: Number): Cuboid
  function m.new(x, y, z, w, h, d)
    return {
      x = x or 0,
      y = y or 0,
      z = z or 0,
      w = w or 0,
      h = h or 0,
      d = d or 0,
    }
  end

  --- @spec new_from_vec3(pos: Vector3, size: Vector3): Cuboid
  function m.new_from_vec3(pos, size)
    return m.new(pos.x, pos.y, pos.z, size.x, size.y, size.z)
  end

  --- @spec new_from_extents(Vector3, Vector3): Cuboid
  function m.new_from_extents(pos1, pos2)
    local x1 = math.min(pos1.x, pos2.x)
    local x2 = math.max(pos1.x, pos2.x)

    local y1 = math.min(pos1.y, pos2.y)
    local y2 = math.max(pos1.y, pos2.y)

    local z1 = math.min(pos1.z, pos2.z)
    local z2 = math.max(pos1.z, pos2.z)

    return m.new(
      x1,
      y1,
      z1,
      x2 - x1,
      y2 - y1,
      z2 - z1
    )
  end

  --- @spec copy(Cuboid): Cuboid
  function m.copy(other)
    return m.new(
      other.x,
      other.y,
      other.z,
      other.w,
      other.h,
      other.d
    )
  end

  --- @spec position(Cuboid): Vector3
  function m.position(subject)
    return Vector3.new(subject.x, subject.y, subject.z)
  end

  --- @spec size(Cuboid): Vector3
  function m.size(subject)
    return Vector3.new(subject.w, subject.h, subject.d)
  end

  --- @spec volume(Cuboid): Number
  function m.volume(subject)
    return subject.w * subject.h * subject.d
  end

  --- @spec surface_area(Cuboid): Number
  function m.surface_area(subject)
    local xy = subject.w * subject.h
    local xz = subject.w * subject.d
    local yz = subject.h * subject.d
    return xy * 2 + xz * 2 + yz * 2
  end

  --- @spec is_empty(Cuboid): Boolean
  function m.is_empty(subject)
    return subject.w == 0 or subject.h == 0 or subject.d == 0
  end

  --- @mutative
  --- @spec contract_xyz(Cuboid, x: Number, y: Number, z: Number): Cuboid
  function m.contract_xyz(subject, x, y, z)
    if x then
      subject.x = subject.x + x
      subject.w = subject.w - x * 2
    end

    if y then
      subject.y = subject.y + y
      subject.h = subject.h - y * 2
    end

    if z then
      subject.z = subject.z + z
      subject.d = subject.d - z * 2
    end

    return subject
  end

  --- @mutative
  --- @spec contract(Cuboid, Vector3): Cuboid
  function m.contract(subject, vec3)
    return m.contract_xyz(subject, vec3.x, vec3.y, vec3.z)
  end

  --- @mutative
  --- @spec expand_xyz(Cuboid, x: Number, y: Number, z: Number): Cuboid
  function m.expand_xyz(subject, x, y, z)
    if x then
      subject.x = subject.x - x
      subject.w = subject.w + x * 2
    end

    if y then
      subject.y = subject.y - y
      subject.h = subject.h + y * 2
    end

    if z then
      subject.z = subject.z - z
      subject.d = subject.d + z * 2
    end

    return subject
  end

  --- @mutative
  --- @spec expand_xyz(Cuboid, vec3: Vector3): Cuboid
  function m.expand(subject, vec3)
    return m.expand_xyz(subject, vec3.x, vec3.y, vec3.z)
  end

  --- @mutative
  --- @spec resize(Cuboid, w: Number, h: Number, d: Number): Cuboid
  function m.resize(subject, w, h, d)
    subject.w = w
    subject.h = h
    subject.d = d

    return subject
  end

  --- @mutative
  --- @spec move(Cuboid, x: Number, y: Number, z: Number): Cuboid
  function m.move(subject, x, y, z)
    subject.x = x
    subject.y = y
    subject.z = z

    return subject
  end

  --- @mutative
  --- @spec translate(Cuboid, x: Number, y: Number, z: Number): Cuboid
  function m.translate(subject, x, y, z)
    subject.x = subject.x + x
    subject.y = subject.y + y
    subject.z = subject.z + z

    return subject
  end

  --- @mutative
  --- @spec floor(Cuboid): Cuboid
  function m.floor(subject)
    subject.x = number_floor(subject.x)
    subject.y = number_floor(subject.y)
    subject.z = number_floor(subject.z)
    subject.w = number_floor(subject.w)
    subject.h = number_floor(subject.h)
    subject.d = number_floor(subject.d)
    return subject
  end

  --- @mutative
  --- @spec ceil(Cuboid): Cuboid
  function m.ceil(subject)
    subject.x = number_ceil(subject.x)
    subject.y = number_ceil(subject.y)
    subject.z = number_ceil(subject.z)
    subject.w = number_ceil(subject.w)
    subject.h = number_ceil(subject.h)
    subject.d = number_ceil(subject.d)
    return subject
  end

  --- @mutative
  --- @spec round(Cuboid): Cuboid
  function m.round(subject)
    subject.x = number_round(subject.x)
    subject.y = number_round(subject.y)
    subject.z = number_round(subject.z)
    subject.w = number_round(subject.w)
    subject.h = number_round(subject.h)
    subject.d = number_round(subject.d)
    return subject
  end

  --- Aligns the `subject` within the given `container` based on the
  --- parameters specified in the `aligns` vector.
  --- The `aligns` range must be between -1 and 1 (inclusive).
  --- The `anchor` range must be between -1 and 1 (inclusive).
  --- The anchor defines the normalized coordinate space of where the
  --- cuboid should align `from`
  ---
  --- @mutative
  --- @spec align(
  ---   subject: Cuboid,
  ---   anchor: Vector3,
  ---   container: Cuboid,
  ---   aligns: Vector3
  --- ): Cuboid
  function m.align(subject, anchor, container, aligns)
    if aligns.x then
      local alx = container.x + container.w * ((aligns.x + 1) / 2)
      local anx = subject.w * ((anchor.x + 1) / 2)
      subject.x = alx - anx
    end

    if aligns.y then
      local aly = container.y + container.h * ((aligns.y + 1) / 2)
      local any = subject.h * ((anchor.y + 1) / 2)
      subject.y = aly - any
    end

    if aligns.z then
      local alz = container.z + container.d * ((aligns.z + 1) / 2)
      local anz = subject.d * ((anchor.z + 1) / 2)
      subject.z = alz - anz
    end

    return subject
  end

  --- Splits the cuboid along it's x line: producing 2 cuboids
  ---
  --- @spec slice_x(Cuboid, x: Number): Cuboid[]
  function m.slice_x(subject, x)
    local result = {}

    local a = m.copy(subject)
    local b = m.copy(subject)

    a.w = math.max(0, math.min(a.w, x))
    b.w = math.max(0, a.w - x)
    b.x = subject.x + x

    return result
  end

  --- Splits the cuboid along it's y line: producing 2 cuboids
  ---
  --- @spec slice_y(Cuboid, y: Number): Cuboid[]
  function m.slice_y(subject, y)
    local result = {}

    local a = m.copy(subject)
    local b = m.copy(subject)

    a.h = math.max(0, math.min(a.h, y))
    b.h = math.max(0, a.h - y)
    b.y = subject.y + y

    return result
  end

  --- Splits the cuboid along it's z line: producing 2 cuboids
  ---
  --- @spec slice_z(Cuboid, z: Number): Cuboid[]
  function m.slice_z(subject, z)
    local result = {}

    local a = m.copy(subject)
    local b = m.copy(subject)

    a.d = math.max(0, math.min(a.d, z))
    b.d = math.max(0, a.d - z)
    b.z = subject.z + z

    return result
  end

  --- Determines if the `subject` completely contains the `other` cuboid.
  ---
  --- @spec contains(subject: Cuboid, other: Cuboid): Boolean
  function m.contains(subject, other)
    local px1 = subject.x
    local px2 = subject.x + subject.w
    local py1 = subject.y
    local py2 = subject.y + subject.h
    local pz1 = subject.z
    local pz2 = subject.z + subject.d

    local cx1 = other.x
    local cx2 = other.x + other.w
    local cy1 = other.y
    local cy2 = other.y + other.h
    local cz1 = other.z
    local cz2 = other.z + other.d

    return cx1 >= px1 and cx1 <= px2 and
           cx2 >= px1 and cx2 <= px2 and
           cy1 >= py1 and cy1 <= py2 and
           cy2 >= py1 and cy2 <= py2 and
           cz1 >= pz1 and cz1 <= pz2 and
           cz2 >= pz1 and cz2 <= pz2
  end

  --- Merges variable list of Cuboids into one Cuboid which would contain all
  --- of them.
  ---
  --- @spec merge(...Cuboid): Cuboid
  function m.merge(...)
    local len = select('#', ...)

    local tmp

    local x1
    local x2

    local y1
    local y2

    local z1
    local z2

    local c
    for i = 1,len do
      c = select(i, ...)

      if x1 then
        if c.x < x1 then
          x1 = c.x
        end
      else
        x1 = c.x
      end

      tmp = c.x + x.w
      if x2 then
        if tmp > x2 then
          x2 = tmp
        end
      else
        x2 = tmp
      end

      if y1 then
        if c.y < y1 then
          y1 = c.y
        end
      else
        y1 = c.y
      end

      tmp = c.y + x.h
      if y2 then
        if tmp > y2 then
          y2 = tmp
        end
      else
        y2 = tmp
      end

      if z1 then
        if c.z < z1 then
          z1 = c.z
        end
      else
        z1 = c.z
      end

      tmp = c.z + x.d
      if z2 then
        if tmp > z2 then
          z2 = tmp
        end
      else
        z2 = tmp
      end
    end

    return m.new(
      x1 or 0,
      y1 or 0,
      z1 or 0,
      (x2 or 0) - (x1 or 0),
      (y2 or 0) - (y1 or 0),
      (z2 or 0) - (z1 or 0)
    )
  end

end

return m
