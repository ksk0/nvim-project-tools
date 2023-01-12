-- lazy load project-tools
--
local M = {}

M.test = function ()
  vim.notify("No tests defined for this project!")
end

return setmetatable(M, {
  __index = function(t, k)
    local module = "project-tools." .. k
    local ok,val = pcall(require, module)

    if ok then
      rawset(t, k, val)
    else
      val = nil
    end

    return val
  end,
})
