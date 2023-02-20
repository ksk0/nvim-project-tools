local api = vim.api

local unfollow = function(self)
  local follower_no = #self._followers

  if follower_no == 0 then
    return
  end

  self._followers[follower_no] = nil

  if follower_no == 1 then
    api.nvim_del_augroup_by_name('NvimProjectTools')
  end
end

return unfollow
