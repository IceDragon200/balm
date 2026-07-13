local assertions = require("balm/m/assertions")
local Bytes = require("balm/p/bin_types/bytes")
local BinSchema = require("balm/p/bin_schema")
local StringBuffer = require("balm/u/string_buffer")
local MarshallValue = require("balm/p/bin_types/marshall_value")
local Object = require("balm/object")

local MMAPSchema = BinSchema:new({
  {"magic", Bytes:new(4)},
  {"version", "u32"},
  {"timestamp", "u32"},
  4, -- padding
  32, -- reserved
  {"data", "map", "u8string", MarshallValue:new()},
})

--- @class balm.p.VTable
local VTable = Object:extends("balm.p.VTable")
do
  local ic = VTable.instance_class

  --- @spec #initialize(Table): void
  function ic:initialize(options)
    assertions.is_table(options, "expected options table")
    ic._super.initialize(self)
    self.m_filename = assertions.is_string(options.filename, "expected a filename")
    self.m_initializer = options.initializer
    self.m_dirty = false
    self.m_paranoid = false
    self.m_data = {}

    self.m_file = love.filesystem.newFile(self.m_filename)
    if not love.filesystem.getInfo(self.m_filename) then
      self:initialize_table()
    end
    self:load_table()
  end

  --- @spec #initialize_table(): void
  function ic:initialize_table()
    if self.m_initializer then
      self.m_initializer(self.m_data)
      self:save_table()
    end
  end

  --- @exception
  --- @spec #save_table(): self
  function ic:save_table()
    local buffer = StringBuffer:new("", "w")

    local success
    local bw
    local err
    -- MMAP - Marshall Map
    bw, err = MMAPSchema:write(buffer, {
      magic = "MMAP",
      version = 1,
      timestamp = 0,
      data = self.m_data
    })
    if err then
      error(err)
    end
    assert(bw > 0)
    success, err = self.m_file:open("w")
    if success then
      print("VTAB", "saving table", self.file:getFilename())
      self.m_file:write(buffer.data);
      self.m_file:flush()
      self.m_file:close()
    else
      error(err)
    end
    return self
  end

  --- @exception
  --- @spec #load_table(): self
  function ic:load_table()
    local success, err = self.m_file:open("r")
    if success then
      local result = MMAPSchema:read(self.m_file)
      assert(result.magic == "MMAP", "expected an MMAP file")
      self.m_data = result.data
      self.m_file:close()
    else
      error(err)
    end
    return self
  end

  --- @exception
  --- @spec #set_properties(Table): self
  function ic:set_properties(properties)
    assertions.is_table(properties, "expected a table")
    for key, value in pairs(properties) do
      self.m_data[key] = value
    end
    return self
  end

  --- @spec #set(key: String, value: Any): self
  function ic:set(key, value)
    self.m_data[key] = value
    return self
  end

  --- @exception
  --- @spec #put_properties(Table): self
  function ic:put_properties(properties)
    self:set_properties(properties)
    self:save_table()
    return self
  end

  --- @spec #put(key: String, value: Any): self
  function ic:put(key, value)
    self:set(key, value)
    self:save_table()
    return self
  end

  --- @spec #get(key: String): Any
  function ic:get(key)
    return self.m_data[key]
  end

  --- @spec #get_number(key: String): Number
  function ic:get_number(key)
    local value = self:get(key)
    if value == nil then
      return 0
    else
      return tonumber(value)
    end
  end

  --- @spec #get_int(key: String): Integer
  function ic:get_int(key)
    local value = self:get(key)
    if value == nil then
      return 0
    else
      return math.floor(tonumber(value))
    end
  end

  --- @spec #get_bool(key: String): Boolean
  function ic:get_bool(key)
    local value = self:get(key)
    if value == nil then
      return false
    else
      return value and true or false
    end
  end

  --- @spec #get_string(key: String): String
  function ic:get_string(key)
    local value = self:get(key)
    if value == nil then
      return ""
    else
      return tostring(value)
    end
  end
end

return VTable
