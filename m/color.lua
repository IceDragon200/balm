--- @namespace balm.m.color
local hex_encoding = require("balm/m/string/hex_encoding")
local btable = require("balm/m/table")

local byte_to_hexpair = assert(hex_encoding.byte_to_hexpair)
local hexpair_to_byte = assert(hex_encoding.hex_pair_to_byte)
local nibble_to_hex = assert(hex_encoding.nibble_to_hex)
local table_freeze = assert(btable.freeze)

local function hexpair_to_color_value(hexpair)
  return hexpair_to_byte(hexpair) / 255.0
end

local function hex_to_color_value(hex)
  return hexpair_to_byte(hex .. hex) / 255.0
end

local Color = {

}

--- @type Byte: 0..255

--- @type Color: {
---   r: Float,
---   g: Float,
---   b: Float,
---   a: Float,
--- }

local function color_channel_clamp(a)
  return math.max(math.min(a, 1), 0)
end

local function channel_overlay(a, b)
  local r
  local n = a
  local n2 = b

  if n < 0.5 then
    r = 2 * (n * n2)
  else
    r = 1 - 2 * (1 - n) * (1 - n2)
  end

  return color_channel_clamp(r)
end

local function channel_hard_light(a, b)
  local r
  local n = a
  local n2 = b

  if n2 < 0.5 then
    r = 2 * (n * n2)
  else
    r = 1 - 2 * (1 - n) * (1 - n2)
  end

  return color_channel_clamp(r)
end

---
--- @spec new(r: Float, g: Float, b: Float, a?: Float): Color
function Color.new(r, g, b, a)
  return { r = r, g = g, b = b, a = a or 1.0 }
end

--- @spec copy(Color): Color
function Color.copy(color)
  return new(
    color.r,
    color.g,
    color.b,
    color.a
  )
end

--- @spec lerp(d: Color, a: Color, b: Color, d: Number): Color
function Color.lerp(d, a, b, delta)
  d.r = color_channel_clamp(a.r + (b.r - a.r) * delta)
  d.g = color_channel_clamp(a.g + (b.g - a.g) * delta)
  d.b = color_channel_clamp(a.b + (b.b - a.b) * delta)
  d.a = color_channel_clamp(a.a + (b.a - a.a) * delta)
  return d
end

--- @spec add(Color, Color, Color): Color
function Color.add(d, a, b)
  d.r = color_channel_clamp((a.r * a.a) + (b.r * b.a))
  d.g = color_channel_clamp((a.g * a.a) + (b.g * b.a))
  d.b = color_channel_clamp((a.b * a.a) + (b.b * b.a))
  d.a = 1.0
  return d
end

--- @spec sub(Color, Color): Color
function Color.sub(a, b)
  d.r = color_channel_clamp((a.r * a.a) - (b.r * b.a))
  d.g = color_channel_clamp((a.g * a.a) - (b.g * b.a))
  d.b = color_channel_clamp((a.b * a.a) - (b.b * b.a))
  d.a = 1.0
  return d
end

--- @spec mult(Color, Color): Color
function Color.mult(d, a, b)
  d.r = color_channel_clamp((a.r * a.a) * (b.r * b.a))
  d.g = color_channel_clamp((a.g * a.a) * (b.g * b.a))
  d.b = color_channel_clamp((a.b * a.a) * (b.b * b.a))
  d.a = 1.0
  return d
end

--- @spec blend_overlay(d: Color, Color, Color): Color
function Color.blend_overlay(d, a, b)
  d.r = channel_overlay(a.r, b.r)
  d.g = channel_overlay(a.g, b.g)
  d.b = channel_overlay(a.b, b.b)
  d.a = color_channel_clamp(a.a * b.a)
  return d
end

--- @spec blend_hard_light(d: Color, Color, Color): Color
function Color.blend_hard_light(d, a, b)
  d.r = channel_hard_light(a.r, b.r)
  d.g = channel_hard_light(a.g, b.g)
  d.b = channel_hard_light(a.b, b.b)
  d.a = color_channel_clamp(a.a * b.a)
  return d
end

--- @spec blend_multiply(Color, Color): Color
function Color.blend_multiply(d, a, b)
  d.r = color_channel_clamp(a.r * b.r)
  d.g = color_channel_clamp(a.g * b.g)
  d.b = color_channel_clamp(a.b * b.b)
  d.a = color_channel_clamp(a.a * b.a)
  return d
end

--- @spec to_grayscale_value(Color): Integer
function Color.to_grayscale_value(color)
  return color_channel_clamp(0.299 * color.r + 0.587 * color.g + 0.114 * color.b)
end

--- @spec to_grayscale(Color): Color
function Color.to_grayscale(color)
  local y = Color.to_grayscale_value(color)
  return Color.new(y, y, y)
