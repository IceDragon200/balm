local Object = require("balm/object")
local Deque = require("balm/s/deque")
local Tweener = require("balm/u/tweener")

--- @namespace balm.u

--- @since "2026.6.4"
--- @class Timeline
local Timeline = Object:extends("balm.u.Timeline")
do
  local ic = Timeline.instance_class

  --- @override
  --- @spec #initialize(): void
  function ic:initialize()
    ic._super.initialize(self)

    --- @spec tracks: Record<ID, Deque>
    self.tracks = {}
  end

  --- @spec #initialize_copy(other: Timeline): void
  function ic:initialize_copy(other)
    ic._super.initialize_copy(self, other)
    self.tracks = {}
    for key, track in pairs(other.tracks) do
      self.tracks[key] = {
        elapsed = track.elapsed,
        looped = track.looped,
        wait = track.wait,
        active_item = track.active_item,
        deque = track.deque:copy(),
      }
    end
  end

  --- @spec #clear(): self
  function ic:clear()
    self.tracks = {}
    return self
  end

  --- @spec #new_track(id: ID): self
  function ic:new_track(track_id)
    local deque = Deque:new()
    self.tracks[track_id] = {
      elapsed = 0,
      looped = false,
      wait = 0,
      active_item = false,
      deque = deque,
    }
    return self
  end

  --- @spec #set_track_loop(track_id: ID, state: Boolean): self
  function ic:set_track_loop(track_id, state)
    local track = self.tracks[track_id]
    if track then
      track.looped = state
    end
    return self
  end

  --- @spec #complete_track(track_id: ID): self
  function ic:complete_track(track_id)
    local track = self.tracks[track_id]
    if track then
      if not track.looped then
        track.elapsed = track.elapsed + track.wait
        track.wait = 0
        if track.active_item then
          track.active_item:complete()
          track.elapsed = track.elapsed + track.active_item:calc_remaining_time()
          track.active_item = false
        end
        local ty
        while not track.deque:is_empty() do
          ty = track.deque:shift()
          if "tweener" == ty then
            -- shift and immediately complete the tweener
            local tweener = track.deque:shift()
            tweener:reset()
            track.elapsed = track.elapsed + tweener:calc_remaining_time()
            tweener:complete()
          elseif "wait" == ty then
            track.elapsed = track.elapsed + track.deque:shift() -- drop the wait
          elseif "callback" == ty then
            track.deque:shift()(track_id, track.elapsed)
          else
            error("unexpected type=" .. ty)
          end
        end
      end
    end
    return self
  end

  --- @spec #remove_track(id: ID): self
  function ic:remove_track(track_id)
    self.tracks[track_id] = nil
  end

  --- @spec #add_tween(track_id: ID, dest: Table, duration: Number, to: Table, from?: Table, easers?: Table): self
  function ic:add_tween(track_id, dest, duration, to, from, easers)
    local track = self.tracks[track_id]
    if track then
      track.deque:push("tweener")
      track.deque:push(Tweener:new(dest, duration, to, from, easers))
    else
      error("no such track id=" .. track_id)
    end
    return self
  end

  --- @spec #add_wait(track_id: ID, duration: Number): self
  function ic:add_wait(track_id, duration)
    local track = self.tracks[track_id]
    if track then
      track.deque:push("wait")
      track.deque:push(duration)
    else
      error("no such track id=" .. track_id)
    end
    return self
  end

  --- @since "2026.6.5"
  --- @spec #add_callback(track_id: ID, callback: Function/1): self
  function ic:add_callback(track_id, callback)
    local track = self.tracks[track_id]
    if track then
      track.deque:push("callback")
      track.deque:push(callback)
    else
      error("no such track id=" .. track_id)
    end
    return self
  end

  --- @spec #is_track_empty(track_id: ID): Boolean
  function ic:is_track_empty(track_id)
    local track = self.tracks[track_id]
    if track then
      if track.active_item then
        return false
      end

      return track.deque:is_empty()
    end
    return true
  end

  --- @spec #update(dtime: Number): void
  function ic:update(dtime)
    local z
    local e
    for track_id, track in pairs(self.tracks) do
      z = dtime
      while z > 0 do
        if track.active_item and track.active_item:is_done() then
          track.active_item = false
        end

        if track.wait > 0 then
          track.elapsed = track.elapsed + math.min(track.wait, z)
          track.wait = track.wait - z
          if track.wait < 0 then
            z = -track.wait
            track.wait = 0
          else
            z = 0
          end
        elseif not track.active_item then
          if track.deque:is_empty() then
            break
          else
            local ty = track.deque:shift()
            if "tweener" == ty then
              track.active_item = track.deque:shift()
              track.active_item:reset()
              if track.looped then
                track.deque:push("tweener")
                track.deque:push(track.active_item)
              end
            elseif "wait" == ty then
              track.active_item = false
              track.wait = track.deque:shift()
              if track.looped then
                track.deque:push("wait")
                track.deque:push(track.wait)
              end
            elseif "callback" == ty then
              track.active_item = false
              track.wait = 0
              local cb = track.deque:shift()
              cb(track_id, track.elapsed)
              if track.looped then
                track.deque:push("callback")
                track.deque:push(cb)
              end
            else
              error("unexpected type=" .. ty)
            end
          end
        elseif track.active_item then
          e = track.active_item:run(z)
          if e > 0 then
            track.elapsed = track.elapsed + e
            z = z - e
          else
            break
          end
        else
          break
        end
      end
    end
  end
end
return Timeline
