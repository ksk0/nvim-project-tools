local P

local run_tests = function ()
  local tool = P._config.tool
  local root = P._root .. "/"

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

  P = vim.fn.deepcopy(pconfig)

  self.test = run_tests
end

return setup
