local Object = require("balm/object")
local Vector2 = require("balm/m/vector/2")
local Rect = require("balm/m/rect")
local floor = math.floor

local Quadmap = Object:extends("balm.u.Quadmap")
do
  local ic = Quadmap.instance_class

  --- @spec #initialize(options: Table): void
  function ic:initialize(options)
    ic._super.initialize(self)

    self.cell_size = Vector2.copy(options.cell_size)
    self.image_size = Vector2.copy(options.image_size)
    if options.src_rect then
      self.src_rect = Rect.copy(options.src_rect)
    else
      self.src_rect = Rect.new(0, 0, self.image_size.x, self.image_size.y)
    end
    self.cols = floor(self.src_rect.w / self.cell_size.x)
    self.rows = floor(self.src_rect.h / self.cell_size.y)
  end

  --- @spec #cell_to_index(x: Number, y: Number): Number
  function ic:cell_to_index(x, y)
    return x % self.cols + self.cols * (y % self.rows)
  end

  --- @spec #index_to_cell(index: Number): (x: Number, y: Number)
  function ic:index_to_cell(index)
    return index % self.cols, floor(index / self.cols)
  end

  --- @spec #quad_from_pos(x: Number, y: Number): love.graphics.Quad
  function ic:quad_from_pos(x, y)
    return love.graphics.newQuad(
      self.src_rect.x + x * self.cell_size.x,
      self.src_rect.y + y * self.cell_size.y,
      self.cell_size.x,
      self.cell_size.y,
      self.image_size.x,
      self.image_size.y
    )
  end

  --- @spec #quad_from_index(index: Number): love.graphics.Quad
  function ic:quad_from_index(index)
    local x, y = self:index_to_cell(index)
    return self:quad_from_pos(x, y)
  end
end

return Quadmap
