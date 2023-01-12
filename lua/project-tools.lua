-- lazy load project-tools
--
return setmetatable({}, {
  __index = function(t, k)
    local module = "project-tools." .. k
    local ok,val = pcall(require, module)

    if ok then
      rawset(t, k, val)
    else
      val = nil
    end

    return val
  end,
})
