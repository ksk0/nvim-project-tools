-- setup/python/runner
--
local ppath  = require("plenary.path")
local list   = require("project-tools.core.list")
local env    = require("project-tools.core.env")

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

local setup = function(self)
  local tools = self._config.tool
  if not tools then return end

  local runner  = tools.runner or {}
  local pyright = tools.pyright or {}

  local venv  = runner.venv or pyright.venv
  local extraPaths = list.union(runner.extraPaths, pyright.extraPaths)
  local extraBin   = list.union(runner.extraBin)

  if venv then
      local venv_path = ppath:new(self._root, venv).filename
      local run_path  = ppath:new(venv_path, "bin").filename
      local lib_path  = python_lib_dir(venv_path)

      env.prepend("PYTHONPATH", lib_path)
      env.prepend("PATH", run_path)
  end

  for _,path in pairs(list.reverse(extraPaths)) do
      local lib_path = ppath:new(self._root, path).filename
      env.prepend("PYTHONPATH", lib_path)
  end

  for _,path in pairs(list.reverse(extraBin)) do
      local run_path = ppath:new(self._root, path).filename
      env.prepend("PATH", run_path)
  end
end

return setup
