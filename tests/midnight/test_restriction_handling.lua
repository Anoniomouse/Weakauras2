-- Tests for Phase 6: Addon Restriction State handling
-- Validates WeakAuras responds to ADDON_RESTRICTION_STATE_CHANGED in Midnight

describe("Addon Restriction State Handling (Midnight)", function()
  local mock = require("tests.midnight.mock_wow_api")

  describe("C_RestrictedActions", function()
    it("IsAddOnRestrictionActive returns false when not restricted", function()
      mock.SetRestrictionActive(false)
      assert.is_false(C_RestrictedActions.IsAddOnRestrictionActive(0))
    end)

    it("IsAddOnRestrictionActive returns true when restricted", function()
      mock.SetRestrictionActive(true)
      assert.is_true(C_RestrictedActions.IsAddOnRestrictionActive(0))
      mock.SetRestrictionActive(false)
    end)

    it("GetAddOnRestrictionState returns Inactive (0) when not restricted", function()
      mock.SetRestrictionActive(false)
      assert.equals(0, C_RestrictedActions.GetAddOnRestrictionState(0))
    end)

    it("GetAddOnRestrictionState returns Active (2) when restricted", function()
      mock.SetRestrictionActive(true)
      assert.equals(2, C_RestrictedActions.GetAddOnRestrictionState(0))
      mock.SetRestrictionActive(false)
    end)
  end)

  describe("WeakAuras.lua ADDON_RESTRICTION_STATE_CHANGED registration", function()
    it("WeakAuras.IsMidnight() returns true for Midnight build", function()
      assert.is_true(WeakAuras.IsMidnight())
    end)

    it("IsMidnight() returns false for pre-Midnight build info", function()
      local savedBuildInfo = WeakAuras.BuildInfo
      WeakAuras.BuildInfo = 110200  -- TWW
      assert.is_false(WeakAuras.IsMidnight())
      WeakAuras.BuildInfo = savedBuildInfo
    end)
  end)

  describe("CLEU unrestricted in Midnight", function()
    it("C_CombatLog.IsCombatLogRestricted returns false for normal addons", function()
      -- C_CombatLog.IsCombatLogRestricted tells addons whether they can access CLEU
      -- In Midnight, untainted addons use INTERNAL_UNFILTERED instead
      assert.is_false(C_CombatLog.IsCombatLogRestricted())
    end)
  end)
end)
