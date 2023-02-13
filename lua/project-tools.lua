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
    -- if project config is already loaded
    -- call functions for specific language
    --
    local ok,val
    local lang = self._lang

    if lang then
      ok,val = pcall(require, "project-tools.lang." .. lang .. "." .. k)
    else
      ok,val = pcall(require, "project-tools." .. k)
      if not ok then
        ok,val = pcall(require, "project-tools.lang.default." .. k)
      end
    end

    if ok then
      rawset(self, k, val)
    else
      val = nil
    end

    return val
  end,
})
