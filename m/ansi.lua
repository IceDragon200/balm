--- @namespace balm.m.ansi
local m = {}

-- Reference: https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
local ANSI_CODE = {
  bold = "1",
  dim = "2",
  italic = "3",
  underline = "4",
  blinking = "5",
  reverse = "7",
  hidden = "8",
  strikethrough = "9",

  fg = {
    black = "30",
    red = "31",
    green = "32",
    yellow = "33",
    blue = "34",
    magenta = "35",
    cyan = "36",
    white = "37",
    default = "39",

    bright_black = "90",
    bright_red = "91",
    bright_green = "92",
    bright_yellow = "93",
    bright_blue = "94",
    bright_magenta = "95",
    bright_cyan = "96",
    bright_white = "97",
  },

  bg = {
    black = "40",
    red = "41",
    green = "42",
    yellow = "43",
    blue = "44",
    magenta = "45",
    cyan = "46",
    white = "47",
    default = "49",

    bright_black = "100",
    bright_red = "101",
    bright_green = "102",
    bright_yellow = "103",
    bright_blue = "104",
    bright_magenta = "105",
    bright_cyan = "106",
    bright_white = "107",
  },
}

local RESET_ANSI_CODE = {
  bold = "21",
  dim = "22",
  italic = "23",
  underline = "24",
  blinking = "25",
  reverse = "27",
  hidden = "28",
  strikethrough = "29",
}

--- @type ANSIColorName:
---   "black" |
---   "red" |
---   "green" |
---   "yellow" |
---   "blue" |
---   "magenta" |
---   "cyan" |
---   "white" |
---   "default" |
---   "bright_black" |
---   "bright_red" |
---   "bright_green" |
---   "bright_yellow" |
---   "bright_blue" |
---   "bright_magenta" |
---   "bright_cyan" |
---   "bright_white"

--- @type ANSIFormatOptions: {
---   bold: Boolean?,
---   dim: Boolean?,
---   italic: Boolean?,
---   underline: Boolean?,
---   blinking: Boolean?,
---   reverse: Boolean?,
---   hidden: Boolean?,
---   strikethrough: Boolean?,
---   fg: ANSIColorName,
---   bg: ANSIColorName,
--- }

--- @since "0.1.0"
--- @spec ansi_move_cursor_home(): String
function m.ansi_move_cursor_home()
  return "\x1B[H"
end

--- @since "0.1.0"
--- @spec ansi_move_cursor_up(lines: Integer): String
function m.ansi_move_cursor_up(lines)
  return "\x1B[" .. lines .. "A"
end

--- @since "0.1.0"
--- @spec ansi_move_cursor_down(lines: Integer): String
function m.ansi_move_cursor_down(lines)
  return "\x1B[" .. lines .. "B"
end

--- @since "0.1.0"
--- @spec ansi_move_cursor_right(columns: Integer): String
function m.ansi_move_cursor_right(columns)
  return "\x1B[" .. columns .. "C"
end

--- @since "0.1.0"
--- @spec ansi_move_cursor_left(columns: Integer): String
function m.ansi_move_cursor_left(columns)
  return "\x1B[" .. columns .. "D"
end

--- @since "0.1.0"
--- @spec ansi_move_cursor_to(line: Integer, column: Integer): String
function m.ansi_move_cursor_to(line, column)
  return "\x1B[" .. line .. ";" .. column .. "H"
end

--- @since "0.1.0"
--- @spec ansi_clear_line_trailing(): String
function m.ansi_clear_line_trailing()
  return "\x1B[0K"
end

--- @since "0.1.0"
--- @spec ansi_clear_line_leading(): String
function m.ansi_clear_line_leading()
  return "\x1B[1K"
end

--- @since "0.1.0"
--- @spec ansi_clear_line(): String
function m.ansi_clear_line()
  return "\x1B[2K"
end

--- @since "0.1.0"
--- @spec ansi_clear_screen_trailing(): String
function m.ansi_clear_screen_trailing()
  return "\x1B[0J"
end

--- @since "0.1.0"
--- @spec ansi_clear_screen_leading(): String
function m.ansi_clear_screen_leading()
  return "\x1B[1J"
end

--- @since "0.1.0"
--- @spec ansi_clear_screen(): String
function m.ansi_clear_screen()
  return "\x1B[2J"
end

--- @since "0.1.0"
--- @spec ansi_format_start(ANSIFormatOptions): String
function m.ansi_format_start(options)
  local codes = {}
  local code
  local sub

  for name, value in pairs(options) do
    if value == true then
      code = ANSI_CODE[name]
      if code then
        table.insert(codes, code)
      else
        error("unexpected key=" .. name)
      end
    elseif value == false then
      code = RESET_ANSI_CODE[name]
      if code then
        table.insert(codes, code)
      else
        error("unexpected key=" .. name)
      end
    else
      sub = ANSI_CODE[name]
      if type(sub == "table") then
        code = sub[value]
        if type(code) == "string" then
          table.insert(codes, code)
        else
          error("unexpected subkey=" .. value)
        end
      else
        error("unexpected key=" .. name)
      end
    end
  end

  return "\x1B[" .. table.concat(codes, ";") .. "m"
end

--- @since "0.1.0"
--- @spec ansi_format_end(): String
function m.ansi_format_end()
  return "\x1B[0m"
end

--- @since "0.1.0"
--- @spec ansi_format(inner: String, options: ANSIFormatOptions): String
function m.ansi_format(inner, options)
  return m.ansi_format_start(options) .. inner .. m.ansi_format_end()
end

--- @since "2024.7.23"
--- @spec ansi_format_lazy(inner: Function/0, options: ANSIFormatOptions): String
function m.ansi_format_lazy(callback, options)
  return m.ansi_format_start(options) .. callback() .. m.ansi_format_end()
end

return m
