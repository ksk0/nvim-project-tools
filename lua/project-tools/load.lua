local parser = require("toml")
local ppath  = require("plenary.path")

local config_files = {
  python = "pyproject",
  lua =  "luaproject",
}

local current_dir = function ()
  return os.getenv("PWD") or io.popen("cd"):read() or vim.fn.getcwd()
end

local search_path = function(root)
  local search_root = ppath:new(root or current_dir())
  local parents = search_root:parents()

  if not search_root:is_dir() then
    search_root = ppath:new(parents[1])
    parents = search_root:parents()
  end

  -- ===============================================
  -- "search_root" can't be system root directory
  --
  if parents[#parents] == search_root:absolute() then
    vim.notify ("System root is not valid project dir!", "error")
    return
  end

  return search_root .. ";" .. parents[#parents-1]
end

local find_config = function (root)
  local spath = search_path(root)

  if not spath then return end

  local projects = {}

  -- ================================================================
  -- nested projects should not exist, but if found, use
  -- deepest project as project. While any duplication of 
  -- project file is considered wrong/dangerouse, using
  -- top most is considered more dangerouse.
  --
  for lang,file_name in pairs(config_files) do
    local project_file = vim.fn.findfile(file_name .. ".toml", spath)

    if project_file ~= "" then
      local file = ppath:new(project_file)
      local pconfig = {
        _lang = lang,
        _file = file:absolute(),
        _root = file:parent():absolute(),
      }

      table.insert(projects, pconfig)
    end
  end

  if not projects[1] then return end

  table.sort(
    projects,
    function (a, b)
      return a._file > b._file
    end
  )

  return projects[1]
end

local load_config = function(self, root)
  local pconfig = find_config(root)

  if not pconfig then return end

  local file = io.open(pconfig._file, "r")

  if not file then
    vim.notify("Failed to open project file " .. pconfig._file, "error")
    return
  end

  pconfig._config = parser.decode(file:read("*a"))

  file:close()

  pconfig = vim.tbl_extend("force", self, pconfig)

  return setmetatable(pconfig, getmetatable(self))
end

local create_test_object = function ()
  local M = {}

  M._search_path = search_path
  M._find_config = find_config
  M._load_config = load_config

  return M
end

if _G._LUA_TEST then
  return create_test_object()
else
  return load_config
end