end

--- @spec to_string32(Color): String
function Color.to_string32(color)
  local result = "#" ..
    byte_to_hexpair(color.r) ..
    byte_to_hexpair(color.g) ..
    byte_to_hexpair(color.b) ..
    byte_to_hexpair(color.a)

  return result
end

--- @spec to_string24(Color): String
function Color.to_string24(color)
  local result = "#" ..
    byte_to_hexpair(color.r) ..
    byte_to_hexpair(color.g) ..
    byte_to_hexpair(color.b)

  return result
end

--- @spec to_string16(Color): String
function Color.to_string16(color)
  local result = "#" ..
    nibble_to_hex(math.floor(color.r * 16)) ..
    nibble_to_hex(math.floor(color.g * 16)) ..
    nibble_to_hex(math.floor(color.b * 16)) ..
    nibble_to_hex(math.floor(color.a * 16))

  return result
end

--- @spec to_string12(Color): String
function Color.to_string12(color)
  local result = "#" ..
    nibble_to_hex(math.floor(color.r * 16)) ..
    nibble_to_hex(math.floor(color.g * 16)) ..
    nibble_to_hex(math.floor(color.b * 16))

  return result
end

--- @spec from_rgb24(r: Byte, g: Byte, b: Byte): Color
function Color.from_rgb24(r, g, b)
  return Color.new(
    color_channel_clamp(r / 255.0),
    color_channel_clamp(g / 255.0),
    color_channel_clamp(b / 255.0)
  )
end

