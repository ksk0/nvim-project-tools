-- setup/lua/runner
--
local scanner = require("plenary.scandir").scan_dir
local env = require("project-tools.core.env")

local setup = function(_, pconfig)
  local tools = pconfig._config.tool
  if not tools then return end

  local runner  = tools.runner or {}

  if runner.lib then
    local plib = pconfig._root .. '/' .. runner.lib

    package.cpath = env.prepend_var(package.cpath, plib .. '/?.so', ';')
    package.path  = env.prepend_var(package.path,  plib .. '/?.lua', ';')
    package.path  = env.prepend_var(package.path,  plib .. '/?/init.lua', ';')
  end

  if runner.plugin == 1 then
    local plugin_dir = pconfig._root .. '/plugin'

    local scripts = scanner(
      plugin_dir, {
        hidden = false,
        add_dirs = false,
        search_pattern = '^.*%.vim$',
        silent = true
      }
    )

    for _,script in pairs(scripts) do
      vim.cmd('source ' .. script)
    end
  end

  if runner.init then
    local pinit = pconfig._root .. '/' .. runner.init

    local ok,_ = pcall(dofile, pinit)
    if not ok then
      local msg = string.format('Init file: "%s" not found!', runner.init)
      vim.notify(msg, "error")
    end
  end
end

return setup
