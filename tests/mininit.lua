-- =======================================================
-- Packer should be present
--
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- =======================================================
-- Get directory where this script is located
--
local prepend_var = function (var_value, ext_value, separator)
  if not ext_value then return var_value end

  separator = separator or ":"

  if not var_value then
    return ext_value
  end

  local var_values = vim.split(var_value, separator)
  local new_value = var_value

  if not vim.tbl_contains(var_values, ext_value) then
      new_value = ext_value .. separator .. var_value
  end

  return new_value
end

-- =======================================================
-- Get directory where this plugin is located
--
local function script_path()
  local iswin = package.config:sub(1, 1) == '\\'
  local path  = debug.getinfo(2, 'S').source:sub(2)
  local separator =  '\\' and iswin or  '/'

  if iswin then
    path = path:gsub('/', '\\')
  end

  return path:match('(.*' .. separator .. ')')
end

-- =======================================================
-- Get directory where this plugin is located
-- (last "match" removes "tests" directory from script)
-- path, reulsting in plugin path only
--
local plugin_root = function()
  return (script_path():match('(.-)/([^/]+/)$') .. "/")
end

-- =======================================================
-- Initiate packer and load plugins
--
packer.init()
packer.use "ksk0/nvim-bricks"
packer.use "nvim-lua/plenary.nvim"

pcall(require, "nvim-bricks")

local pl_root = plugin_root()

package.path  = prepend_var(package.path,  pl_root .. 'lua/?.lua', ';')
package.path  = prepend_var(package.path,  pl_root .. 'lua/?/init.lua', ';')
