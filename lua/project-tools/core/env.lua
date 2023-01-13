-- core/env
--
local extend_var = function (var_value, ext_value, separator, prepend)
  if not ext_value then return var_value end

  separator = separator or ":"

  if not var_value then
    return ext_value
  end

  local var_values = vim.split(var_value, separator)
  local new_value = var_value

  if not vim.tbl_contains(var_values, ext_value) then
    if prepend then
      new_value = ext_value .. separator .. var_value
    else
      new_value = var_value .. separator .. ext_value
    end
  end

  return new_value
end

local M = {}

M.append_var = function (var_value, ext_value, separator)
  return extend_var (var_value, ext_value, separator, false)
end

M.prepend_var = function (var_value, ext_value, separator)
  return extend_var (var_value, ext_value, separator, true)
end

M.append = function (name, path, separator)
  vim.env[name] = extend_var (vim.env[name], path, separator, false)
end

M.prepend = function (name, path, separator)
  vim.env[name] = extend_var (vim.env[name], path, separator, true)
end

return M
