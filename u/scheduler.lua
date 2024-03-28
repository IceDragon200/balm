---
--- Allows running tasks, over a period of time, or during a period
---
local easers = require("balm/m/easers")
local Object = require("balm/object")

--- @namespace balm

--- @type TimerID: String

--- @class Scheduler
local Scheduler = Object:extends("balm.Scheduler")
do
  local ic = Scheduler.instance_class

  --- @spec #initialize(): void
  function ic:initialize()
    self._super.initialize(self)
    self.timer_id = 0
    self.timers = {}
    self.dead_timers = {}
  end

  --- @spec #is_busy(): Boolean
  function ic:is_busy()
    return next(self.timers) ~= nil
  end

  --- @spec #has_timer(timer_id: TimerID): Boolean
  function ic:has_timer(timer_id)
    if self.timers[timer_id] then
      return true
    end
    return false
  end

  --- @spec #on_timer_done(timer_id: TimerID, done_fun: Function): self
  function ic:on_timer_done(timer_id, done_fun)
    self.timers[timer_id].on_done = done_fun
    return self
  end

  --- @spec #get_timer(timer_id: TimerID): Timer
  function ic:get_timer(timer_id)
    return self.timers[timer_id]
  end

  --- @spec #remove_timer(timer_id: TimerID): self
  function ic:remove_timer(timer_id)
    self.timers[timer_id] = nil
    return self
  end

  --- Calls the fun after duration, the timer is removed afterwards
  ---
  --- @spec #set_timeout(non_neg_integer, (t) => void): TimerID
  function ic:set_timeout(time, fun)
    self.timer_id = self.timer_id + 1
    self.timers[self.timer_id] = {
      type = "timeout",
      time = time,
      time_max = time,
      fun = fun,
    }
    return self.timer_id
  end

  --- Calls the fun every duration, the timer is reset each time
  ---
  --- @spec #set_interval(non_neg_integer, (t) => void): TimerID
  function ic:set_interval(time, fun)
    self.timer_id = self.timer_id + 1
    self.timers[self.timer_id] = {
      type = "interval",
      time = time,
      time_max = time,
      fun = fun,
    }
    return self.timer_id
  end

  --- Calls the given fun every frame for duration, the timer is removed once it reaches 0
  ---
  --- @spec set_duration(non_neg_integer, (t) => void): TimerID
  function ic:set_duration(time, fun)
    self.timer_id = self.timer_id + 1
    self.timers[self.timer_id] = {
      type = "duration",
      time = time,
      time_max = time,
      fun = fun,
    }
    return self.timer_id
  end

  --- @spec #tween(
  ---   duration: Integer,
  ---   object: Table,
  ---   from: Table,
  ---   to: Table,
  ---   easer: String | (float) => float
  --- ): TimerID
  function ic:tween(duration, object, from, to, easer)
    return self:set_duration(duration, self:make_tweener(object, from, to, easer))
  end

  --- @spec #make_tweener(
  ---   object: Table,
  ---   from: Table,
  ---   to: Table,
  ---   easer: String | Function/1
  --- ): Function/1
  function ic:make_tweener(object, from, to, easer)
    local ease
    if type(easer) == "function" then
      ease = easer
    else
      ease = assert(easers[easer], "expected an easer function")
    end

    return function (t)
      local b
      local d
      for key,a in pairs(from) do
        b = to[key]
        d = b - a
        object[key] = a + d * ease(t)
      end
    end
  end

  --- @spec #update(dt: Float): void
  function ic:update(dt)
    for timer_id, timer in pairs(self.timers) do
      if timer.type == "timeout" then
        if timer.time > 0 then
          timer.time = timer.time - dt
        end
        if timer.time <= 0 then
          timer.fun(1)
          self.dead_timers[timer_id] = timer
        end
      elseif timer.type == "interval" then
        if timer.time > 0 then
          timer.time = timer.time - dt
        end
        if timer.time <= 0 then
          timer.fun(1)
          timer.time = timer.time_max
        end
      elseif timer.type == "duration" then
        if timer.time > 0 then
          timer.time = timer.time - dt
        end
        timer.fun(1 - timer.time / timer.time_max)
        if timer.time <= 0 then
          self.dead_timers[timer_id] = timer
          if timer.on_done then
            timer.on_done()
          end
        end
      end
    end

    local had_dead_timer = false
    for timer_id, _timer in pairs(self.dead_timers) do
      had_dead_timer = true
      self.timers[timer_id] = nil
    end

    if had_dead_timer then
      self.dead_timers = {}
    end
  end
end

return Scheduler
