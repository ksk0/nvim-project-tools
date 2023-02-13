-- lua/setup
--
local scanner = require("plenary.scandir").scan_dir
local env = require("project-tools.core.env")

local add_lib = function (path)
  package.cpath = env.prepend_var(package.cpath, path .. '/?.so', ';')
  package.path  = env.prepend_var(package.path,  path .. '/?.lua', ';')
  package.path  = env.prepend_var(package.path,  path .. '/?/init.lua', ';')
end

local setup = function(self)
  local tools = self._config.tool

  if not tools then return end
  if not tools.runner then return end

  local runner  = tools.runner

  local lib = runner.lib

  if lib then
    local paths = type(lib) == 'table' and lib or {lib}

    for _,path in ipairs(paths) do
      add_lib(self._root .. '/' .. path)
    end
  end

  if runner.plugin == 1 then
    local plugin_dir  = self._root .. '/plugin'

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
      dofile(script)
    end
  end

  if runner.init then
    local pinit = self._root .. '/' .. runner.init
    dofile(pinit)
  end
end

return setup
