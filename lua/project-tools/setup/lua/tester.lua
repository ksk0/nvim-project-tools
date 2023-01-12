local test_runner
local project

if project then
  local ok_tester,tester = pcall (require, "user.testing." .. project.lang)

  if ok_tester then
    test_runner = tester.setup(project)
  else
    test_runner = function () print("There is no lang " .. project.lang) end
  end
end

local run_tests = function ()
  local tool = project._config.tool
  local root = project._root .. "/"

  local test_dir = root .. tool.tests.dir
  local opts = {
    sequential = true
  }

  if tool.tests.init then
    opts.minimal_init = root .. tool.tests.init
  end

  if tool.tests.sequential then
    opts.sequential = tool.tests.sequential or true
  end

  local harness = require("plenary.test_harness")

  harness.test_directory(test_dir, opts)
end

local setup = function(pconfig)
  if not pconfig._config.tool then return end
  if not pconfig._config.tool.tests then return end

  project = vim.tbl_extend("force", {}, pconfig)

  vim.api.nvim_create_user_command("RunTests", run_tests, {})
end

return setup
