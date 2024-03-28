local Rect = require("balm/m/rect")

local WindowSkin = {}

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

function WindowSkin.create_border(sprite_batch, target_rect, src_rect, thicknesses, options)
  assert(src_rect)
  -- image sizes
  local image_w = sprite_batch:getTexture():getWidth()
  local image_h = sprite_batch:getTexture():getHeight()

  -- thicknesses
  local lw = thicknesses.l
  local th = thicknesses.t
  local rw = thicknesses.r
  local bh = thicknesses.b

  -- source rectangle coords and sizes
  local sx = src_rect.x
  local sy = src_rect.y
  local sw = src_rect.w
  local sh = src_rect.h
  local sx2 = sx + sw
  local sy2 = sy + sh

  -- now calculate the inner segments, these are 3x segments
  -- meaning that they have a 'start', 'mid' and 'end' segment.
  -- 'start' and 'end' are fixed size, while 'mid' is repeating
  -- if I was doing true blitting, then 'mid' would be variable size, sadly that won't work here

  -- the segments width and height, these are the inner parts of the border,
  -- i.e. without the corners
  local segments_w = sw - lw - rw
  local segments_h = sh - th - bh

  -- segment cell sizes
  local scw = math.floor(segments_w / 3)
  local sch = math.floor(segments_h / 3)

  --
  local tx = target_rect.x
  local ty = target_rect.y
  local inner_w = target_rect.w
  local inner_h = target_rect.h

  local mid_segs_w = inner_w - scw * 2
  local mid_segs_h = inner_h - sch * 2

  local horz_segs = math.floor(inner_w / scw)
  local vert_segs = math.floor(inner_h / sch)

  local horz_rest = math.max(0, mid_segs_w) % scw
  local vert_rest = math.max(0, mid_segs_h) % sch

  -- subtract the start and end segments from the totals
  local mid_horz_segs = math.floor(mid_segs_w / scw)
  local mid_vert_segs = math.floor(mid_segs_h / sch)

  local sscwl = scw
  local sscwr = scw
  local sscht = sch
  local sschb = sch

  hiw = math.floor(inner_w / 2)
  if hiw < scw then
    sscwl = hiw
    sscwr = inner_w - hiw
  end
  hih = math.floor(inner_h / 2)
  if inner_h / 2 < sch then
    sscht = hih
    sschb = inner_h - hih
  end

  local ssro = scw - sscwr
  local ssbo = sch - sschb

  -- alias
  local nq = love.graphics.newQuad
  -- corners, the easiest to add
  local tlc = nq(sx, sy, lw, th, image_w, image_h)
  local trc = nq(sx2 - rw, sy, rw, th, image_w, image_h)
  local blc = nq(sx, sy2 - bh, lw, bh, image_w, image_h)
  local brc = nq(sx2 - rw, sy2 - bh, rw, bh, image_w, image_h)
  -- top segments
  local ts = nq(sx + lw, sy, sscwl, th, image_w, image_h)
  local tm = nq(sx + lw + scw, sy, scw, th, image_w, image_h)
  local te = nq(sx + lw + scw * 2 + ssro, sy, sscwr, th, image_w, image_h)
  -- left segments
  local ls = nq(sx, sy + th, lw, sscht, image_w, image_h)
  local lm = nq(sx, sy + th + sch, lw, sch, image_w, image_h)
  local le = nq(sx, sy + th + sch * 2 + ssbo, lw, sschb, image_w, image_h)
  -- right segments
  local nx = sx2 - rw
  local rs = nq(nx, sy + th, rw, sscht, image_w, image_h)
  local rm = nq(nx, sy + th + sch, rw, sch, image_w, image_h)
  local re = nq(nx, sy + th + sch * 2 + ssbo, rw, sschb, image_w, image_h)
  -- bottom segments
  local ny = sy2 - bh
  local bs = nq(sx + lw, ny, sscwl, bh, image_w, image_h)
  local bm = nq(sx + lw + scw, ny, scw, bh, image_w, image_h)
  local be = nq(sx + lw + scw * 2 + ssro, ny, sscwr, bh, image_w, image_h)

  local dx = tx - rw
  local dy = ty - th

  sprite_batch:add(tlc, dx, dy)
  dx = dx + lw
  sprite_batch:add(ts, dx, dy)
  dx = dx + sscwl
  if mid_horz_segs > 0 then
    for _=1,mid_horz_segs do
      sprite_batch:add(tm, dx, dy)
      dx = dx + scw
    end
  end
  if horz_rest > 0 then
    sprite_batch:add(resize_quad(tm, horz_rest, nil), dx, dy)
    dx = dx + horz_rest
  end
  sprite_batch:add(te, dx, dy)
  dx = dx + sscwr
  local bdx = dx

  sprite_batch:add(trc, dx, dy)

  dx = tx - lw
  dy = ty

  sprite_batch:add(ls, dx, dy)
  sprite_batch:add(rs, bdx, dy)
  dy = dy + sscht
  if mid_vert_segs > 0 then
    for _=1,mid_vert_segs do
      sprite_batch:add(lm, dx, dy)
      sprite_batch:add(rm, bdx, dy)
      dy = dy + sch
    end
  end
  if vert_rest > 0 then
    sprite_batch:add(resize_quad(lm, nil, vert_rest), dx, dy)
    sprite_batch:add(resize_quad(rm, nil, vert_rest), bdx, dy)
    dy = dy + vert_rest
  end
  sprite_batch:add(le, dx, dy)
  sprite_batch:add(re, bdx, dy)
  dy = dy + sschb

  dx = tx - rw
  sprite_batch:add(blc, dx, dy)
  dx = dx + lw

  sprite_batch:add(bs, dx, dy)
  dx = dx + sscwl
  if mid_horz_segs > 0 then
    for _=1,mid_horz_segs do
      sprite_batch:add(bm, dx, dy)
      dx = dx + scw
    end
  end
  if horz_rest > 0 then
    sprite_batch:add(resize_quad(bm, horz_rest, nil), dx, dy)
    dx = dx + horz_rest
  end
  sprite_batch:add(be, dx, dy)
  dx = dx + sscwr

  sprite_batch:add(brc, dx, dy)

  return sprite_batch
