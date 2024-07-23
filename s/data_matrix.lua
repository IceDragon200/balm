local Object = require("balm/object")
local Vector3 = require("balm/m/vector/3")
local Cuboid = require("balm/m/cuboid")

--- @namespace balm.s

---
--- A data matrix is a 3 dimnensional data map.
--- The data itself is stored linearly as a massive table encoded in the order: z (plane) y (column) x (row)
---
--- @since "2024.7.23"
--- @class DataMatrix<T>
local DataMatrix = Object:extends("balm.DataMatrix")

do
  local ic = DataMatrix.instance_class

  --- @spec #initialize(w: Integer, h: Integer, d: Integer, fun: Function): void
  --- @spec #initialize(w: Integer, h: Integer, d: Integer, default: T): void
  function ic:initialize(w, h, d, default_or_fun)
    ic._super.initialize(self)

    self.m_w = math.floor(w)
    self.m_h = math.floor(h)
    self.m_d = math.floor(d)
    self.m_volume = 0
    self.m_data = nil

    self:_validate_declared_size()
    self:_initialize_data(default_or_fun)
  end

  --- Initializes the target data matrix from another matrix.
  ---
  --- @mutative self
  --- @spec #initialize_copy(other: DataMatrix): void
  function ic:initialize_copy(other)
    self.m_w = other.m_w
    self.m_h = other.m_h
    self.m_d = other.m_d
    self.m_volume = other.m_volume
    self.m_data = {}
    for i = 1,self.m_volume do
      self.m_data[i] = other.m_data[i]
    end
  end

  --- Creates a copy of the data matrix, note that the data is only,
  --- copied at the top-level, if a cell contains any tables those
  --- will be left as is.
  ---
  --- @spec #copy(): DataMatrix
  function ic:copy()
    local result = self._class:alloc()
    result:initialize_copy(self)
    return result
  end

  function ic:_validate_declared_size()
    assert(self.m_w > 0, "width must be greater than 0")
    assert(self.m_h > 0, "height must be greater than 0")
    assert(self.m_d > 0, "depth must be greater than 0")

    self.m_volume = self.m_w * self.m_h * self.m_d
  end

  function ic:_initialize_data(default_or_fun)
    if default_or_fun == nil then
      self.m_data = {}
    elseif type(default_or_fun) == "function" then
      self:_initialize_data_with_function(default_or_fun)
    else
      self:_initialize_data_with_default(default_or_fun)
    end
  end

  --- @spec #_initialize_data_with_function(Function/4): void
  function ic:_initialize_data_with_function(fun)
    self.m_data = {}
    self:fill_lazy(fun)
  end

  --- @spec #_initialize_data_with_default(Any): void
  function ic:_initialize_data_with_default(default)
    self.m_data = {}
    self:fill(default)
  end

  --- @spec #data(): T[]
  function ic:data()
    return self.m_data
  end

  --- Reports the width of the data matrix
  ---
  --- @spec #width(): Integer
  function ic:width()
    return self.m_w
  end

  --- Reports the height of the data matrix
  ---
  --- @spec #height(): Integer
  function ic:height()
    return self.m_h
  end

  --- Reports the depth of the data matrix
  ---
  --- @spec #depth(): Integer
  function ic:depth()
    return self.m_d
  end

  --- Reports the size in cells of the data matrix
  ---
  --- @spec #size(): Vector3
  function ic:size()
    return Vector3.new(self.m_w, self.m_h, self.m_d)
  end

  --- Helper function for quickly generating the `src_cube` from a
  --- data matrix for use in `blit` functions.
  ---
  --- @spec #src_cube(): Cuboid
  function ic:src_cube()
    return Cuboid.new(
      0,
      0,
      0,
      self.m_w,
      self.m_h,
      self.m_d
    )
  end

  --- Reports the size in cells of the data matrix
  ---
  --- @spec #volume(): Integer
  function ic:volume()
    return self.m_volume
  end

  --- @mutative self
  --- @spec #fill(T): void
  function ic:fill(value)
    for i1 = 1,self.m_volume do
      self.m_data[i1] = value
    end
  end

  function ic:xyz_to_index(x, y, z)
    return 1 + z * self.m_h * self.m_w + y * self.m_w + x
  end

  function ic:index_to_xyz(i1)
    local i = i1 - 1
    x = math.floor(i % self.m_w)
    y = math.floor((i / self.m_w) % self.m_h)
    z = math.floor((i / self.m_h) / self.m_w)
    return x, y, z
  end

  --- @spec #wrap_coords(
  ---   x: Integer,
  ---   y: Integer,
  ---   z: Integer
  --- ): (Integer, Integer, Integer)
  function ic:wrap_coords(x, y, z)
    x = x % self.m_w
    y = y % self.m_h
    z = z % self.m_d

    return x, y, z
  end

  function ic:test_bounds(x, y, z)
    if x < 0 or x >= self.m_w then
      return false, "x is out of bounds"
    end

    if y < 0 or y >= self.m_h then
      return false, "y is out of bounds"
    end

    if z < 0 or z >= self.m_d then
      return false, "z is out of bounds"
    end

    return true
  end

  --- @mutative self
  --- @spec #fill_lazy(Function/4): void
  function ic:fill_lazy(fun)
    local x
    local y
    local z
    for i1 = 1,self.m_volume do
      x, y, z = self:index_to_xyz(i1)
      self.m_data[i1] = fun(x, y, z, i1 - 1)
    end
  end

  --
  -- Cell Operations
  --

  --- Retrieve cell at specified xyz coordinates.
  ---
  --- @spec #get(
  ---   x: Integer,
  ---   y: Integer,
  ---   z: Integer,
  ---   is_wrapped: Boolean = false
  --- ): T
  function ic:get(x, y, z, is_wrapped)
    if is_wrapped then
      x, y, z = self:wrap_coords(x, y, z)
    end

    local ok, err = self:test_bounds(x, y, z)
    if ok then
      local i1 = self:xyz_to_index(x, y, z)
      return self.m_data[i1]
    else
      error(err)
    end
  end

  --- Put a value at specified xyz coordinates
  ---
  --- @mutative self
  --- @spec #put(
  ---   x: Integer,
  ---   y: Integer,
  ---   z: Integer,
  ---   value: T,
  ---   is_wrapped: Boolean
  --- ): void
  function ic:put(x, y, z, value, is_wrapped)
    if is_wrapped then
      x, y, z = self:wrap_coords(x, y, z)
    end

    local ok, err = self:test_bounds(x, y, z)
    if ok then
      local i1 = self:xyz_to_index(x, y, z)
      self.m_data[i1] = value
    else
      error(err)
    end
  end

  --- Put a value at specified xyz coordinates
  ---
  --- @mutative self
  --- @spec #put_lazy(
  ---   x: Integer,
  ---   y: Integer,
  ---   z: Integer,
  ---   value: Function/4 => T,
  ---   is_wrapped: Boolean
  --- ): void
  function ic:put_lazy(x, y, z, fun, is_wrapped)
    if is_wrapped then
      x, y, z = self:wrap_coords(x, y, z)
    end

    local ok, err = self:test_bounds(x, y, z)
    if ok then
      local i1 = self:xyz_to_index(x, y, z)
      self.m_data[i1] = fun(x, y, z, i1 - 1)
    else
      error(err)
    end
  end

  --- @spec #sub_matrix(cuboid: Cuboid, is_wrapped: Boolean): DataMatrix
  function ic:sub_matrix(cuboid, is_wrapped)
    local ok, err
    local x, y, z = cuboid.x, cuboid.y, cuboid.z
    local w, h, d = cuboid.w, cuboid.h, cuboid.d
    if is_wrapped then
      x, y, z = self:wrap_coords(x, y, z)
    end
    ok, err = self:test_bounds(x, y, z)
    if not ok then
      error(err)
    end
    if not is_wrapped then
      ---
      local x2, y2, z2 = x + w, y + h, z + d
      ok, err = self:test_bounds(x2, y2, z2)
      if not ok then
        error(err)
      end
    end

    local szp
    local syp
    local szyp
    local si
    local dzp
    local dyp
    local dzyp
    local di
    local smx, smy, smz
    local res = DataMatrix:new(w, h, d)
    local res_data = res.m_data

    for mz = 0,d do
      smz = z + mz
      if is_wrapped then
        smz = smz % self.m_d
      end
      szp = smz * self.m_h * self.m_w
      dzp = mz * h * w
      for my = 0,h do
        smy = y + my
        if is_wrapped then
          smy = smy % self.m_h
        end
        syp = smy * self.m_w
        dyp = my * w
        szyp = szp + syp
        dzyp = dzp + dyp
        for mx = 0,w do
          smx = x + mx
          if is_wrapped then
            smx = smx % self.m_w
          end
          si = szyp + smx
          di = dzyp + mx
          res_data[di + 1] = self.m_data[si + 1]
        end
      end
    end

    return res
  end

  --- @spec #reduce(acc: Any, fun: Function/6 => Any): Any
  function ic:reduce(acc, fun)
    local i1
    for z = 0,self.m_d-1 do
      for y = 0,self.m_h-1 do
        for x = 0,self.m_w-1 do
          i1 = self:xyz_to_index(x, y, z)
          fun(x, y, z, i1 - 1, self.m_data[i1], acc)
        end
      end
    end
    return acc
  end

  --- @spec #each(acc: Any, fun: Function/5): self
  function ic:each(fun)
    self:reduce(0, function (x, y, z, i, d, c)
      fun(x, y, z, i, d)
      return c + 1
    end)
    return self
  end

  --- Executes given `fun` over every cell in the matrix.
  ---
  --- @mutative self
  --- @spec #map(mapper: Function/5): self
  function ic:map(fun)
    local i1
    for z = 0,self.m_d-1 do
      for y = 0,self.m_h-1 do
        for x = 0,self.m_w-1 do
          i1 = self:xyz_to_index(x, y, z)
          self.m_data[i1] = fun(x, y, z, i1 - 1, self.m_data[i1])
        end
      end
    end

    return self
  end

  --- @mutative self
  --- @spec #blit_map(
  ---   pos: Vector3,
  ---   other: DataMatrix,
  ---   src_cube: Cuboid,
  ---   mapper: Function/10,
  ---   is_wrapped: Boolean
  --- ): void
  function ic:blit_map(pos, other, src_cube, mapper, is_wrapped)
    local dx, dy, dz = pos.x, pos.y, pos.z
    local sx, sy, sz = src_cube.x, src_cube.y, src_cube.z
    local sw, sh, sd = src_cube.w, src_cube.h, src_cube.d
    local sow, soh, sod = other.m_w, other.m_h, other.m_d
    if is_wrapped then
      dx, dy, dz = self:wrap_coords(dx, dy, dz)
      sx, sy, sz = other:wrap_coords(sx, sy, sz)
    end

    local dcx, dcy, dcz
    local scx, scy, scz
    local si
    local di
    local should_map = mapper ~= false

    for z = 0,sd-1 do
      dcz = dz + z
      scz = sz + z

      if is_wrapped then
        dcz = dcz % self.m_d
        scz = scz % sod
      end

      for y = 0,sh-1 do
        dcy = dy + y
        scy = sy + y

        if is_wrapped then
          dcy = dcy % self.m_h
          scy = scy % soh
        end

        for x = 0,sw-1 do
          dcx = dx + x
          scx = sx + x

          if is_wrapped then
            dcx = dcx % self.m_w
            scx = scx % sow
          end

          di = dcz * self.m_h * self.m_w + dcy * self.m_w + dcx
          si = scz * soh * sow + scy * sow + scx

          if should_map then
            self.m_data[di + 1] = mapper(
              dcx, dcy, dcz,
              di,
              self.m_data[di + 1],
              scx, scy, scz,
              si,
              other.m_data[si + 1]
            )
          else
            self.m_data[di + 1] = other.m_data[si + 1]
          end
        end
      end
    end
  end
end

return DataMatrix
