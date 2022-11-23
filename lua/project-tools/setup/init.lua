local pconfig = require("project-tools.config")

local setup = function (_, root)
  local config = pconfig.load(root)

  if not config then return end

  require("project-tools.setup." .. config.lang)(config)
end

local M = {}

return setmetatable(M,{__call = setup})