end

-- Fills the target sprite batch with the src rect as many times as possible
function WindowSkin.repeat_fill(sprite_batch, target_rect, src_rect, _unsued, options)
  local col_segments = math.floor(target_rect.w / src_rect.w)
  local row_segments = math.floor(target_rect.h / src_rect.h)
  local col_rest = target_rect.w % src_rect.w
  local row_rest = target_rect.h % src_rect.h

  -- image sizes
  local image_w = sprite_batch:getTexture():getWidth()
  local image_h = sprite_batch:getTexture():getHeight()

  -- source rectangle coords and sizes
  local sx = src_rect.x
  local sy = src_rect.y
  local sw = src_rect.w
  local sh = src_rect.h

  -- alias
  local nq = love.graphics.newQuad

  local dy = target_rect.y
  if row_segments > 0 then
    for _i = 1,row_segments do
      local dx = target_rect.x
      if col_segments > 0 then
        local rep_quad = nq(sx, sy, sw, sh, image_w, image_h)
        for _i=1,col_segments do
          sprite_batch:add(rep_quad, dx, dy)
          dx = dx + sw
        end
      end
      if col_rest > 0 then
        local rest_quad = nq(sx, sy, col_rest, sh, image_w, image_h)
        sprite_batch:add(rest_quad, dx, dy)
        dx = dx + col_rest
      end
      dy = dy + sh
    end
  end
  if row_rest > 0 then
    local dx = target_rect.x

    if col_segments > 0 then
      local rep_quad = nq(sx, sy, sw, row_rest, image_w, image_h)
      for _i=1,col_segments do
        sprite_batch:add(rep_quad, dx, dy)
        dx = dx + sw
      end
    end

    if col_rest > 0 then
      local rest_quad = nq(sx, sy, col_rest, row_rest, image_w, image_h)
      sprite_batch:add(rest_quad, dx, dy)
      dx = dx + col_rest
    end
  end
  return sprite_batch
