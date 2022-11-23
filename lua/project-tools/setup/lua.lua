local setup = function ()
  return true
end

local M = {}

return setmetatable(M,{__call = setup})
