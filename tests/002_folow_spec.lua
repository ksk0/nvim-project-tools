-- ============================================
-- aserts:
--   is     - test is true
--   is_not - test is not true
--   is_nil - test is nil
--   has    - same as is
--
--   equal  - comparing if same object
--   same   - comparing if content of object are same
--
--   no.errors   - run without errors
--   has.errors  - run with errors
--
-- eqaul objects:
--   A = {element = 1}
--   B = A
--
-- same objects:
--   A = {element = 1}
--   B = {element = 1}
--
print()
describe("Load module:", function ()
  it("Regular [OK]", function ()
    assert.no.errors(function() M = require("project-tools") end)
  end)
end)

print()
describe("Follow - options:", function ()
  it("Options must be table of options [ERROR]", function ()
    local ok,msg = pcall(M.follow, M)

    assert.is_not_true(ok)
    assert.not_equal(nil, msg:match('follow: Options must be table of options'))
  end)

  it('Invalid option "foo" [ERROR]', function ()
    local ok,msg = pcall(M.follow, M, {foo = true, bar = true})

    assert.is_not_true(ok)
    assert.not_equal(nil, msg:match('follow: invalid option%(s%):'))
  end)

  it('"init" is string ("A") [ERROR]', function ()
    local ok,msg = pcall(M.follow, M, {init = 'A'})

    assert.is_not_true(ok)
    assert.not_equal(nil, msg:match('follow: "init" option is boolean'))
  end)

  -- it('"leave" is string ("A") [ERROR]', function ()
  --   local ok,msg = pcall(M.follow, M, {leave = 'A'})
  --
  --   assert.is_not_true(ok)
  --   assert.not_equal(nil, msg:match('follow %[leave%]: option must be table'))
  -- end)

  it('neather "enter" not "leave" are given [ERROR]', function ()
    local ok,msg = pcall(M.follow, M, {})

    -- print("OK:" .. tostring(ok) .. " MSG:" .. tostring(msg))

    assert.is_not_true(ok)
    assert.not_equal(nil, msg:match('follow: give eather "enter" or "leave" option or both'))
  end)

  -- it('"enter" is table [OK]', function ()
  --   assert.no.errors(function() M:follow({enter = {}}) end)
  -- end)
  --
  -- it('"leave" is table [OK]', function ()
  --   assert.no.errors(function() M:follow({enter = {}}) end)
  -- end)

end)

print()
describe('Follow - event:', function ()
  it("Event must be table of options [ERROR]", function ()
    local ok,msg = pcall(M.follow, M, {enter = "A"})

    assert.is_not_true(ok)
    assert.not_equal(nil, msg:match('follow %[enter%]: must be table of options'))
  end)

  it('Invalid option "foo" [ERROR]', function ()
    local ok,msg = pcall(M.follow, M, {enter = {foo = true}})

    assert.is_not_true(ok)
    assert.not_equal(nil, msg:match('follow %[enter%]: invalid option%(s%):'))
  end)

  it('"action" must be given [ERROR]', function ()
    local ok,msg = pcall(M.follow, M, {enter = {once = true}})

    assert.is_not_true(ok)
    assert.not_equal(nil, msg:match('follow %[enter%]: "action" must be given'))
  end)

  it('"action" is string ("A") [ERROR]', function ()
    local opts = {
      enter = {
        action = "A",
        once = true,
      }
    }

    local ok,msg = pcall(M.follow, M, opts)

    assert.is_not_true(ok)
    assert.not_equal(nil, msg:match('follow %[enter%]: "action" must be function'))
  end)

  it('"once" is string ("A") [ERROR]', function ()
    local opts = {
      enter = {
        action = function() end,
        once = "A",
      }
    }

    local ok,msg = pcall(M.follow, M, opts)

    assert.is_not_true(ok)
    assert.not_equal(nil, msg:match('follow %[enter%]: "once" option is boolean'))
  end)

  it('"enter" event is OK [OK]', function ()
    local opts = {
      enter = {
        action = function() end,
        once = true,
      }
    }

    assert.no.errors(function() M:follow(opts) end)
  end)

  it('"leave" event is OK [OK]', function ()
    local opts = {
      leave = {
        action = function() end,
        once = true,
      }
    }

    assert.no.errors(function() M:follow(opts) end)
  end)
end)

