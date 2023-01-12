local ppath  = require("plenary.path")
local list   = require("project-tools.core.list")

local extend_env_var = function (name, path, separator, prepend)
  if not path then return end

  separator = separator or ":"

  if not vim.env[name] then
    vim.env[name] = path
    return
  end

  local paths = vim.split(vim.env[name], separator)

  if not vim.tbl_contains(paths, path) then
    if prepend then
      vim.env[name] = path .. separator .. vim.env[name]
    else
      vim.env[name] = vim.env[name] .. separator .. path
    end
  end
end

local append_to_env_var = function (name, path, separator)
  extend_env_var (name, path, separator)
end

local prepend_to_env_var = function (name, path, separator)
  extend_env_var (name, path, separator, true)
end

local python_lib_dir = function(path)
  local config_file = ppath:new(path, "pyvenv.cfg").filename

  local file = io.open(config_file, "r")

  if not file then
    return
  end

  local line = file:read()

  while line do
    local m_start, m_end = line:find('^%s*version%s*=%s*')

    if m_start == 1 then
      local v = vim.split(line:sub(m_end + 1), "%.")
      local python_lib = string.format("%s/lib/python%s.%s/site-packages", path, v[1], v[2])

      file:close()

      return python_lib
    end

    line = file:read()
  end

  file:close()
end

local setup = function(self, project)
  local tools = project._config.tool
  if not tools then return end

  local runner  = tools.runner or {}
  local pyright = tools.pyright or {}

  local venv  = runner.venv or pyright.venv
  local extraPaths = list.union(runner.extraPaths, pyright.extraPaths)
  local extraBin   = list.union(runner.extraBin)

  if venv then
      local venv_path = ppath:new(project._root, venv).filename
      local run_path  = ppath:new(venv_path, "bin").filename
      local lib_path  = python_lib_dir(venv_path)

      prepend_to_env_var("PYTHONPATH", lib_path)
      prepend_to_env_var("PATH", run_path)
  end

  for _,path in pairs(list.reverse(extraPaths)) do
      local lib_path = ppath:new(project._root, path).filename
      prepend_to_env_var("PYTHONPATH", lib_path)
  end

  for _,path in pairs(list.reverse(extraBin)) do
      local run_path = ppath:new(project._root, path).filename
      prepend_to_env_var("PATH", run_path)
  end
end

return setup
