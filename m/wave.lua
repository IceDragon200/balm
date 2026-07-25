--- @since "2026.6.2"
--- @namespace balm.m.wave
local m = {}

--- @spec triangle(t: Number): Number
function m.triangle(t)
  return 4 * math.abs(t - 0.5) - 1
end

--- @spec sawtooth(t: Number): Number
function m.sawtooth(t)
  return 2 * t - 1
end

--- @spec square(t: Number, d: Number): Number
function m.square(t, d)
  d = d or 0.5
  return (t < d) and 1 or -1
end

--- Args:
--- * `t`
--- * `o` - Offset/Bias
--- * `a` - Amplitude/Scale
--- * `f` - Frequency
--- * `p` - Phase
--- @spec iqcp(t: Number, o: Number, a: Number, f: Number, p: Number): Number
function m.iqcp(t, o, a, f, p)
  return o + a * math.cos(2 * math.pi * (f * t + p))
end

return m
