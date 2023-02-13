local harness = require("plenary.test_harness")

local test = function (self)
  local tool = self._config.tool

  if not tool then return end
  if not tool.tests then return end

  local root = self._root .. "/"
  local tconfig = tool.tests

  local opts = {
    sequential   =  tconfig.sequential,
    minimal_init = (tconfig.init and (root .. tconfig.init) or nil)
  }

  local test_dir = root .. tconfig.dir

  harness.test_directory(test_dir, opts)
end

return test
