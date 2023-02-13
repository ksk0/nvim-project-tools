-- lazy load project-tools
--
local M = {}

M.test = function ()
  vim.notify("No tests defined for this project!")
end

return setmetatable(M, {
  __index = function(self, k)
    local module = "project-tools."

    -- if project config is already loaded
    -- call functions for specific language
    --
    if (self._lang) then
      module = module .. self._lang .. "."
    end

    module = module .. k

    local ok,val = pcall(require, module)

    if ok then
      rawset(self, k, val)
    else
      val = nil
    end

    return val
  end,
})
