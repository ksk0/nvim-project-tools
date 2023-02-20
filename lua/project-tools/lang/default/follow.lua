local list = require('project-tools.core.list')
local fn = vim.fn
local api = vim.api

-- ============================================
-- parse and check options
--
local check_event = function(options, event)
  local e_options = options[event]
  if type(e_options) ~= 'table' then
    error('follow [' .. event .. ']: must be table of options', 5)
  end

  local opts = vim.tbl_keys(e_options)
  local invalid = list.sub(opts, {"action", "once"})

  if #invalid ~= 0 then
    local invalids = '"' .. fn.join(invalid, '", "') .. '"'
    error('follow [' .. event .. ']: invalid option(s): ' .. invalids, 5)
  end

  if e_options.action == nil then
    error('follow [' .. event .. ']: "action" must be given', 5)
  end

  if type(e_options.action) ~= 'function' then
    error('follow [' .. event .. ']: "action" must be function', 5)
  end

  if e_options.once ~= nil and type(e_options.once) ~= 'boolean' then
    error('follow [' .. event .. ']: "once" option is boolean', 5)
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
    check_event(options, "enter")
  end

  if options.leave then
    check_event(options, "leave")
  end
end

local parse_event = function(e_options)
  if e_options.once == nil then
    e_options.once = true
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
local buff_event_worker = function(self, event)
  local follower_no = #self._followers
  if follower_no == 0 then return end

  local e_options = self._followers[follower_no][event]
  if not e_options then return end

  local buffer = api.nvim_get_current_buf()

  if fn.getbufvar(buffer,'&filetype') ~= self._lang then
    return
  end

  if e_options.done and e_options.done[buffer] then return end

  e_options.action(buffer)

  if e_options.once then
    e_options.done = e_options.done or {}
    e_options.done[buffer] = true
  end
end

local buff_enter_worker = function(self)
  return function()
    buff_event_worker(self, 'enter')

    -- local follower_no = #self._followers
    -- if follower_no == 0 then return end
    --
    -- buff_event_worker(self, self._followers[follower_no].enter)
  end
end

local buff_leave_worker = function(self)
  return function()
    buff_event_worker(self, 'leave')

    -- local follower_no = #self._followers
    -- if follower_no == 0 then return end
    --
    -- buff_event_worker(self, self._followers[follower_no].leave)
  end
end


-- ============================================
-- main functions
--
local init_folowers = function(self, options)
  self._followers = self._followers or {}

  table.insert(self._followers, vim.deepcopy(options))

  local gid  = api.nvim_create_augroup("NvimProjectTools",{})
  local cmds = api.nvim_get_autocmds({group = gid})

  -- print(vim.inspect(cmds))

  if #cmds ~= 0 then return end

  local enter_worker = buff_enter_worker(self)
  local leave_worker = buff_leave_worker(self)

  local enter_opts = {
    group = gid,
    pattern = '*',
    callback = enter_worker,
  }

  local leave_opts = {
    group = gid,
    pattern = '*',
    callback = leave_worker,
  }

  api.nvim_create_autocmd("BufEnter", enter_opts)
  api.nvim_create_autocmd("BufLeave", leave_opts)

  if options.enter and options.init then
    enter_worker()
  end
end

local follow = function(self,options)
  parse_options(options)
  init_folowers(self,options)
end

return follow
