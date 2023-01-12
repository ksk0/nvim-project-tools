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

return function (self, root)
  local project

  if self._file then
    project = self
  else
    project = self:load(root)
  end

  if not project then return end
  if not project._config.tool then return end

  local lang_dir = setup_dir .. project._lang

  if fn.isdirectory(lang_dir) == 0 then return project end

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

    local script = "project-tools.setup." .. project._lang .. "." .. task

    local task_ok,task_script = pcall(require, script)

    if task_ok then
      task_script(project)
    end
  end

  return project
end
