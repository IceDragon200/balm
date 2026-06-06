local Object = require("balm/object")

local ScalarTypes = {
  -- Signed Integers
  i8 = {},
  i16 = {},
  i24 = {},
  i32 = {},
  i40 = {},
  i48 = {},
  i64 = {},
  -- Unsigned Integers
  u8 = {},
  u16 = {},
  u24 = {},
  u32 = {},
  u40 = {},
  u48 = {},
  u64 = {},
  -- Floating-Point Numbers
  f16 = {},
  f24 = {},
  f32 = {},
  f40 = {},
  f48 = {},
  f64 = {},
  -- Special types
  u8bool = {},
  u8string = {},
  u16string = {},
  u24string = {},
  u32string = {},
}

function ScalarTypes.i8:write(byte_buf, file, data)
  return byte_buf:w_i8(file, data)
end
function ScalarTypes.i16:write(byte_buf, file, data)
  return byte_buf:w_i16(file, data)
end
function ScalarTypes.i24:write(byte_buf, file, data)
  return byte_buf:w_i24(file, data)
end
function ScalarTypes.i32:write(byte_buf, file, data)
  return byte_buf:w_i32(file, data)
end
function ScalarTypes.i40:write(byte_buf, file, data)
  return byte_buf:w_i40(file, data)
end
function ScalarTypes.i48:write(byte_buf, file, data)
  return byte_buf:w_i48(file, data)
end
function ScalarTypes.i64:write(byte_buf, file, data)
  return byte_buf:w_i64(file, data)
end

function ScalarTypes.u8:write(byte_buf, file, data)
  return byte_buf:w_u8(file, data)
end
function ScalarTypes.u16:write(byte_buf, file, data)
  return byte_buf:w_u16(file, data)
end
function ScalarTypes.u24:write(byte_buf, file, data)
  return byte_buf:w_u24(file, data)
end
function ScalarTypes.u32:write(byte_buf, file, data)
  return byte_buf:w_u32(file, data)
end
function ScalarTypes.u40:write(byte_buf, file, data)
  return byte_buf:w_u40(file, data)
end
function ScalarTypes.u48:write(byte_buf, file, data)
  return byte_buf:w_u48(file, data)
end
function ScalarTypes.u64:write(byte_buf, file, data)
  return byte_buf:w_u64(file, data)
end

function ScalarTypes.f16:write(byte_buf, file, data)
  return byte_buf:w_f16(file, data)
end
function ScalarTypes.f24:write(byte_buf, file, data)
  return byte_buf:w_f24(file, data)
end
function ScalarTypes.f32:write(byte_buf, file, data)
  return byte_buf:w_f32(file, data)
end
function ScalarTypes.f64:write(byte_buf, file, data)
  return byte_buf:w_f64(file, data)
end

function ScalarTypes.u8bool:write(byte_buf, file, data)
  return byte_buf:w_u8bool(file, data)
end

function ScalarTypes.u8string:write(byte_buf, file, data)
  return byte_buf:w_u8string(file, data)
end
function ScalarTypes.u16string:write(byte_buf, file, data)
  return byte_buf:w_u16string(file, data)
end
function ScalarTypes.u24string:write(byte_buf, file, data)
  return byte_buf:w_u24string(file, data)
end
function ScalarTypes.u32string:write(byte_buf, file, data)
  return byte_buf:w_u32string(file, data)
end

function ScalarTypes.i8:read(byte_buf, file)
  return byte_buf:r_i8(file)
end
function ScalarTypes.i16:read(byte_buf, file)
  return byte_buf:r_i16(file)
end
function ScalarTypes.i24:read(byte_buf, file)
  return byte_buf:r_i24(file)
end
function ScalarTypes.i32:read(byte_buf, file)
  return byte_buf:r_i32(file)
end
function ScalarTypes.i40:read(byte_buf, file)
  return byte_buf:r_i40(file)
end
function ScalarTypes.i48:read(byte_buf, file)
  return byte_buf:r_i48(file)
end
function ScalarTypes.i64:read(byte_buf, file)
  return byte_buf:r_i64(file)
end

function ScalarTypes.u8:read(byte_buf, file)
  return byte_buf:r_u8(file)
end
function ScalarTypes.u16:read(byte_buf, file)
  return byte_buf:r_u16(file)
end
function ScalarTypes.u24:read(byte_buf, file)
  return byte_buf:r_u24(file)
end
function ScalarTypes.u32:read(byte_buf, file)
  return byte_buf:r_u32(file)
end
function ScalarTypes.u40:read(byte_buf, file)
  return byte_buf:r_u40(file)
end
function ScalarTypes.u48:read(byte_buf, file)
  return byte_buf:r_u48(file)
end
function ScalarTypes.u64:read(byte_buf, file)
  return byte_buf:r_u64(file)
end

function ScalarTypes.f16:read(byte_buf, file)
  return byte_buf:r_f16(file)
end
function ScalarTypes.f24:read(byte_buf, file)
  return byte_buf:r_f24(file)
end
function ScalarTypes.f32:read(byte_buf, file)
  return byte_buf:r_f32(file)
end
function ScalarTypes.f64:read(byte_buf, file)
  return byte_buf:r_f64(file)
end

function ScalarTypes.u8bool:read(byte_buf, file)
  return byte_buf:r_u8bool(file)
end

function ScalarTypes.u8string:read(byte_buf, file)
  return byte_buf:r_u8string(file)
end
function ScalarTypes.u16string:read(byte_buf, file)
  return byte_buf:r_u16string(file)
end
function ScalarTypes.u24string:read(byte_buf, file)
  return byte_buf:r_u24string(file)
end
function ScalarTypes.u32string:read(byte_buf, file)
  return byte_buf:r_u32string(file)
end

function ScalarTypes.normalize_type(t)
  if type(t) == "string" then
    local scalar_type = ScalarTypes[t]
    assert(scalar_type, "expected a scalar type")
    return scalar_type
  elseif type(t) == "table" then
    assert(t.write, "expected write/3")
    assert(t.read, "expected read/2")
    return t
  else
    error("unexpected type " .. type(t))
  end
end

return ScalarTypes