end

function WindowSkin.repeat_fill_horz(sprite_batch, target_rect, src_rect, unused, options)
  local new_target_rect = Rect.resize(target_rect, target_rect.w, src_rect.h)
  return WindowSkin.repeat_fill(sprite_batch, new_target_rect, src_rect, unused, options)
end

function WindowSkin.repeat_fill_vert(sprite_batch, target_rect, src_rect, unused, options)
  local new_target_rect = Rect.resize(target_rect, src_rect.w, target_rect.h)
  return WindowSkin.repeat_fill(sprite_batch, new_target_rect, src_rect, unused, options)
end

function WindowSkin.create_from_3x1(sprite_batch, target_rect, src_rect, _unsued, options)
  assert(sprite_batch, "expected a sprite_batch")
  options = options or {}

  local cell_w = src_rect.w / 3

  -- image sizes
  local image_w = sprite_batch:getTexture():getWidth()
  local image_h = sprite_batch:getTexture():getHeight()

  -- source rectangle coords and sizes
  local sx = src_rect.x
  local sy = src_rect.y
  local sw = src_rect.w
  local sh = src_rect.h

  local cell_h = math.min(target_rect.h, sh)
  -- alias
  local nq = love.graphics.newQuad

  local head_w = cell_w
  local tail_w = cell_w

  local min_w = head_w + tail_w

  -- if the target width is shorter than the minimum length
  if target_rect.w < min_w then
    -- then the head and tail become half of the target width instead of their cell width
    head_w = target_rect.w / 2
    tail_w = head_w
  end

  local dx = 0
  sprite_batch:add(nq(sx, sy, head_w, cell_h, image_w, image_h), target_rect.x, target_rect.y)
  dx = dx + head_w

  -- determine if there is any mid body parts
  local mid_w = target_rect.w - head_w - tail_w
  if mid_w > 0 then
    local segment_count = math.floor(mid_w / cell_w)
    local mid_rest = mid_w % cell_w
    local qm = nq(sx + cell_w * 1, sy, cell_w, cell_h, image_w, image_h)
    for _i=1,segment_count do
      sprite_batch:add(qm, target_rect.x + dx, target_rect.y)
      dx = dx + cell_w
    end
    if mid_rest > 0 then
      sprite_batch:add(resize_quad(qm, mid_rest, nil), target_rect.x + dx, target_rect.y)
      dx = dx + mid_rest
    end
  end

  -- finally add the tail, the tail may be pushed over
  sprite_batch:add(nq(sx + cell_w * 2 + cell_w - tail_w, sy, tail_w, cell_h, image_w, image_h), target_rect.x + dx, target_rect.y)

  return sprite_batch
end

function WindowSkin.create_from_1x3(sprite_batch, target_rect, src_rect, _unsued, options)
  assert(sprite_batch, "expected a sprite_batch")
  local cell_h = src_rect.h / 3

  -- image sizes
  local image_w = sprite_batch:getTexture():getWidth()
  local image_h = sprite_batch:getTexture():getHeight()

  -- source rectangle coords and sizes
  local sx = src_rect.x
  local sy = src_rect.y
  local sw = src_rect.w
  local sh = src_rect.h

  local cell_w = math.min(target_rect.w, sw)
  -- alias
  local nq = love.graphics.newQuad

  local head_h = cell_h
  local tail_h = cell_h

  local min_h = head_h + tail_h

  -- if the target height is shorter than the minimum length
  if target_rect.h < min_h then
    -- then the head and tail become half of the target height instead of their cell height
    head_h = target_rect.h / 2
    tail_h = head_h
  end

  sprite_batch:add(nq(sx, sy, cell_w, head_h, image_w, image_h), target_rect.x, target_rect.y)

  local mid_h = target_rect.h - cell_h * 2
  local segment_count = math.floor(mid_h / cell_h)
  local mid_rest = mid_h % cell_h
  local qm = nq(sx, sy + cell_h * 1, cell_w, cell_h, image_w, image_h)
  local dy = cell_h
  for _i=1,segment_count do
    sprite_batch:add(qm, target_rect.x, target_rect.y + dy)
    dy = dy + cell_h
  end
  if mid_rest > 0 then
    sprite_batch:add(resize_quad(qm, nil, mid_rest), target_rect.x, target_rect.y + dy)
    dy = dy + mid_rest
  end
  sprite_batch:add(nq(sx, sy + cell_h * 2 + cell_h - tail_h, cell_w, tail_h, image_w, image_h), target_rect.x, target_rect.y + dy)

  return sprite_batch
