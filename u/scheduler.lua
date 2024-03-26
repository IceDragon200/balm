---
--- Allows running tasks, over a period of time, or during a period
---
local Tweener = lily_core:require("util/tweener")

local Scheduler = lily.Object:extends("Scheduler")
local ic = Scheduler.instance_class

function ic:initialize()
  self._super.initialize(self)
  self.timer_id = 0
  self.timers = {}
  self.dead_timers = {}
end

function ic:is_busy()
  for _,_ in pairs(self.timers) do
    return true
  end
  return false
end

function ic:has_timer(timer_id)
  if self.timers[timer_id] then
    return true
  end
  return false
end

function ic:on_timer_done(timer_id, done_fun)
  self.timers[timer_id].on_done = done_fun
  return self
end

function ic:get_timer(timer_id)
  return self.timers[timer_id]
end

function ic:remove_timer(timer_id)
  self.timers[timer_id] = nil
  return self
end

-- Calls the fun after duration, the timer is removed afterwards
-- @spec set_timeout(non_neg_integer, (t) => void)
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

-- Calls the fun every duration, the timer is reset each time
-- @spec set_interval(non_neg_integer, (t) => void)
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

-- Calls the given fun every frame for duration, the timer is removed once it reaches 0
-- @spec set_duration(non_neg_integer, (t) => void)
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

-- @spec tween(integer, table, table, table, string | (float) => float) :: integer
function ic:tween(duration, object, from, to, easer)
  return self:set_duration(duration, Tweener.new(object, from, to, easer))
end

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

return Scheduler
