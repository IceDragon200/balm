local assertions = require("balm/m/assertions")
local Object = require("balm/object")
local Rect = require("balm/m/rect")
local WindowSkin = require("balm/u/window_skin")
local floor = assert(math.floor)

--- @type Layout = "1x1" | "1x3" | "3x1" | "3x3" | "6x6" | "border" | "horz" | "vert"

--- Modern version of WindowSkin, allows more advanced operations such as tile swapping.
--- @since "2026.6.11"
--- @class Tiler
local Tiler = Object:extends("balm.u.Tiler")
do
  local ic = Tiler.instance_class

  local function resize_quad(quad, nw, nh)
    local tw, th = quad:getTextureDimensions()
    local sx, sy, sw, sh = quad:getViewport()
    if (nw and nw ~= sw) or (nh and nh ~= sh) then
      return love.graphics.newQuad(sx, sy, nw or sw, nh or sh, tw, th)
    else
      return quad
    end
  end

  local function translate_quad(quad, nx, ny)
    local tw, th = quad:getTextureDimensions()
    local sx, sy, sw, sh = quad:getViewport()
    return love.graphics.newQuad(sx + nx, sy + ny, nw or sw, nh or sh, tw, th)
  end

  local function build_quads_for_layout(layout, entry)
    local cols
    local rows

    if layout == "1x1" then
      cols = 1
      rows = 1
    elseif layout == "1x3" then
      cols = 1
      rows = 3
    elseif layout == "3x1" then
      cols = 3
      rows = 1
    elseif layout == "3x3" then
      cols = 3
      rows = 3
    elseif layout == "6x6" then
      -- microtile 3x3 effectively
      cols = 6
      rows = 6
    else
      error("unexpected layout=" .. layout)
    end

    local nq = assert(love.graphics.newQuad)

    local cw = floor(entry.src_rect.w / cols)
    local ch = floor(entry.src_rect.h / rows)

    local layout_entry = {
      cols = cols,
      rows = rows,
      cw = cw,
      ch = ch,
      quads = {},
    }
    entry.layouts[layout] = layout_entry

    local x0
    local y0
    local yo
    for y = 1,rows do
      y0 = y - 1
      yo = y0 * cols
      for x = 1,cols do
        x0 = x - 1
        local qx = entry.src_rect.x + x0 * cw
        local qy = entry.src_rect.y + y0 * ch
        layout_entry.quads[1 + yo + x0] = nq(
          qx,
          qy,
          cw,
          ch,
          entry.texture_w,
          entry.texture_h
        )
      end
    end
  end

  --- @spec #initialize(): void
  function ic:initialize()
    ic._super.initialize(self)

    --- @spec components: Table<ID, Table>
    self.components = {}
  end

  --- @spec #add_component(vanity_id: String, layout: Layout, src_rect: Rect, tw: Number, th: Number): self
  function ic:add_component(vanity_id, layout, src_rect, tw, th)
    assertions.is_string(vanity_id)
    assertions.is_string(layout)
    assert(Rect.is_rect_like(src_rect))
    assertions.is_number(tw)
    assertions.is_number(th)
    if self.components[vanity_id] then
      error("source already registered vanity_id=" .. vanity_id)
    end
    local entry = {
      layout = layout,
      src_rect = src_rect,
      layouts = {},
      texture_w = tw,
      texture_h = th,
    }
    build_quads_for_layout(entry.layout, entry)
    if layout == "3x3" then
      build_quads_for_layout("6x6", entry)
    end
    self.components[vanity_id] = entry
    return self
  end

  --- Render or place the given components into the sprite batch.
  --- `components` is a table with a `base` which represents the core or base component that
  --- the quad map should be based on.
  --- `overrides` is a list of components that should be used to override specific quads in the
  --- quad map.
  --- The quad map is laid out via a numpad like format:
  ---     789
  ---     456
  ---     123
  --- For example to replace the top-left corner, the override should contain:
  ---     {
  ---       vanity_id = "replacement_component",
  ---       quads = {
  ---         [7] = 7 -- replace the top-left component with the top-left component of replacement_component
  ---       }
  ---     }
  ---
  --- @spec #build_component(
  ---   sprite_batch: SpriteBatch,
  ---   target_rect: Rect,
  ---   components: Table,
  ---   thicknesses: Any,
  ---   options: Table
  --- ): SpriteBatch
  function ic:build_component(sprite_batch, target_rect, components, _thicknesses, options)
    assert(Rect.is_rect_like(target_rect), "expected a rect for target_rect")
    options = options or {}

    local nq = assert(love.graphics.newQuad)
    -- 789
    -- 456
    -- 123
    local base_layout
    local q = {}
    if type(components.base) == "string" then
      local entry = self.components[components.base]
      if entry then
        base_layout = entry.layout
        if base_layout == "1x1" then
          local q2 = assert(entry.layouts["1x1"].quads)
          q[7], q[8], q[9] = q2[1], q2[1], q2[1]
          q[4], q[5], q[6] = q2[1], q2[1], q2[1]
          q[1], q[2], q[3] = q2[1], q2[1], q2[1]
        elseif base_layout == "1x3" then
          local q2 = assert(entry.layouts["1x3"].quads)
          q[7], q[8], q[9] = q2[1], q2[1], q2[1]
          q[4], q[5], q[6] = q2[2], q2[2], q2[2]
          q[1], q[2], q[3] = q2[3], q2[3], q2[3]
        elseif base_layout == "3x1" then
          local q2 = assert(entry.layouts["3x1"].quads)
          q[7], q[8], q[9] = q2[1], q2[2], q2[3]
          q[4], q[5], q[6] = q2[1], q2[2], q2[3]
          q[1], q[2], q[3] = q2[1], q2[2], q2[3]
        elseif base_layout == "3x3" then
          local q2 = assert(entry.layouts["3x3"].quads)
          q[7], q[8], q[9] = q2[1], q2[2], q2[3]
          q[4], q[5], q[6] = q2[4], q2[5], q2[6]
          q[1], q[2], q[3] = q2[7], q2[8], q2[9]
        end
      else
        error("component does not exists vanity_id=" .. component.base)
      end
    else
      error("unexpected components")
    end

    if components.overrides then
      local entry
      local replacement
      for _, override in ipairs(components.overrides) do
        entry = self.components[override.vanity_id]

        for source_index, replacement_index in pairs(overrides.quads) do
          replacement = entry.quads[entry.layout][replacement_index]
          q[source_index] = replacement
        end
      end
    end

    local dx = assert(target_rect.x, "expected target x-coord")
    local dy = assert(target_rect.y, "expected target y-coord")
    local w = assert(target_rect.w, "expected a target width")
    local h = assert(target_rect.h, "expected a target height")

    local hw = floor(w / 2)
    local hh = floor(h / 2)

    -- i.e. base quad cell sizes
    local quad_params = {}
    for i, quad in pairs(q) do
      local x, y, cw, ch = quad:getViewport()
      quad_params[i] = { ox = 0, oy = 0, w = cw, h = ch }
    end

    -- quad-cell-sizes
    local qcs = {}
    for i, item in pairs(quad_params) do
      qcs[i] = {
        ox = item.ox,
        oy = item.oy,
        x = 0,
        y = 0,
        w = item.w,
        h = item.h,
        lw = 0,
        lh = 0,
        c = 0,
        r = 0,
      }
    end

    qcs[7].w = math.min(quad_params[7].w, hw)
    qcs[4].w = math.min(quad_params[4].w, hw)
    qcs[1].w = math.min(quad_params[1].w, hw)

    qcs[9].w = math.min(quad_params[9].w, w - qcs[7].w)
    qcs[6].w = math.min(quad_params[6].w, w - qcs[4].w)
    qcs[3].w = math.min(quad_params[3].w, w - qcs[1].w)

    -- the right side is special in that it must be offset to compensate
    qcs[9].ox = quad_params[9].w - qcs[9].w
    qcs[6].ox = quad_params[6].w - qcs[6].w
    qcs[3].ox = quad_params[3].w - qcs[3].w

    qcs[7].h = math.min(quad_params[7].h, hh)
    qcs[8].h = math.min(quad_params[8].h, hh)
    qcs[9].h = math.min(quad_params[9].h, hh)

    qcs[1].h = math.min(quad_params[1].h, h - qcs[7].h)
    qcs[2].h = math.min(quad_params[2].h, h - qcs[8].h)
    qcs[3].h = math.min(quad_params[3].h, h - qcs[9].h)

    qcs[1].oy = quad_params[1].h - qcs[1].h
    qcs[2].oy = quad_params[2].h - qcs[2].h
    qcs[3].oy = quad_params[3].h - qcs[3].h

    -- inner quads
    qcs[8].iw, qcs[8].ih = w - qcs[7].w - qcs[9].w, qcs[8].h
    qcs[4].iw, qcs[4].ih = qcs[4].w,                h - qcs[7].h - qcs[1].h
    qcs[5].iw, qcs[5].ih = w - qcs[4].w - qcs[6].w, h - qcs[8].h - qcs[2].h
    qcs[6].iw, qcs[6].ih = qcs[6].w,                h - qcs[9].h - qcs[3].h
    qcs[2].iw, qcs[2].ih = w - qcs[1].w - qcs[3].w, qcs[2].h

    -- inner grid
    qcs[8].c, qcs[8].r = floor(qcs[8].iw / qcs[8].w), floor(qcs[8].ih / qcs[8].h)
    qcs[4].c, qcs[4].r = floor(qcs[4].iw / qcs[4].w), floor(qcs[4].ih / qcs[4].h)
    qcs[5].c, qcs[5].r = floor(qcs[5].iw / qcs[5].w), floor(qcs[5].ih / qcs[5].h)
    qcs[6].c, qcs[6].r = floor(qcs[6].iw / qcs[6].w), floor(qcs[6].ih / qcs[6].h)
    qcs[2].c, qcs[2].r = floor(qcs[2].iw / qcs[2].w), floor(qcs[2].ih / qcs[2].h)

    qcs[8].lw, qcs[8].lh = qcs[8].iw % qcs[8].w, qcs[8].ih % qcs[8].h
    qcs[4].lw, qcs[4].lh = qcs[4].iw % qcs[4].w, qcs[4].ih % qcs[4].h
    qcs[5].lw, qcs[5].lh = qcs[5].iw % qcs[5].w, qcs[5].ih % qcs[5].h
    qcs[6].lw, qcs[6].lh = qcs[6].iw % qcs[6].w, qcs[6].ih % qcs[6].h
    qcs[2].lw, qcs[2].lh = qcs[2].iw % qcs[2].w, qcs[2].ih % qcs[2].h

    qcs[7].x, qcs[7].y = target_rect.x,                              target_rect.y
    qcs[8].x, qcs[8].y = qcs[7].x + qcs[7].w,                        target_rect.y
    qcs[9].x, qcs[9].y = qcs[8].x + qcs[8].c * qcs[8].w + qcs[8].lw, target_rect.y
    qcs[4].x, qcs[4].y = target_rect.x,                              qcs[7].y + qcs[7].h
    qcs[5].x, qcs[5].y = qcs[4].x + qcs[4].w,                        qcs[8].y + qcs[8].h
    qcs[6].x, qcs[6].y = qcs[5].x + qcs[5].c * qcs[5].w + qcs[5].lw, qcs[9].y + qcs[9].h
    qcs[1].x, qcs[1].y = target_rect.x,                              qcs[4].y + qcs[4].r * qcs[4].h + qcs[4].lh
    qcs[2].x, qcs[2].y = qcs[1].x + qcs[1].w,                        qcs[5].y + qcs[5].r * qcs[5].h + qcs[5].lh
    qcs[3].x, qcs[3].y = qcs[2].x + qcs[2].c * qcs[2].w + qcs[2].lw, qcs[6].y + qcs[6].r * qcs[6].h + qcs[6].lh

    -- Top // L>R
    sprite_batch:add(resize_quad(q[7], qcs[7].w, qcs[7].h), dx, dy)
    dx = dx + qcs[7].w
    local tmq = resize_quad(q[8], qcs[8].w, qcs[8].h)
    if qcs[8].c > 0 then
      for _ = 1,qcs[8].c do
        sprite_batch:add(tmq, dx, dy)
        dx = dx + qcs[8].w
      end
    end
    if qcs[8].lw > 0 then
      sprite_batch:add(resize_quad(q[8], qcs[8].lw, qcs[8].h), dx, dy)
      dx = dx + qcs[8].lw
    end
    sprite_batch:add(translate_quad(resize_quad(q[9], qcs[9].w, qcs[9].h), qcs[9].ox, 0), dx, dy)

    -- Mid L>B M>B R>B
    dx = qcs[4].x
    dy = qcs[4].y
    if qcs[4].r > 0 then
      dy = target_rect.y + qcs[7].h
      for _ = 1,qcs[4].r do
        sprite_batch:add(q[4], dx, dy)
        dy = dy + qcs[4].h
      end
    end

    if qcs[4].lh > 0 then
      sprite_batch:add(resize_quad(q[5], qcs[4].w, qcs[4].lh), dx, dy)
    end

    dy = qcs[5].y
    if qcs[5].r > 0 then
      local q5 = resize_quad(q[5], qcs[5].w, qcs[5].h)
      for _ = 1,qcs[5].r do
        dx = qcs[5].x
        if qcs[5].c > 0 then
          for _ = 1,qcs[5].c do
            sprite_batch:add(q5, dx, dy)
            dx = dx + qcs[5].w
          end
        end
        if qcs[5].lw > 0 then
          sprite_batch:add(resize_quad(q5, qcs[5].lw, qcs[5].h), dx, dy)
          dx = dx + qcs[5].lw
        end
        dy = dy + qcs[5].h
      end
    end

    dx = qcs[5].x
    if qcs[5].lh > 0 then
      if qcs[5].c > 0 then
        for _ = 1,qcs[5].c do
          sprite_batch:add(resize_quad(q[5], qcs[5].w, qcs[5].lh), dx, dy)
          dx = dx + qcs[5].w
        end
      end
      if qcs[5].lw > 0 then
        sprite_batch:add(resize_quad(q[5], qcs[5].lw, qcs[5].lh), dx, dy)
        dx = dx + qcs[5].lw
      end
    end

    dx = qcs[6].x
    dy = qcs[6].y
    if qcs[6].r > 0 then
      for _ = 1,qcs[6].r do
        sprite_batch:add(q[6], dx, dy)
        dy = dy + qcs[6].h
      end
    end

    if qcs[6].lh > 0 then
      dx = qcs[6].x
      sprite_batch:add(
        translate_quad(resize_quad(q[6], qcs[6].w, qcs[6].lh), qcs[6].ox, qcs[6].oy),
        dx,
        dy
      )
    end

    -- Bottom
    dx = qcs[1].x
    dy = qcs[1].y
    sprite_batch:add(
      translate_quad(resize_quad(q[1], qcs[1].w, qcs[1].h), qcs[1].ox, qcs[1].oy),
      dx,
      dy
    )
    dx = qcs[2].x
    dy = qcs[2].y
    local tmq = resize_quad(q[2], qcs[2].w, qcs[2].h)
    if qcs[2].c > 0 then
      for _=1,qcs[2].c do
        sprite_batch:add(tmq, dx, dy)
        dx = dx + qcs[2].w
      end
    end
    if qcs[2].lw > 0 then
      sprite_batch:add(
        translate_quad(resize_quad(q[2], qcs[2].lw, qcs[2].h), qcs[2].ox, qcs[2].oy),
        dx,
        dy
      )
      dx = dx + qcs[2].lw
    end
    dx = qcs[3].x
    dy = qcs[3].y
    sprite_batch:add(
      translate_quad(resize_quad(q[3], qcs[3].w, qcs[3].h), qcs[3].ox, qcs[3].oy),
      dx,
      dy
    )

    return sprite_batch
  end
end

return Tiler
