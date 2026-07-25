local Rect = require("balm/m/rect")
local SpriteBatch = require("balm/k/love2d/sprite_batch")
local M = require("balm/u/tiler")
local Luna = require("balm/luna")
local floor = assert(math.floor)

local case = Luna:new("balm.u.Tiler")

if rawget(_G, "love") and love.graphics then
  case:describe("#add_component/3", function (t2)
    t2:test("can add a component to a Tiler object", function (t3)
      local s = M:new()

      s:add_component("win16", "3x3", Rect.new(0, 0, 48, 48), 64, 96)

      for vanity_id, component in pairs(s.components) do
        t3:assert_eq(vanity_id, "win16")

        t3:assert_matches(component, {
          src_rect = { x = 0, y = 0, w = 48, h = 48 },
          layout = "3x3",
          texture_w = 64,
          texture_h = 96,
          layouts = {
            ["3x3"] = {
              cols = 3,
              rows = 3,
              cw = 16,
              ch = 16,
            },
            ["6x6"] = {
              cols = 6,
              rows = 6,
              cw = 8,
              ch = 8,
            },
          }
        })

        for layout_id, layout in pairs(component.layouts) do
          local quads = layout.quads
          for i = 1,layout.rows*layout.cols do
            local i0 = i - 1
            local qx, qy, qw, qh = quads[i]:getViewport()
            t3:assert_eq(qx, (i0 % layout.cols) * layout.cw)
            t3:assert_eq(qy, floor(i0 / layout.cols) * layout.ch)
            t3:assert_eq(qw, layout.cw)
            t3:assert_eq(qh, layout.ch)
          end
        end
      end
    end)
  end)

  case:describe("#build_component/3", function (t2)
    t2:test("can build a component standard 9-slice", function (t3)
      local sb = SpriteBatch:new()

      local s = M:new()

      s:add_component("win16", "3x3", Rect.new(0, 0, 48, 48), 48, 48)

      s:build_component(sb, Rect.new(0, 0, 48, 48), {
        base = "win16"
      }, nil, {})

      -- Top
      local item = sb:get(1)
      local qx, qy, qw, qh = item.quad:getViewport()
      t3:assert_eq(qx, 0)
      t3:assert_eq(qy, 0)
      t3:assert_eq(qw, 16)
      t3:assert_eq(qh, 16)
      t3:assert_matches(item, {
        x = 0,
        y = 0,
      })

      item = sb:get(2)
      qx, qy, qw, qh = item.quad:getViewport()
      t3:assert_eq(qx, 16)
      t3:assert_eq(qy, 0)
      t3:assert_eq(qw, 16)
      t3:assert_eq(qh, 16)
      t3:assert_matches(item, {
        x = 16,
        y = 0,
      })

      item = sb:get(3)
      qx, qy, qw, qh = item.quad:getViewport()
      t3:assert_eq(qx, 32)
      t3:assert_eq(qy, 0)
      t3:assert_eq(qw, 16)
      t3:assert_eq(qh, 16)
      t3:assert_matches(item, {
        x = 32,
        y = 0,
      })

      -- Middle
      item = sb:get(4)
      qx, qy, qw, qh = item.quad:getViewport()
      t3:assert_eq(qx, 0)
      t3:assert_eq(qy, 16)
      t3:assert_eq(qw, 16)
      t3:assert_eq(qh, 16)
      t3:assert_matches(item, {
        x = 0,
        y = 16,
      })

      item = sb:get(5)
      qx, qy, qw, qh = item.quad:getViewport()
      t3:assert_eq(qx, 16)
      t3:assert_eq(qy, 16)
      t3:assert_eq(qw, 16)
      t3:assert_eq(qh, 16)
      t3:assert_matches(item, {
        x = 16,
        y = 16,
      })

      item = sb:get(6)
      qx, qy, qw, qh = item.quad:getViewport()
      t3:assert_eq(qx, 32)
      t3:assert_eq(qy, 16)
      t3:assert_eq(qw, 16)
      t3:assert_eq(qh, 16)
      t3:assert_matches(item, {
        x = 32,
        y = 16,
      })

      -- Bottom
      item = sb:get(7)
      qx, qy, qw, qh = item.quad:getViewport()
      t3:assert_eq(qx, 0)
      t3:assert_eq(qy, 32)
      t3:assert_eq(qw, 16)
      t3:assert_eq(qh, 16)
      t3:assert_matches(item, {
        x = 0,
        y = 32,
      })

      item = sb:get(8)
      qx, qy, qw, qh = item.quad:getViewport()
      t3:assert_eq(qx, 16)
      t3:assert_eq(qy, 32)
      t3:assert_eq(qw, 16)
      t3:assert_eq(qh, 16)
      t3:assert_matches(item, {
        x = 16,
        y = 32,
      })

      item = sb:get(9)
      qx, qy, qw, qh = item.quad:getViewport()
      t3:assert_eq(qx, 32)
      t3:assert_eq(qy, 32)
      t3:assert_eq(qw, 16)
      t3:assert_eq(qh, 16)
      t3:assert_matches(item, {
        x = 32,
        y = 32,
      })
    end)
  end)
end

case:execute()
case:display_stats()
case:maybe_error()
