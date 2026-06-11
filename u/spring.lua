local Object = require("balm/object")
local DynVector = require("balm/m/dyn_vector")

--- @since "2026.6.11"
--- @class balm.u.Spring
local Spring = Object:extends("balm.u.Spring")
do
  local ic = Spring.instance_class

  --- @override
  --- @spec #initialize(options: Table): void
  function ic:initialize(options)
    options = options or {}
    ic._super.initialize(self)

    --- @member mode: "steering" | "damping"
    self.mode = options.mode or "steering"

    assert(self.mode == "steering" or self.mode == "damping", "expected mode to be steering or damping")

    --- @member max_speed: Number
    self.max_speed = options.max_speed or 350

    --- @member slowing_radius: Number
    self.slowing_radius = options.slowing_radius or 50
    --
    -- steering method
    --
    --- @member max_force: Number
    self.max_force = options.max_force or 15

    --
    -- damping
    --
    --- @member stiffness: Number
    self.stiffness = options.stiffness or 4.0
    --- @member damping: Number
    self.damping = options.damping or 0.95

    --- @member dist_threshold: Number
    self.dist_threshold = options.dist_threshold or 0.1
    --- @member last_dist: Number
    self.last_dist = math.huge

    --- @member current: Number | Table
    self.current = options.current
    --- @member velocity: Number | Table
    self.velocity = options.velocity
    --- @member target: Number | Table
    self:set_target(options.target)
  end

  --- @spec #set_current(current: Number | Table): self
  function ic:set_current(current)
    self.current = current
    return self
  end

  --- @spec #set_target(target: Number | Table): self
  function ic:set_target(target)
    self.target = target
    if type(self.target) == "table" then
      self.d = {}
      self.s = {}
      if not self.velocity then
        self.velocity = {}
        for k, _ in pairs(self.target) do
          self.velocity[k] = 0
        end
      end
    else
      self.d = 0
      self.s = 0
      self.velocity = self.velocity or 0
    end
    return self
  end

  --- Immediately aligns the current with the target and zeroes the velocity.
  --- @spec #solve(): self
  function ic:solve()
    local ty = type(self.target)
    if ty == "table" then
      for k, v in pairs(self.target) do
        self.current[k] = v
        self.velocity[k] = 0
      end
    elseif ty == "number" then
      self.current = self.target
      self.velocity = 0
    end
  end

  --- @spec #is_close(): Boolean
  function ic:is_close()
    return self.last_dist < self.dist_threshold
  end

  --- @spec #update(dtime: Number): void
  function ic:update(dtime)
    self.d = DynVector.subtract(self.d, self.target, self.current)

    self.last_dist = DynVector.magnitude(self.d)
    if self.last_dist < self.dist_threshold then
      self:solve()
      return
    end

    if self.mode == "steering" then
      self:update_steering(dtime)
    else
      self:update_damping(dtime)
    end

    local speed = DynVector.magnitude(self.velocity)
    if speed > self.max_speed then
      self.velocity = DynVector.normalize(self.velocity, self.velocity)
      self.velocity = DynVector.multiply(self.velocity, self.velocity, self.max_speed)
    end
    self.s = DynVector.multiply(self.s, self.velocity, dtime)
    self.current = DynVector.add(self.current, self.current, self.s)
  end

  --- @spec #update_steering(dtime: Number): void
  function ic:update_steering(dtime)
    self.d = DynVector.normalize(self.d, self.d)
    if self.last_dist < self.slowing_radius then
      local speed = self.max_speed * (self.last_dist / self.slowing_radius)
      self.d = DynVector.multiply(self.d, self.d, speed)
    else
      self.d = DynVector.multiply(self.d, self.d, self.max_speed)
    end
    self.s = DynVector.subtract(self.s, self.d, self.velocity)
    local steer_mag = DynVector.magnitude(self.s)
    if steer_mag > self.max_force then
      self.s = DynVector.normalize(self.s, self.s)
      self.s = DynVector.multiply(self.s, self.s, self.max_force)
    end
    self.s = DynVector.multiply(self.s, self.s, dtime)
    self.velocity = DynVector.add(self.velocity, self.velocity, self.s)
  end

  --- @spec #update_damping(dtime: Number): void
  function ic:update_damping(dtime)
    self.s = DynVector.multiply(self.s, self.d, self.stiffness)
    self.s = DynVector.multiply(self.s, self.s, dtime)
    self.velocity = DynVector.add(self.velocity, self.velocity, self.s)
    local current_damping = self.damping ^ (dtime * 60)
    self.velocity = DynVector.multiply(self.velocity, self.velocity, current_damping)
  end
end

return Spring
