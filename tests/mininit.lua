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
local plugin_root = script_path():match('(.-)/([^/]+/)$')

-- =======================================================
-- load this plugin
--
return packer.startup(function(use)
  use (plugin_root)
  -- use ("/home/koske/develop/nvim/nvim-expose-private")
  use "nvim-lua/plenary.nvim"
  use {"ksk0/nvim-bricks", config = function() require("nvim-bricks") end}
end)
