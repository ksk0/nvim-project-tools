-- ============================================
-- aserts:
--   is     - test is true
--   is_not - test is not true
--   is_nil - test is nil
--   has    - same as is
--
--   equal  - comparing if same object
--   same   - comparing if content of object are same
--
--   no.errors   - run without errors
--   has.errors  - run with errors
--
-- eqaul objects:
--   A = {element = 1}
--   B = A
--
-- same objects:
--   A = {element = 1}
--   B = {element = 1}
--



-- ============================================
-- disable output of notifications from plugin
---
-- vim.notify = function() end
--
local ppath = require("plenary.path")
local fn = vim.fn
local org_path
local org_pypath

local function script_path()
  local iswin = package.config:sub(1, 1) == '\\'
  local path  = debug.getinfo(2, 'S').source:sub(2)

  if iswin then
    path = path:gsub('/', '\\')
  end

  return ppath:new(path)
end

local script_file = script_path()
local tests_root  = ppath:new(script_file:parents()[1])
local plugin_root = ppath:new(script_file:parents()[2])
local M
local T

local reload_module = function(module)
  local pattern = "^" .. vim.pesc(module) .. "."
  local luacache = (_G.__luacache or {}).cache

  if luacache then
    luacache[module] = nil
  end

  for pack, _ in pairs(package.loaded) do
    if string.find(pack, pattern) then

      package.loaded[pack] = nil

      if luacache then
        luacache[pack] = nil
      end
    end
  end
end

local get_config_dir = function(what, lang)
  local config_root
  local config_file

  if what == "project" then
    config_root = plugin_root
    config_file = ppath:new(config_root, "luaproject.toml")
  else
    if lang == "lua" then
      config_root = ppath:new(tests_root, "test-lua")
      config_file = ppath:new(config_root, "luaproject.toml")
    elseif lang == "python" then
      config_root = ppath:new(tests_root, "test-python")
      config_file = ppath:new(config_root, "pyproject.toml")
    end
  end

  return config_root, config_file
end

local check_config = function(what, lang, project)
    local _,config_file = get_config_dir(what, lang)

    assert.is_not_nil(project)
    assert.equal(config_file.filename, project._file)
    assert.equal(lang, project._lang)
    assert.equal("tests", project._config.tool.tests.dir)
end

local check_runner = function(what, lang, project)
  local config_root,config_file = get_config_dir(what, lang)

  -- print ("What:" .. what .. " Lang: " .. lang)

  if lang == 'lua' then
    return
  elseif  lang == 'python' then
    local extra_bin = project._config.tool.runner.extraBin[1]
    local extra_lib = project._config.tool.runner.extraPaths[1]

    -- print(vim.inspect(project))
    -- print("PATH:" .. vim.env.PATH)
    -- print("PYTHONPATH:" .. vim.env.PYTHONPATH)

    assert.is_not_nil(project)
    assert.equal(config_file.filename, project._file)
    assert.equal('python', project._lang)
    assert.equal('runner/bin', extra_bin)
    assert.equal('runner/lib', extra_lib)

    local paths = fn.split(vim.env.PATH, ":")
    local py_paths = fn.split(vim.env.PYTHONPATH, ":")

    local bin_dir =  ppath:new(config_root, extra_bin)
    local lib_dir =  ppath:new(config_root, extra_lib)

    assert.is_true(vim.tbl_contains(paths, bin_dir.filename))
    assert.is_true(vim.tbl_contains(py_paths, lib_dir.filename))

  end
end

local check_setup = function(what, lang, project)
  check_runner(what, lang, project)
end

local store_paths = function()
  org_path = vim.env.PATH
  org_pypath = vim.env.PYTHONPATH
end

local restore_paths = function()
  vim.env.PATH = org_path
  vim.env.PYTHONPATH = org_pypath
end


print()
describe("Load module:", function ()
  reload_module("project-tools")

  _G._LUA_TEST = true

  it("Test [OK]", function ()
    assert.no.errors(function() T = require("project-tools.load") end)
  end)

  _G._LUA_TEST = nil

  reload_module("project-tools")

  it("Tegular [OK]", function ()
    assert.no.errors(function() M = require("project-tools") end)
  end)
end)

