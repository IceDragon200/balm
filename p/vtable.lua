local ByteBuf = require("util/byte_buf")
local Bytes = require("util/bin_types/bytes")
local BinSchema = require("util/bin_schema")
local StringBuf = require("util/string_buf")
local MarshallValue = require("util/bin_types/marshall_value")

local MMAPSchema = BinSchema:new({
  {"magic", Bytes:new(4)},
  {"version", "u32"},
  {"timestamp", "u32"},
  4, -- padding
  32, -- reserved
  {"data", "map", "u8string", MarshallValue:new()},
})

local VTable = lily.Object:extends("VTable")
local ic = VTable.instance_class

function ic:initialize(filename, initializer)
  ic._super.initialize(self)
  assert(filename, "expected a filename")
  self.filename = filename
  self.initializer = initializer
  self.data = {}
  self.file = love.filesystem.newFile(filename)
  if not love.filesystem.getInfo(filename) then
    self:initialize_table()
  end
  self:load_table()
end

function ic:save_table()
  local buffer = StringBuf:new("", "w")
  -- MMAP - Marshall Map
  local bytes_written, err = MMAPSchema:write(buffer, {
    magic = "MMAP",
    version = 1,
    timestamp = 0,
    data = self.data
  })
  if err then
    error(err)
  end
  local success, err = self.file:open("w")
  if success then
    print("VTAB", "saving table", self.file:getFilename())
    self.file:write(buffer.data);
    self.file:flush()
    self.file:close()
  else
    error(err)
  end
  return self
end

function ic:load_table()
  local success, err = self.file:open("r")
  if success then
    local result = MMAPSchema:read(self.file)
    assert(result.magic == "MMAP", "expected an MMAP file")
    self.data = result.data
    self.file:close()
  else
    error(err)
  end
  return self
end

function ic:initialize_table()
  if self.initializer then
    self.initializer(self.data)
  end
  self:save_table()
end

function ic:set_properties(properties)
  for key, value in pairs(properties) do
    self.data[key] = value
  end
  return self
end

function ic:set(key, value)
  self.data[key] = value
  return self
end

function ic:put_properties(properties)
  self:set_properties(properties)
  self:save_table()
  return self
end

function ic:put(key, value)
  self:set(key, value)
  self:save_table()
  return self
end

function ic:get(key)
  return self.data[key]
end

function ic:get_int(key)
  local value = self:get(key)
  if value == nil then
    return 0
  else
    return value
  end
end

function ic:get_bool(key)
  local value = self:get(key)
  if value == nil then
    return false
  else
    return value
  end
end

function ic:get_string(key)
  local value = self:get(key)
  if value == nil then
    return ""
  else
    return value
  end
end

return VTable
