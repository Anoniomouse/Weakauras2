-- Minimal busted-compatible runner for tests/midnight.
-- Usage (from repo root): lua tests/midnight/run_tests.lua
-- Use real busted instead when available: busted tests/midnight/

local passed, failed = 0, 0
local failures = {}
local descStack = {}
local beforeEachStack = {}

local function currentName(name)
  local parts = {}
  for _, d in ipairs(descStack) do parts[#parts + 1] = d end
  parts[#parts + 1] = name
  return table.concat(parts, " :: ")
end

function describe(name, fn)
  descStack[#descStack + 1] = name
  beforeEachStack[#beforeEachStack + 1] = {}
  fn()
  table.remove(descStack)
  table.remove(beforeEachStack)
end

function setup(fn)
  fn()
end

function before_each(fn)
  local block = beforeEachStack[#beforeEachStack]
  block[#block + 1] = fn
end

function it(name, fn)
  local ok, err = pcall(function()
    for _, block in ipairs(beforeEachStack) do
      for _, hook in ipairs(block) do
        hook()
      end
    end
    fn()
  end)
  if ok then
    passed = passed + 1
  else
    failed = failed + 1
    failures[#failures + 1] = currentName(name) .. "\n    " .. tostring(err)
    io.write("FAIL: ", currentName(name), "\n")
  end
end

-- busted-style assertions on top of Lua's assert
local rawassert = assert
assert = setmetatable({
  equals = function(expected, actual, msg)
    if expected ~= actual then
      error((msg or "assert.equals failed") ..
        (": expected %s, got %s"):format(tostring(expected), tostring(actual)), 2)
    end
  end,
  is_true = function(v, msg)
    if v ~= true then
      error((msg or "assert.is_true failed") .. (": got %s"):format(tostring(v)), 2)
    end
  end,
  is_false = function(v, msg)
    if v ~= false then
      error((msg or "assert.is_false failed") .. (": got %s"):format(tostring(v)), 2)
    end
  end,
  is_nil = function(v, msg)
    if v ~= nil then
      error((msg or "assert.is_nil failed") .. (": got %s"):format(tostring(v)), 2)
    end
  end,
  is_not_nil = function(v, msg)
    if v == nil then
      error(msg or "assert.is_not_nil failed: got nil", 2)
    end
  end,
}, { __call = function(_, ...) return rawassert(...) end })

-- Discover and run all test files in this directory
local sep = package.config:sub(1, 1)
local pattern = "tests" .. sep .. "midnight" .. sep .. "test_*.lua"
local cmd
if sep == "\\" then
  cmd = 'dir /b "tests\\midnight\\test_*.lua"'
else
  cmd = 'ls tests/midnight/test_*.lua'
end
local files = {}
local pipe = io.popen(cmd)
for line in pipe:lines() do
  local fname = line:match("(test_[%w_]+%.lua)$")
  if fname then files[#files + 1] = "tests/midnight/" .. fname end
end
pipe:close()
table.sort(files)

if #files == 0 then
  io.write("No test files found; run from the repo root.\n")
  os.exit(1)
end

for _, file in ipairs(files) do
  io.write("== ", file, "\n")
  local chunk, err = loadfile(file)
  if not chunk then
    failed = failed + 1
    failures[#failures + 1] = file .. "\n    load error: " .. tostring(err)
    io.write("FAIL (load): ", file, "\n")
  else
    local ok, runErr = pcall(chunk)
    if not ok then
      failed = failed + 1
      failures[#failures + 1] = file .. "\n    runtime error: " .. tostring(runErr)
      io.write("FAIL (run): ", file, "\n")
    end
  end
end

io.write(("\n%d passed, %d failed\n"):format(passed, failed))
if failed > 0 then
  io.write("\nFailures:\n")
  for _, f in ipairs(failures) do
    io.write("  - ", f, "\n")
  end
  os.exit(1)
end
