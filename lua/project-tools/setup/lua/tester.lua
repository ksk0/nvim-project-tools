local test_runner
local pconfig

local run_tests = function ()
  local tool = pconfig._config.tool
  local root = pconfig._root .. "/"

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

local setup = function(self, pconfig)
  if not pconfig._config.tool then return end
  if not pconfig._config.tool.tests then return end

  pconfig = vim.tbl_extend("force", {}, pconfig)

  self.test = run_tests
  -- vim.api.nvim_create_user_command("RunProjectTests", run_tests, {})
end

return setup
