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

  --- @spec #clear(): self
  function ic:clear()
    self.tracks = {}
    return self
  end

  --- @spec #new_track(id: ID): self
  function ic:new_track(track_id)
    local deque = Deque:new()
    self.tracks[track_id] = {
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

        if not track.active_item and track.wait <= 0 then
          if not track.deque:is_empty() then
            local type = track.deque:shift()
            if type == "tweener" then
              track.active_item = track.deque:shift()
              track.active_item:reset()
              if track.looped then
                track.deque:push("tweener")
                track.deque:push(track.active_item)
              end
            elseif type == "wait" then
              track.active_item = false
              track.wait = track.deque:shift()
              if track.looped then
                track.deque:push("wait")
                track.deque:push(track.wait)
              end
            else
              error("unexpected type=" .. type)
            end
          end
        end

        if track.active_item then
          e = track.active_item:run(z)
          if e > 0 then
            z = z - e
          else
            break
          end
        elseif track.wait > 0 then
          track.wait = track.wait - z
          if track.wait < 0 then
            z = -track.wait
            track.wait = 0
          else
            z = 0
          end
        else
          break
        end
      end
    end
  end
end
return Timeline
