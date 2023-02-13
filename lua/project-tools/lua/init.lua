-- lazy load project-tools/lua
--
local M = {}

return setmetatable(M, {
  __index = function(t, k)
    local module = string.format("preoject-tools.lua.%s", k)
    local ok, val = pcall(require, module)

    if ok then
      rawset(t, k, val)
    else
      val = nil
    end

    return val
  end,
})
