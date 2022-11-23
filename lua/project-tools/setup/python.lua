local ppath  = require("plenary.path")
local F = vim.F

local extend_env_var = function (name, path, separator, prepend)
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

local setup_runner = function(project)
  local tools = project.config.tool
  if not tools then return end

  for _,config in pairs {tools.pyright, tools.runner} do
    for _,path in pairs {config.venv} do
        local venv_path = ppath:new(project.root, path).filename
        local run_path  = ppath:new(venv_path, "bin").filename
        local lib_path  = python_lib_dir(venv_path)

        append_to_env_var("PYTHONPATH", lib_path)
        prepend_to_env_var ("PATH", run_path)
    end

    for _,path in pairs(F.if_nil(config.extraPaths, {})) do
        local lib_path = ppath:new(project.root, path).filename
        append_to_env_var("PYTHONPATH", lib_path)
    end

    for _,path in pairs(F.if_nil(config.extraBin, {})) do
        local run_path = ppath:new(project.root, path).filename
        prepend_to_env_var("PATH", run_path)
    end
  end
end

local setup = function(_, project)
  if not project.config.tool then
    return
  end

  setup_runner(project)
end

local M = {}

return setmetatable(M,{__call = setup})
