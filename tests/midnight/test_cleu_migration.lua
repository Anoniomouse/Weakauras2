-- Tests for Phase 2: Combat Log Event migration
-- Validates COMBAT_LOG_EVENT_INTERNAL_UNFILTERED usage in Midnight

describe("Combat Log Event Migration (Midnight)", function()
  local mock = require("tests.midnight.mock_wow_api")

  describe("CLEU_EVENT selection", function()
    it("uses COMBAT_LOG_EVENT_INTERNAL_UNFILTERED when C_CombatLogInternal exists", function()
      -- Simulate Midnight: C_CombatLogInternal is present
      local cleuEvent = (C_CombatLogInternal and "COMBAT_LOG_EVENT_INTERNAL_UNFILTERED")
                        or "COMBAT_LOG_EVENT_UNFILTERED"
      assert.equals("COMBAT_LOG_EVENT_INTERNAL_UNFILTERED", cleuEvent)
    end)

    it("falls back to COMBAT_LOG_EVENT_UNFILTERED on pre-Midnight clients", function()
      -- Simulate pre-Midnight: C_CombatLogInternal not present
      local saved = C_CombatLogInternal
      C_CombatLogInternal = nil
      local cleuEvent = (C_CombatLogInternal and "COMBAT_LOG_EVENT_INTERNAL_UNFILTERED")
                        or "COMBAT_LOG_EVENT_UNFILTERED"
      assert.equals("COMBAT_LOG_EVENT_UNFILTERED", cleuEvent)
      C_CombatLogInternal = saved
    end)

    it("WeakAuras.CLEU_EVENT is set correctly for Midnight", function()
      assert.equals("COMBAT_LOG_EVENT_INTERNAL_UNFILTERED", WeakAuras.CLEU_EVENT)
    end)
  end)

  describe("CombatLogGetCurrentEventInfo fallback", function()
    it("uses C_CombatLogInternal.GetCurrentEventInfo when global is missing", function()
      -- Simulate Midnight where CombatLogGetCurrentEventInfo global is gone
      local savedGlobal = CombatLogGetCurrentEventInfo
      CombatLogGetCurrentEventInfo = nil

      local fn = CombatLogGetCurrentEventInfo
                 or (C_CombatLogInternal and C_CombatLogInternal.GetCurrentEventInfo)
      assert.is_not_nil(fn)
      assert.equals(C_CombatLogInternal.GetCurrentEventInfo, fn)

      CombatLogGetCurrentEventInfo = savedGlobal
    end)

    it("prefers CombatLogGetCurrentEventInfo global when available (pre-Midnight)", function()
      local mockGlobal = function() return "timestamp", "SPELL_DAMAGE" end
      CombatLogGetCurrentEventInfo = mockGlobal

      local fn = CombatLogGetCurrentEventInfo
                 or (C_CombatLogInternal and C_CombatLogInternal.GetCurrentEventInfo)
      assert.equals(mockGlobal, fn)

      CombatLogGetCurrentEventInfo = nil
    end)
  end)

  describe("C_CombatLogInternal.GetCurrentEventInfo", function()
    it("returns nil when no current event is set", function()
      C_CombatLogInternal._currentEvent = nil
      local result = C_CombatLogInternal.GetCurrentEventInfo()
      assert.is_nil(result)
    end)

    it("returns event data when current event is set", function()
      C_CombatLogInternal._currentEvent = { 1234567.0, "SPELL_DAMAGE", 0, "PlayerGUID", "Player", 0x512, 0, "TargetGUID", "Target", 0x10a48, 0, 12345, "Fireball", 4, 500, 0, -1, 1, nil, nil, nil }
      local timestamp, subEvent = C_CombatLogInternal.GetCurrentEventInfo()
      assert.equals(1234567.0, timestamp)
      assert.equals("SPELL_DAMAGE", subEvent)
      C_CombatLogInternal._currentEvent = nil
    end)
  end)
end)
