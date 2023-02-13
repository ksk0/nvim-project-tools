-- lazy load project-tools
--
local M = {}

-- ==============================================
-- if we don't set initial value for "_lang"
-- ""__index"" function will loop for ever
-- searching "_lang" member.
--
M._lang = false

return setmetatable(M, {
  __index = function(self, k)
    local ok,val
    local lang = self._lang

    -- ========================================
    -- if project config is already loaded
    -- call functions for specific language
    --
    if lang then
      ok,val = pcall(require, "project-tools.lang." .. lang .. "." .. k)
    else
      ok,val = pcall(require, "project-tools." .. k)
    end

    -- ========================================
    -- if command is not found, check if there
    -- is default one
    --
    if not ok then
      ok,val = pcall(require, "project-tools.lang.default." .. k)
    end

    if ok then
      rawset(self, k, val)
    else
      val = nil
    end

    return val
  end,
})
