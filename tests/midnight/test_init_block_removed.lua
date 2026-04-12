-- Tests for Phase 1.2: Init.lua Midnight load block removal
-- Validates the blocking code is no longer present

describe("Init.lua Midnight Load Block (Phase 1.2)", function()
  local function readFile(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local content = f:read("*a")
    f:close()
    return content
  end

  local content

  setup(function()
    content = readFile("WeakAuras/Init.lua")
  end)

  it("Init.lua exists", function()
    assert.is_not_nil(content)
  end)

  it("does not contain the Midnight load block (libsAreOk = false)", function()
    assert.is_nil(content:match("IsMidnight%(%)"),
      "Should not have IsMidnight() check that sets libsAreOk = false")
  end)

  it("does not contain the erroneous IsTWW() Midnight message", function()
    assert.is_nil(content:match("does not support Midnight"),
      "Should not contain 'does not support Midnight' message")
  end)

  it("still has the missing libraries check", function()
    assert.is_not_nil(content:match("WeakAuras is missing necessary libraries"),
      "Should still have the library check message")
  end)

  it("still has the IsWrathClassic() CN server message", function()
    assert.is_not_nil(content:match("IsWrathClassic"),
      "Should still have the Wrath CN server warning")
  end)

  it("defines WeakAuras.CLEU_EVENT", function()
    assert.is_not_nil(content:match("WeakAuras%.CLEU_EVENT"),
      "Should define WeakAuras.CLEU_EVENT for combat log event selection")
  end)

  it("WeakAuras.CLEU_EVENT uses C_CombatLogInternal when available", function()
    assert.is_not_nil(content:match("COMBAT_LOG_EVENT_INTERNAL_UNFILTERED"),
      "Should reference COMBAT_LOG_EVENT_INTERNAL_UNFILTERED for Midnight")
  end)
end)
