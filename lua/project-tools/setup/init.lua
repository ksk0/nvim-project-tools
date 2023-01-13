-- plugin/setup/init
--
local fn = vim.fn
local scanner = require("plenary.scandir").scan_dir

local function get_script_path()
  local iswin = package.config:sub(1, 1) == '\\'
  local path  = debug.getinfo(2, 'S').source:sub(2)

  path = path:gsub('/[^/]+$', '/')

  if iswin then
    path = path:gsub('/', '\\')
  end

  return path
end

local setup_dir = get_script_path()

local setup = function (self, root)
  local pconfig

  if self._file then
    pconfig = self
  else
    pconfig = self:load(root)
  end

  if not pconfig then return end
  if not pconfig._config.tool then return end

  local lang_dir = setup_dir .. pconfig._lang

  if fn.isdirectory(lang_dir) == 0 then return pconfig end

  local tasks = scanner(
    lang_dir, {
      hidden = false,
      add_dirs = false,
      search_pattern = '.*%.lua',
      silent = true
    }
  )

  for _,task in pairs(tasks) do
    task = task:gsub('.*/','')
    task = task:gsub('%.lua$','')

    local script = "project-tools.setup." .. pconfig._lang .. "." .. task

    local task_ok,task_script = pcall(require, script)

    if task_ok then
      task_script(self, pconfig)
    end
  end

  return pconfig
end

return setup
