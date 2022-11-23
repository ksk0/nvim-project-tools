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
local C

print()
describe("Module:", function ()
  _G._LUA_TEST = true

  it("Requiring module [OK]", function ()
    assert.no.errors(function() C = require("project-tools.config") end)
  end)

  _G._LUA_TEST = nil
end)

print()
describe("Find config:", function ()
  it("Don't accept root as project dir [OK]", function ()
    local parents  = ppath:new(vim.fn.getcwd()):parents()
    local root_dir = parents[#parents]

    assert.is_nil(C._search_path(root_dir))
  end)

  it("Plugin root is valid project dir [OK]", function ()
    local parents = ppath:new(plugin_root):parents()
    local search_path = plugin_root .. ";" .. parents[#parents - 1]

    assert.equal(search_path, C._search_path(plugin_root))
  end)

  local project

  it("No project config in home dir [OK]", function ()
    local config_root = ppath:new('.').path.home

    assert.is_nil(C._find_config(config_root))
  end)

  it("Find this project's config - implicite [OK]", function ()

    -- =====================================================
    -- we need "config_file" and "config_root" variables
    -- because when those are constructed from "getcwd"
    -- we get "dereferenced"" path, i.e. symbolic links
    -- are derefernced to real paths, while "debug.getinfo"
    -- keeps links.
    --
    local config_file
    local config_root
    local test_root
    local cwd = vim.fn.getcwd()

    vim.fn.chdir(script_file:parent().filename)

    test_root   = ppath:new(vim.fn.getcwd())
    config_root = test_root:parent()
    config_file = ppath:new(config_root, "luaproject.toml")

    project = C._find_config()
    vim.fn.chdir(cwd)

    assert.equal(config_file.filename, project.file)
    assert.equal(config_root.filename, project.root)
  end)

  it("Find this project's config - explicite [OK]", function ()
    local config_file = ppath:new(plugin_root, "luaproject.toml")

    project = C._find_config(plugin_root.filename)

    assert.equal(config_file.filename, project.file)
    assert.equal(plugin_root.filename, project.root)
  end)
end)

print()
describe("Load config:", function ()
  it("Load 'lua' test config [OK]", function ()
    local lua_test_dir  = ppath:new(tests_root, "test-lua")
    local lua_test_conf = ppath:new(lua_test_dir, "luaproject.toml")

    local project = C.load(lua_test_dir.filename)

    assert.is_not_nil(project)
    assert.equal(lua_test_conf.filename, project.file)
    assert.equal('lua', project.lang)
    assert.equal('lua', project.config.tool.tester.option_1)
  end)

  it("Load 'python' test config [OK]", function ()
    local py_test_dir  = ppath:new(tests_root, "test-python")
    local py_test_conf = ppath:new(py_test_dir, "pyproject.toml")

    local project = C.load(py_test_dir.filename)

    assert.is_not_nil(project)
    assert.equal(py_test_conf.filename, project.file)
    assert.equal('python', project.lang)
    assert.equal('python', project.config.tool.tester.option_1)
  end)
end)
