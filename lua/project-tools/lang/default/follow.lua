local list = require('project-tools.core.list')
local fn = vim.fn
local api = vim.api

-- ============================================
-- parse and check options
--
local check_event = function(name, event)
  if type(event) ~= 'table' then
    error('follow [' .. name .. ']: must be table of options', 5)
  end

  local opts = vim.tbl_keys(event)
  local invalid = list.sub(opts, {"action", "once"})

  if #invalid ~= 0 then
    local invalids = '"' .. fn.join(invalid, '", "') .. '"'
    error('follow [' .. name .. ']: invalid option(s): ' .. invalids, 5)
  end

  if event.action == nil then
    error('follow [' .. name .. ']: "action" must be given', 5)
  end

  if type(event.action) ~= 'function' then
    error('follow [' .. name .. ']: "action" must be function', 5)
  end

  if event.once ~= nil and type(event.once) ~= 'boolean' then
    error('follow [' .. name .. ']: "once" option is boolean', 5)
  end
end

local check_options = function(options)
  if type(options) ~= 'table' then
    error('follow: Options must be table of options',4)
  end

  local opts = vim.tbl_keys(options)
  local invalid = list.sub(opts, {"enter", "leave", "init"})

  if #invalid ~= 0 then
    local invalids = '"' .. fn.join(invalid, '", "') .. '"'
    error('follow: invalid option(s): ' .. invalids, 4)
  end

  if options.init ~= nil and type(options.init) ~= 'boolean' then
    error('follow: "init" option is boolean', 5)
  end

  if (not options.enter) and (not options.leave) then
    error('follow: give eather "enter" or "leave" option or both', 4)
  end


  if options.enter then
    check_event("enter", options.enter)
  end

  if options.leave then
    check_event("leave", options.leave)
  end
end

local parse_event = function(event)
  if event.once == nil then
    event.once = true
  end
end

local parse_options = function(options)
  check_options(options)

  if options.init == nil then
    options.init = true
  end

  if options.enter then
    parse_event(options.enter)
  end

  if options.leave then
    parse_event(options.leave)
  end
end


-- ============================================
-- worker functions
--
local buff_worker = function(event)
  if not event then return end
  local buffer = api.nvim_get_current_buf()

  if event.done and event.done[buffer] then return end

  event.action(buffer)

  if event.once then
    event.done = event.done or {}
    event.done[buffer] = true
  end
end

local buff_enter_worker = function(self)
  return function()
    local follower_no = #self._followers
    if follower_no == 0 then return end

    buff_worker(self._followers[follower_no].enter)
  end
end

local buff_leave_worker = function(self)
  return function()
    local follower_no = #self._followers
    if follower_no == 0 then return end

    buff_worker(self._followers[follower_no].leave)
  end
end


-- ============================================
-- main functions
--
local init_folowers = function(self, options)
  self._followers = self._followers or {}

  local options_copy = vim.deepcopy(options)
  table.insert(self._followers, options_copy)

  local gid  = api.nvim_create_augroup("NvimProjectTools",{})
  local cmds = api.nvim_get_autocmds({group = gid})

  -- print(vim.inspect(cmds))

  if #cmds ~= 0 then return end

  local enter_opts = {
    group = gid,
    pattern = '*',
    callback = buff_enter_worker(self)
  }

  local leave_opts = {
    group = gid,
    pattern = '*',
    callback = buff_leave_worker(self)
  }

  api.nvim_create_autocmd("BufEnter", enter_opts)
  api.nvim_create_autocmd("BufLeave", leave_opts)

  if options.enter and options.init then
    buff_worker(options_copy.enter)
  end
end

local follow = function(self,options)
  parse_options(options)
  init_folowers(self,options)
end

return follow
