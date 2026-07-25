local Object = require("balm/object")

--- Mock class for love 2d's SpriteBatch
--- @class SpriteBatch
local SpriteBatch = Object:extends("balm.k.love2d.SpriteBatch")
do
  local ic = SpriteBatch.instance_class

  --- @override
  --- @spec #initialize(): void
  function ic:initialize()
    ic._super.initialize(self)

    self.idx = 0
    self.d = {}
  end

  --- @spec #size(): Number
  function ic:size()
    return self.idx
  end

  --- @spec #add(Quad, x: Number, y: Number)
  function ic:add(quad, x, y)
    local tw, th = quad:getTextureDimensions()
    local qx, qy, qw, qh = quad:getViewport()
    -- print(x, y, qx, qy, qw, qh, tw, th)
    self.idx = self.idx + 1
    self.d[self.idx] = {
      x = x,
      y = y,
      quad = love.graphics.newQuad(qx, qy, qw, qh, tw, th),
    }
  end

  --- @spec #get(idx: Number): Table | nil
  function ic:get(idx)
    return self.d[idx]
  end
end

return SpriteBatch