--- Converts the given colorstring into a Color table or nil if it was named but doesn't exist.
---
--- @spec from_colorstring(colorstring: String): Color | nil
function Color.from_colorstring(colorstring)
  if colorstring:sub(1, 1) == "#" then
    local rest = colorstring:sub(2)

    local len = #rest
    local r
    local g
    local b
    local a

    if len == 3 then
      -- RGB
      r = hex_to_color_value(rest:sub(1, 1))
      g = hex_to_color_value(rest:sub(2, 2))
      b = hex_to_color_value(rest:sub(3, 3))
      a = 1
    elseif len == 4 then
      -- RGBA
      r = hex_to_color_value(rest:sub(1, 1))
      g = hex_to_color_value(rest:sub(2, 2))
      b = hex_to_color_value(rest:sub(3, 3))
      a = hex_to_color_value(rest:sub(4, 4))
    elseif len == 6 then
      -- RRGGBB
      r = hexpair_to_color_value(rest:sub(1, 2))
      g = hexpair_to_color_value(rest:sub(3, 4))
      b = hexpair_to_color_value(rest:sub(5, 6))
      a = 1
    elseif len == 8 then
      -- RRGGBBAA
      r = hexpair_to_color_value(rest:sub(1, 2))
      g = hexpair_to_color_value(rest:sub(3, 4))
      b = hexpair_to_color_value(rest:sub(5, 6))
      a = hexpair_to_color_value(rest:sub(7, 8))
    else
      error("invalid colorstring=" .. colorstring)
    end

    return {
      r = r,
      g = g,
      b = b,
      a = a
    }
  else
    local idx = colorstring:find("#")
    local name = colorstring
    local alpha = 1

    if idx then
      name = colorstring:sub(1, idx - 1)
      alpha = hexpair_to_color_value(colorstring:sub(idx, #colorstring))
    end

    local color = Color.NAMED[name]

    if color then
      color = Color.copy(color)
      color.a = alpha
      return color
    else
      return nil
    end
  end
end

---
--- Takes any value and may or may not return a valid color string.
---
--- @exception
--- @spec maybe_to_colorstring(value: Any): String
function Color.maybe_to_colorstring(value)
  if type(value) == "string" then
    return value
  elseif type(value) == "table" then
    if value.a then
      return Color.to_string32(value)
    else
      return Color.to_string24(value)
    end
  else
    error("unexpected color value=" .. dump(value))
  end
end

--- @exception
--- @spec maybe_to_color(value: String | Table | Color): Color
function Color.maybe_to_color(value)
  if type(value) == "string" then
    return Color.from_colorstring(value)
  elseif type(value) == "table" then
    assert(value.r and value.g and value.b and value.a)
    return value
  else
    error("unexpected value=" .. dump(value))
  end
end

-- https://www.w3.org/TR/css-color-4/#named-color
Color.NAMED = {
  aliceblue =            Color.from_rgb24(240, 248, 255),
  antiquewhite =         Color.from_rgb24(250, 235, 215),
  aqua =                 Color.from_rgb24(0, 255, 255),
  aquamarine =           Color.from_rgb24(127, 255, 212),
  azure =                Color.from_rgb24(240, 255, 255),
  beige =                Color.from_rgb24(245, 245, 220),
  bisque =               Color.from_rgb24(255, 228, 196),
  black =                Color.from_rgb24(0, 0, 0),
  blanchedalmond =       Color.from_rgb24(255, 235, 205),
  blue =                 Color.from_rgb24(0, 0, 255),
  blueviolet =           Color.from_rgb24(138, 43, 226),
  brown =                Color.from_rgb24(165, 42, 42),
  burlywood =            Color.from_rgb24(222, 184, 135),
  cadetblue =            Color.from_rgb24(95, 158, 160),
  chartreuse =           Color.from_rgb24(127, 255, 0),
  chocolate =            Color.from_rgb24(210, 105, 30),
  coral =                Color.from_rgb24(255, 127, 80),
  cornflowerblue =       Color.from_rgb24(100, 149, 237),
  cornsilk =             Color.from_rgb24(255, 248, 220),
  crimson =              Color.from_rgb24(220, 20, 60),
  cyan =                 Color.from_rgb24(0, 255, 255),
  darkblue =             Color.from_rgb24(0, 0, 139),
  darkcyan =             Color.from_rgb24(0, 139, 139),
  darkgoldenrod =        Color.from_rgb24(184, 134, 11),
  darkgray =             Color.from_rgb24(169, 169, 169),
  darkgreen =            Color.from_rgb24(0, 100, 0),
  darkgrey =             Color.from_rgb24(169, 169, 169),
  darkkhaki =            Color.from_rgb24(189, 183, 107),
  darkmagenta =          Color.from_rgb24(139, 0, 139),
  darkolivegreen =       Color.from_rgb24(85, 107, 47),
  darkorange =           Color.from_rgb24(255, 140, 0),
  darkorchid =           Color.from_rgb24(153, 50, 204),
  darkred =              Color.from_rgb24(139, 0, 0),
  darksalmon =           Color.from_rgb24(233, 150, 122),
  darkseagreen =         Color.from_rgb24(143, 188, 143),
  darkslateblue =        Color.from_rgb24(72, 61, 139),
  darkslategray =        Color.from_rgb24(47, 79, 79),
  darkslategrey =        Color.from_rgb24(47, 79, 79),
  darkturquoise =        Color.from_rgb24(0, 206, 209),
  darkviolet =           Color.from_rgb24(148, 0, 211),
  deeppink =             Color.from_rgb24(255, 20, 147),
  deepskyblue =          Color.from_rgb24(0, 191, 255),
  dimgray =              Color.from_rgb24(105, 105, 105),
  dimgrey =              Color.from_rgb24(105, 105, 105),
  dodgerblue =           Color.from_rgb24(30, 144, 255),
  firebrick =            Color.from_rgb24(178, 34, 34),
  floralwhite =          Color.from_rgb24(255, 250, 240),
  forestgreen =          Color.from_rgb24(34, 139, 34),
  fuchsia =              Color.from_rgb24(255, 0, 255),
  gainsboro =            Color.from_rgb24(220, 220, 220),
  ghostwhite =           Color.from_rgb24(248, 248, 255),
  gold =                 Color.from_rgb24(255, 215, 0),
  goldenrod =            Color.from_rgb24(218, 165, 32),
  gray =                 Color.from_rgb24(128, 128, 128),
  green =                Color.from_rgb24(0, 128, 0),
  greenyellow =          Color.from_rgb24(173, 255, 47),
  grey =                 Color.from_rgb24(128, 128, 128),
  honeydew =             Color.from_rgb24(240, 255, 240),
  hotpink =              Color.from_rgb24(255, 105, 180),
  indianred =            Color.from_rgb24(205, 92, 92),
  indigo =               Color.from_rgb24(75, 0, 130),
  ivory =                Color.from_rgb24(255, 255, 240),
  khaki =                Color.from_rgb24(240, 230, 140),
  lavender =             Color.from_rgb24(230, 230, 250),
  lavenderblush =        Color.from_rgb24(255, 240, 245),
  lawngreen =            Color.from_rgb24(124, 252, 0),
  lemonchiffon =         Color.from_rgb24(255, 250, 205),
  lightblue =            Color.from_rgb24(173, 216, 230),
  lightcoral =           Color.from_rgb24(240, 128, 128),
  lightcyan =            Color.from_rgb24(224, 255, 255),
  lightgoldenrodyellow = Color.from_rgb24(250, 250, 210),
  lightgray =            Color.from_rgb24(211, 211, 211),
  lightgreen =           Color.from_rgb24(144, 238, 144),
  lightgrey =            Color.from_rgb24(211, 211, 211),
  lightpink =            Color.from_rgb24(255, 182, 193),
  lightsalmon =          Color.from_rgb24(255, 160, 122),
  lightseagreen =        Color.from_rgb24(32, 178, 170),
  lightskyblue =         Color.from_rgb24(135, 206, 250),
  lightslategray =       Color.from_rgb24(119, 136, 153),
  lightslategrey =       Color.from_rgb24(119, 136, 153),
  lightsteelblue =       Color.from_rgb24(176, 196, 222),
  lightyellow =          Color.from_rgb24(255, 255, 224),
  lime =                 Color.from_rgb24(0, 255, 0),
  limegreen =            Color.from_rgb24(50, 205, 50),
  linen =                Color.from_rgb24(250, 240, 230),
  magenta =              Color.from_rgb24(255, 0, 255),
  maroon =               Color.from_rgb24(128, 0, 0),
  mediumaquamarine =     Color.from_rgb24(102, 205, 170),
  mediumblue =           Color.from_rgb24(0, 0, 205),
  mediumorchid =         Color.from_rgb24(186, 85, 211),
  mediumpurple =         Color.from_rgb24(147, 112, 219),
  mediumseagreen =       Color.from_rgb24(60, 179, 113),
  mediumslateblue =      Color.from_rgb24(123, 104, 238),
  mediumspringgreen =    Color.from_rgb24(0, 250, 154),
  mediumturquoise =      Color.from_rgb24(72, 209, 204),
  mediumvioletred =      Color.from_rgb24(199, 21, 133),
  midnightblue =         Color.from_rgb24(25, 25, 112),
  mintcream =            Color.from_rgb24(245, 255, 250),
  mistyrose =            Color.from_rgb24(255, 228, 225),
  moccasin =             Color.from_rgb24(255, 228, 181),
  navajowhite =          Color.from_rgb24(255, 222, 173),
  navy =                 Color.from_rgb24(0, 0, 128),
  oldlace =              Color.from_rgb24(253, 245, 230),
  olive =                Color.from_rgb24(128, 128, 0),
  olivedrab =            Color.from_rgb24(107, 142, 35),
  orange =               Color.from_rgb24(255, 165, 0),
  orangered =            Color.from_rgb24(255, 69, 0),
  orchid =               Color.from_rgb24(218, 112, 214),
  palegoldenrod =        Color.from_rgb24(238, 232, 170),
  palegreen =            Color.from_rgb24(152, 251, 152),
  paleturquoise =        Color.from_rgb24(175, 238, 238),
  palevioletred =        Color.from_rgb24(219, 112, 147),
  papayawhip =           Color.from_rgb24(255, 239, 213),
  peachpuff =            Color.from_rgb24(255, 218, 185),
  peru =                 Color.from_rgb24(205, 133, 63),
  pink =                 Color.from_rgb24(255, 192, 203),
  plum =                 Color.from_rgb24(221, 160, 221),
  powderblue =           Color.from_rgb24(176, 224, 230),
  purple =               Color.from_rgb24(128, 0, 128),
  rebeccapurple =        Color.from_rgb24(102, 51, 153),
  red =                  Color.from_rgb24(255, 0, 0),
  rosybrown =            Color.from_rgb24(188, 143, 143),
  royalblue =            Color.from_rgb24(65, 105, 225),
  saddlebrown =          Color.from_rgb24(139, 69, 19),
  salmon =               Color.from_rgb24(250, 128, 114),
  sandybrown =           Color.from_rgb24(244, 164, 96),
  seagreen =             Color.from_rgb24(46, 139, 87),
  seashell =             Color.from_rgb24(255, 245, 238),
  sienna =               Color.from_rgb24(160, 82, 45),
  silver =               Color.from_rgb24(192, 192, 192),
  skyblue =              Color.from_rgb24(135, 206, 235),
  slateblue =            Color.from_rgb24(106, 90, 205),
  slategray =            Color.from_rgb24(112, 128, 144),
  slategrey =            Color.from_rgb24(112, 128, 144),
  snow =                 Color.from_rgb24(255, 250, 250),
  springgreen =          Color.from_rgb24(0, 255, 127),
  steelblue =            Color.from_rgb24(70, 130, 180),
  tan =                  Color.from_rgb24(210, 180, 140),
  teal =                 Color.from_rgb24(0, 128, 128),
  thistle =              Color.from_rgb24(216, 191, 216),
  tomato =               Color.from_rgb24(255, 99, 71),
  turquoise =            Color.from_rgb24(64, 224, 208),
  violet =               Color.from_rgb24(238, 130, 238),
  wheat =                Color.from_rgb24(245, 222, 179),
  white =                Color.from_rgb24(255, 255, 255),
  whitesmoke =           Color.from_rgb24(245, 245, 245),
  yellow =               Color.from_rgb24(255, 255, 0),
  yellowgreen =          Color.from_rgb24(154, 205, 50),
}

for name, color in pairs(Color.NAMED) do
  -- prevent the color from being modified
  table_freeze(color)
end

return Color
