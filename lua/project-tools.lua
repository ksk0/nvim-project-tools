-- lazy load project-tools
--
local M = setmetatable({}, {
  __index = function(t, k)
    local module = "project-tools." .. k
    local ok,val = pcall(require, module)

    if ok then
      rawset(t, k, val)
    end

    return val
  end,
})

return M
