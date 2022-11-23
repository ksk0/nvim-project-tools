local parser = require("toml")
local ppath  = require("plenary.path")

local config_files = {
  python = "pyproject",
  lua =  "luaproject",
}

local search_path = function(root)
  local search_root = ppath:new(root or vim.fn.getcwd())
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
  -- nested projects should not exists, but if found, use
  -- deepest project as project - RETHINK THIS !!!!
  --
  for lang,file_name in pairs(config_files) do
    local project_file = vim.fn.findfile(file_name .. ".toml", spath)

    if project_file ~= "" then
      local file = ppath:new(project_file)
      local project = {
        lang = lang,
        file = file:absolute(),
        root = file:parent():absolute(),
      }

      table.insert(projects, project)
    end
  end

  if not projects[1] then return end

  table.sort(
    projects,
    function (a, b)
      return a.file > b.file
    end
  )

  return projects[1]
end

local M = {}

M.load = function(root)
  local project = find_config(root)

  if not project then return end

  local file = io.open(project.file, "r")

  if not file then
    vim.notify("Failed to open project file " .. project.file, "error")
    return
  end

  project.config = parser.decode(file:read("*a"))

  file:close()

  return project
end

if _LUA_TEST then
  M._search_path = search_path
  M._find_config = find_config
end

return M
