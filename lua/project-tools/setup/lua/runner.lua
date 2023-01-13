-- setup/lua/runner
--
-- local ppath  = require("plenary.path")
-- local list   = require("project-tools.core.list")
local env    = require("project-tools.core.env")

local setup = function(_, pconfig)
  local tools = pconfig._config.tool
  if not tools then return end

  -- print(vim.inspect(pconfig))

  local runner  = tools.runner or {}

  -- print("Runner:" .. vim.inspect(runner))

  if runner.lib then
    local plib = pconfig._root .. '/' .. runner.lib

    package.cpath = env.prepend_var(package.cpath, plib .. '/?.so', ';')
    package.path  = env.prepend_var(package.path,  plib .. '/?.lua', ';')
    package.path  = env.prepend_var(package.path,  plib .. '/?/init.lua', ';')
  end
end

return setup
