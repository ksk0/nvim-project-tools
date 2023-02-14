-- ============================================================================
-- this is helper function you can use to reload
-- luad module and its submodules (it declares them
-- "fresh" i.e. deletes them from lua cache and
-- list of loaded modules.
--
-- If used without argument it resets 'project-tools'
-- module/object, but for that purpose "reset" function
-- should be called instead.
--
local luacache = (_G.__luacache or {}).cache

local reload = function(self,what)
  what = what or 'project-tools'

  local pattern = "^" .. vim.pesc(what) .. "%."

  if luacache then
    luacache[what] = nil
  end

  if package.loaded[what] then
    package.loaded[what] = nil
  end

  for pack, _ in pairs(package.loaded) do
    if string.find(pack, pattern) then
      package.loaded[pack] = nil

      if luacache then
        luacache[pack] = nil
      end
    end
  end

  if what == 'project-tools' then
    for key,_ in pairs(self) do
      rawset(self, key, nil)
    end

    self._lang = false
  end
end

return reload
