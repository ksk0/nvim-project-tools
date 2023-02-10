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
    local plugin_dir  = pconfig._root .. '/plugin'

    local vim_scripts = scanner(
      plugin_dir, {
        hidden = false,
        add_dirs = false,
        search_pattern = '^.*%.vim$',
        silent = true
      }
    )

    local lua_scripts = scanner(
      plugin_dir, {
        hidden = false,
        add_dirs = false,
        search_pattern = '^.*%.lua$',
        silent = true
      }
    )

    for _,script in pairs(vim_scripts) do
      vim.cmd('source ' .. script)
    end

    for _,script in pairs(lua_scripts) do
      print("Lua script: " .. script)
      dofile(script)
    end
  end

  if runner.init then
    local pinit = pconfig._root .. '/' .. runner.init
    dofile(pinit)
  end
end

return setup
