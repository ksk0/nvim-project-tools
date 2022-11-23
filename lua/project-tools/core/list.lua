local M = {}
local extend_list = vim.fn.extend

-- ============================================================================
-- list functions
--
local count_members = function(list)
  local slist = list or {}
  local count = {}

  for _,v in ipairs(slist) do
    count[v] = count[v] and count[v] + 1 or 1
  end

  return count
end

M.union = function(list_a, list_b)
  local union = {}
  local result = {}
  local slist_a = list_a or {}
  local slist_b = list_b or {}

  for _,v in ipairs(extend_list(slist_a, slist_b)) do
    if not union[v] then
      table.insert(result, v)
      union[v] = true
    end
  end

  return result
end

M.intersection = function(list_a, list_b)
  local slist_a = list_a or {}
  local slist_b = list_b or {}
  local count = count_members(extend_list(slist_a, slist_b))
  local result = {}

  for _,v in ipairs(slist_a) do
    if count[v] > 1 then
      table.insert(result, v)
    end
  end

  return result
end

M.sub = function(list_a, list_b)
  local slist_a = list_a or {}
  local slist_b = list_b or {}
  local section = M.intersection(slist_a, slist_b)
  local count = count_members(extend_list(slist_a, section))
  local result = {}

  for _,v in ipairs(slist_a) do
    if count[v] == 1 then

      table.insert(result, v)
    end
  end

  return result
end

M.reverse = function (list)
  local reversed = {}
  local slist = list or {}

  for i=#slist,1,-1 do
    table.insert(reversed,slist[i])
  end

  return reversed
end

return M