print()
describe("Find config:", function ()
  it("Don't accept root as project dir [OK]", function ()
    local parents  = ppath:new(fn.getcwd()):parents()
    local root_dir = parents[#parents]

    assert.is_nil(T._search_path(root_dir))
  end)

  it("Plugin root is valid project dir [OK]", function ()
    local parents = ppath:new(plugin_root):parents()
    local search_path = plugin_root .. ";" .. parents[#parents - 1]

    assert.equal(search_path, T._search_path(plugin_root))
  end)

  local project

  it("No project config in home dir [OK]", function ()
    local config_root = ppath:new('.').path.home

    assert.is_nil(T._find_config(config_root))
  end)

  it("Find this project's config - implicite [OK]", function ()

    -- =====================================================
    -- we need "config_file" and "config_root" variables
    -- because when those are constructed from "getcwd"
    -- we get "dereferenced"" path, i.e. symbolic links
    -- are derefernced to real paths, while "debug.getinfo"
    -- keeps links.
    --
    local cwd = fn.getcwd()

    fn.chdir(script_file:parent().filename)

    local config_root = plugin_root
    local config_file = ppath:new(config_root, "luaproject.toml")

    project = T._find_config()

    fn.chdir(cwd)

    assert.equal(config_file.filename, project._file)
    assert.equal(config_root.filename, project._root)
  end)

  it("Find this project's config - explicite [OK]", function ()
    local config_file = ppath:new(plugin_root, "luaproject.toml")

    project = T._find_config(plugin_root.filename)

    assert.equal(config_file.filename, project._file)
    assert.equal(plugin_root.filename, project._root)
  end)

  -- it("Find lua test config - explicite [OK]", function ()
  --   local config_file = ppath:new(plugin_root, "test-lua", "luaproject.toml")
  --
  --   -- project = C._find_config(plugin_root.filename)
  --   project = C._find_config(plugin_root.filename .. "/test-lua")
  --
  --   assert.equal(config_file.filename, project.file)
  --   assert.equal(plugin_root.filename, project.root)
  -- end)
  --
  -- it("Find python test config - explicite [OK]", function ()
  --   local config_file = ppath:new(plugin_root, "test-python", "pyproject.toml")
  --
  --   project = C._find_config(plugin_root.filename .. "/test-python")
  --
  --   assert.equal(config_file.filename, project.file)
  --   assert.equal(plugin_root.filename, project.root)
  -- end)
end)

print()
describe("Load config:", function ()
  local project

  describe("Via function:", function ()
    it("lua-test config [OK]", function ()
      local config_root,_ = get_config_dir('test', 'lua')

      assert.no.errors(function() project = T:_load_config(config_root.filename) end)
      check_config('test', 'lua', project)
    end)

    it("python-test config [OK]", function ()
      local config_root,_ = get_config_dir('test', 'python')

      assert.no.errors(function() project = T:_load_config(config_root.filename) end)
      check_config('test', 'python', project)
    end)
  end)

  reload_module("project-tools")

  describe("Via module:", function ()
    it("project config [OK]", function ()
      local config_root,_ = get_config_dir('project', 'lua')

      assert.no.errors(function() project = M:load(config_root.filename) end)
      check_config('project', 'lua', project)
    end)

    it("lua-test config [OK]", function ()
      local config_root,_ = get_config_dir('test', 'lua')

      assert.no.errors(function() project = M:load(config_root.filename) end)
      check_config('test', 'lua', project)
    end)

    it("python-test config [OK]", function ()
      local config_root,_ = get_config_dir('test', 'python')

      assert.no.errors(function() project = M:load(config_root.filename) end)

      check_config('test', 'python', project)
    end)
  end)
end)

print()
describe("Run setup:", function ()
  before_each(function()
    store_paths()
  end)

  after_each(function()
    restore_paths()
  end)

  local project

  describe("Via setup:", function ()
    it("project [OK]", function ()
      assert.no.errors(function() project = M:setup() end)
      check_config('project', 'lua', project)
      check_setup('project', 'lua', project)
    end)

    it("lua-test [OK]", function ()
      local config_root,_ = get_config_dir('test', 'lua')

      assert.no.errors(function() project = M:setup(config_root.filename) end)

      check_config('test', 'lua', project)
      check_setup('test', 'lua', project)
    end)

    it("python-test [OK]", function ()
      local config_root,_ = get_config_dir('test', 'python')

      assert.no.errors(function() project = M:setup(config_root.filename) end)

      check_config('test', 'python', project)
      check_setup('test', 'python', project)
    end)
  end)

  describe("Via load:", function ()
    it("project [OK]", function ()
      assert.no.errors(function() project = M:load() end)
      assert.no.errors(function() project:setup() end)

      check_config('project', 'lua', project)
      check_setup('project', 'lua', project)
    end)

    it("lua-test [OK]", function ()
      local config_root,_ = get_config_dir('test', 'lua')

      assert.no.errors(function() project = M:load(config_root.filename) end)
      assert.no.errors(function() project:setup() end)

      check_config('test', 'lua', project)
      check_setup('test', 'lua', project)
    end)

    it("python-test [OK]", function ()
      local config_root,_ = get_config_dir('test', 'python')

      assert.no.errors(function() project = M:load(config_root.filename) end)
      assert.no.errors(function() project:setup() end)

      check_config('test', 'python', project)
      check_setup('test', 'python', project)
    end)
  end)
end)
