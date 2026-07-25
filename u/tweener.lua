local assertions = require("balm/m/assertions")
local Object = require("balm/object")
local Easers = require("balm/m/easers")

--- @namespace balm.u

--- @since "2026.6.4"
--- @class Tweener
local Tweener = Object:extends("balm.u.Tweener")
do
  local ic = Tweener.instance_class

  --- @spec #initialize(dest: Table, duration: Number, to: Table, from?: Table, easers: Table): void
  function ic:initialize(dest, duration, to, from, easers)
    ic._super.initialize(self)
    self:set(dest, duration, to, from, easers)
  end

  --- @spec #set(dest: Table, duration: Number, to: Table, from?: Table, easers: Table): self
  function ic:set(dest, duration, to, from, easers)
    self.dest = dest
    self.elapsed = 0
    self.duration = duration
    self.to = assertions.is_table(to)
    self.origin = {}
    self.from = assertions.is_table(from or {})
    self.easers = assertions.is_table(easers or {})

    for key, _ in pairs(self.to) do
      if self.from[key] == nil then
        self.from[key] = true
      end
    end

    for key, _ in pairs(self.to) do
      local easer = self.easers[key]
      local ty = type(easer)
      if nil == easer then
        self.easers[key] = assert(Easers.linear, "missing easer type=linear ")
      elseif "string" == ty then
        self.easers[key] = assert(Easers[easer], "missing easer type="..easer)
      elseif "function" == ty then
        self.easers[key] = easer
      else
        error("unexpected type for easer function, expected a name or function")
      end
    end

    self:refresh_origin()

    return self
  end

  --- @since "2026.6.5"
  --- @spec #calc_remaining_time(): Number
  function ic:calc_remaining_time()
    return self.duration - self.elapsed
  end

  --- Complete the tweener's actions immediately.
  --- @spec #complete(): self
  function ic:complete()
    self.elapsed = self.duration
    self:apply(1)
    return self
  end

  --- @spec #clear(): self
  function ic:clear()
    self.elapsed = 0
    self.duration = 0
    self.dest = nil
    self.to = nil
    self.origin = nil
    self.from = nil
    self.easers = nil
    return self
  end

  --- @spec #reset(): self
  function ic:reset()
    self.elapsed = 0
    self:refresh_origin()
    return self
  end

  --- @spec #refresh_origin(): self
  function ic:refresh_origin()
    self.origin = {}
    for key, value in pairs(self.from) do
      if true == value then
        self.origin[key] = self.dest[key]
      else
        self.origin[key] = value
      end
    end
    return self
  end

  --- Is this tweener done or finished with its work?
  --- @spec #is_done(): Boolean
  function ic:is_done()
    return self.elapsed >= self.duration
  end

  --- Tries to execute the tweener, this will return how much time was actually elapsed.
  --- @spec #run(dtime: Number): Number
  function ic:run(dtime)
    if self.elapsed < self.duration and self.duration > 0 then
      local d = math.min(self.duration - self.elapsed, dtime)
      self.elapsed = math.min(self.elapsed + d, self.duration)
      local r = self.elapsed / self.duration
      self:apply(r)
      return d
    end
    return 0
  end

  --- Standard frame update function for compatability with some update interfaces.
  --- @spec #update(dtime: Number): void
  function ic:update(dtime)
    self:run(dtime)
  end

  --- Applies whatever the easer value should have been at the specific rate, note this ignores
  --- the elapsed and duration.
  --- Args:
  --- * r - a number between 0 and 1, where 0 is the origin and 1 is the `to` values
  --- @spec #apply(r: Number): self
  function ic:apply(r)
    if self.dest then
      local a
      local b
      local bv
      local e
      for k, av in pairs(self.origin) do
        bv = self.to[k]
        e = self.easers[k]
        a = av
        b = bv
        if type(a) == "function" then
          a = a(r)
        end
        if type(b) == "function" then
          b = b(r)
        end
        self.dest[k] = a + (b - a) * e(r)
      end
    end
    return self
  end
end
return Tweener