end

--[[
Expects an even spaced tileset to create the window from
]]
function WindowSkin.create_from_3x3(sprite_batch, target_rect, src_rect, _unsued, options)
  options = options or {}
  -- Allows disabling specific directions on the skin
  -- For example if the right side (i.e. 6) is disabled, then the inner body will repeat to the end instead of capping.
  local enabled_cells = {
    [7] = true, [8] = true, [9] = true,
    [4] = true,             [6] = true,
    [1] = true, [2] = true, [3] = true,
  }
  if options.except then
    for key, _ in pairs(enabled_cells) do
      enabled_cells[key] = not options.except[key]
    end
  elseif options.only then
    for key, _ in pairs(enabled_cells) do
      enabled_cells[key] = options.only[key] or false
    end
  end

  -- cell width
  local cw = math.floor(src_rect.w / 3)
  -- cell height
  local ch = math.floor(src_rect.h / 3)

  -- image sizes
  local image_w = sprite_batch:getTexture():getWidth()
  local image_h = sprite_batch:getTexture():getHeight()

  local w = assert(target_rect.w, "expected a target width")
  local h = assert(target_rect.h, "expected a target height")

  -- left edge width, normally the cell width, but can be less if the cell width is greater than or equal the wanted_w
  local lew = math.min(cw, math.floor(w / 2))
  -- right edge width
  local rew = math.min(cw, w - lew)
  -- right edge x-offset
  local rexo = cw - rew

  -- top edge height
  local teh = math.min(ch, math.floor(h / 2))
  -- bottom edge height
  local beh = math.min(ch, h - teh)
  -- right edge x-offset
  local beyo = ch - beh

  local inner_width = w - lew - rew
  local inner_height = h - teh - beh

  local inner_cols = math.floor(inner_width / cw)
  local inner_rows = math.floor(inner_height / ch)

  -- last cell width, it's actually the last INTERNAL column's width
  local lcw = inner_width % cw
  -- last cell height, it's actually the last INTERNAL rows's height
  local lch = inner_height % ch

  --print("LEW", lew, "REW", rew, "TEH", teh, "BEH", beh, "REXO", rexo, "BEYO", beyo, "INNER COLS", inner_cols, "INNER ROWS", inner_rows)

  local nq = love.graphics.newQuad
  -- 789
  -- 456
  -- 123
  local q7 = nq(src_rect.x, src_rect.y, cw, ch, image_w, image_h)
  local q8 = nq(src_rect.x + cw, src_rect.y, cw, ch, image_w, image_h)
  local q9 = nq(src_rect.x + cw * 2, src_rect.y, cw, ch, image_w, image_h)
  local q5 = nq(src_rect.x + cw, src_rect.y + ch, cw, ch, image_w, image_h)
  local q4 = nq(src_rect.x, src_rect.y + ch, cw, ch, image_w, image_h)
  local q1 = nq(src_rect.x, src_rect.y + ch * 2, cw, ch, image_w, image_h)
  local q3 = nq(src_rect.x + cw * 2, src_rect.y + ch * 2, cw, ch, image_w, image_h)
  local q6 = nq(src_rect.x + cw * 2, src_rect.y + ch, cw, ch, image_w, image_h)
  local q2 = nq(src_rect.x + cw, src_rect.y + ch * 2, cw, ch, image_w, image_h)

  -- Swap cells
  -- Swap the 4 directionals first
  if not enabled_cells[8] then
    q8 = q5
  end

  if not enabled_cells[6] then
    q6 = q5
  end

  if not enabled_cells[4] then
    q4 = q5
  end

  if not enabled_cells[2] then
    q2 = q5
  end

  -- Then swap the corners
  if not enabled_cells[7] then
    q7 = q8
  end
  if not enabled_cells[9] then
    q9 = q8
  end

  if not enabled_cells[1] then
    q1 = q2
  end
  if not enabled_cells[3] then
    q3 = q2
  end
  -- End Cell swapping

  local dx = target_rect.x
  local dy = target_rect.y
  -- top-left
  sprite_batch:add(resize_quad(q7, lew, teh), dx, dy)
  -- top-mid
  dx = dx + lew
  for col=1,inner_cols do
    sprite_batch:add(resize_quad(q8, nil, teh), dx, dy)
    dx = dx + cw
  end
  if lcw > 0 then
    sprite_batch:add(resize_quad(q8, lcw, teh), dx, dy)
    dx = dx + lcw
  end
  -- top-right
  sprite_batch:add(translate_quad(resize_quad(q9, rew, teh), rexo, 0), dx, dy)

  -- body
  local q5w = resize_quad(q5, lcw, nil)
  dy = target_rect.y + teh
  for row = 1,inner_rows do
    dx = target_rect.x
    sprite_batch:add(q4, dx, dy)
    dx = dx + cw
    for col = 1,inner_cols do
      sprite_batch:add(q5, dx, dy)
      dx = dx + cw
    end
    if lcw > 0 then
      sprite_batch:add(q5w, dx, dy)
      dx = dx + lcw
    end
    sprite_batch:add(q6, dx, dy)
    dy = dy + ch
  end
  if lch > 0 then
    dx = target_rect.x
    sprite_batch:add(resize_quad(q4, nil, lch), dx, dy)
    local q5h = resize_quad(q5, nil, lch)
    dx = dx + cw
    for col = 1,inner_cols do
      sprite_batch:add(q5h, dx, dy)
      dx = dx + cw
    end
    if lcw > 0 then
      sprite_batch:add(resize_quad(q5, lcw, lch), dx, dy)
      dx = dx + lcw
    end
    sprite_batch:add(resize_quad(q6, nil, lch), dx, dy)
    dy = dy + lch
  end

  -- bottom-left
  dx = target_rect.x
  sprite_batch:add(translate_quad(resize_quad(q1, lew, beh), 0, beyo), dx, dy)
  -- bottom-mid
  dx = dx + lew
  local i = 0
  for col = 1,inner_cols do
    sprite_batch:add(translate_quad(resize_quad(q2, nil, beh), 0, beyo), dx, dy)
    dx = dx + cw
    i = i + 1
  end
  if lcw > 0 then
    sprite_batch:add(translate_quad(resize_quad(q2, lcw, beh), 0, beyo), dx, dy)
    dx = dx + lcw
  end
  -- bottom-right
  sprite_batch:add(translate_quad(resize_quad(q3, rew, beh), rexo, beyo), dx, dy)
  dy = dy + beh
  dx = dx + rew
  return sprite_batch
end

function WindowSkin.create_from_layout(sprite_batch, target_rect, layout, src_rect, thickness, options)
  local func = nil
  if layout == "1x1" then
    func = WindowSkin.repeat_fill
  elseif layout == "1x3" then
    func = WindowSkin.create_from_1x3
  elseif layout == "3x1" then
    func = WindowSkin.create_from_3x1
  elseif layout == "3x3" then
    func = WindowSkin.create_from_3x3
  elseif layout == "border" then
    func = WindowSkin.create_border
  elseif layout == "horz" then
    func = WindowSkin.repeat_fill_horz
  elseif layout == "vert" then
    func = WindowSkin.repeat_fill_vert
  else
    error("unexpected layout " .. layout)
  end

  return func(sprite_batch, target_rect, src_rect, thickness, options)
end

function WindowSkin.create_from_component(sprite_batch, target_rect, component, options)
  return WindowSkin.create_from_layout(sprite_batch, target_rect, component.layout, component.src_rect, component.thickness, options)
end

return WindowSkin
