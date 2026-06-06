-- Byte Encoder/Decoder is a core component, so we need to test that first
require("balm/tests/p/byte__coder_test")
-- Most persistence will run through the byte buffer
require("balm/tests/p/byte_buf_test")
require("balm/tests/p/bin_types_test")
-- Finally higher level components
require("balm/tests/p/bin_schema_test")
require("balm/tests/p/vtable_test")
