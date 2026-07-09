local has_len_mt = false
do
  local obj = {}
  setmetatable(obj, { __len = function ()
    return 12
  end})

  if #obj == 12 then
    has_len_mt = true
  end
end

return setmetatable({
  has_len_mt = has_len_mt,
}, { __newindex = {} })
