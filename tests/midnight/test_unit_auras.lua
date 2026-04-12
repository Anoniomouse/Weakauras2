-- Tests for Phase 3: UnitAura API migration
-- Validates C_UnitAuras usage in Midnight

describe("UnitAura API Migration (Midnight)", function()
  local mock = require("tests.midnight.mock_wow_api")

  local function makeAura(overrides)
    return {
      name = "Test Aura",
      icon = 12345,
      applications = 1,
      dispelName = nil,
      duration = 10.0,
      expirationTime = 100.0,
      sourceUnit = "player",
      isStealable = false,
      spellId = 99999,
      isBossAura = false,
      isFromPlayerOrPlayerPet = true,
      timeMod = 1.0,
      isHelpful = true,
      isHarmful = false,
    }
  end

  before_each(function()
    mock.SetMockAuras("player", {})
    mock.SetMockAuras("target", {})
  end)

  describe("C_UnitAuras.GetAuraDataByIndex", function()
    it("returns nil for units with no auras", function()
      local aura = C_UnitAuras.GetAuraDataByIndex("player", 1, "HELPFUL")
      assert.is_nil(aura)
    end)

    it("returns aura data at correct index", function()
      local testAura = makeAura({ name = "Power Word: Shield" })
      mock.SetMockAuras("player", { testAura })

      local aura = C_UnitAuras.GetAuraDataByIndex("player", 1, "HELPFUL")
      assert.is_not_nil(aura)
      assert.equals("Power Word: Shield", aura.name)
    end)

    it("returns nil when index exceeds aura count", function()
      local testAura = makeAura({})
      mock.SetMockAuras("player", { testAura })

      local aura = C_UnitAuras.GetAuraDataByIndex("player", 2, "HELPFUL")
      assert.is_nil(aura)
    end)

    it("filters auras by HELPFUL vs HARMFUL", function()
      local buffAura = makeAura({ name = "Buff", isHelpful = true, isHarmful = false })
      local debuffAura = makeAura({ name = "Debuff", isHelpful = false, isHarmful = true })
      mock.SetMockAuras("player", { buffAura, debuffAura })

      local helpful = C_UnitAuras.GetAuraDataByIndex("player", 1, "HELPFUL")
      assert.equals("Buff", helpful.name)

      local harmful = C_UnitAuras.GetAuraDataByIndex("player", 1, "HARMFUL")
      assert.equals("Debuff", harmful.name)
    end)
  end)

  describe("AuraUtil.UnpackAuraData", function()
    it("unpacks AuraData table to legacy multi-return format", function()
      local testAura = makeAura({
        name = "Test Aura",
        icon = 12345,
        applications = 3,
        dispelName = "Magic",
        duration = 10.0,
        expirationTime = 100.0,
        sourceUnit = "player",
        isStealable = true,
        spellId = 99999,
        isBossAura = false,
        isFromPlayerOrPlayerPet = true,
        timeMod = 1.0,
      })

      local name, icon, stacks, debuffClass, duration, expirationTime,
            unitCaster, isStealable, _, spellId, _, isBossDebuff,
            isCastByPlayer, _, modRate = AuraUtil.UnpackAuraData(testAura)

      assert.equals("Test Aura", name)
      assert.equals(12345, icon)
      assert.equals(3, stacks)
      assert.equals("Magic", debuffClass)
      assert.equals(10.0, duration)
      assert.equals(100.0, expirationTime)
      assert.equals("player", unitCaster)
      assert.is_true(isStealable)
      assert.equals(99999, spellId)
      assert.is_false(isBossDebuff)
      assert.is_true(isCastByPlayer)
      assert.equals(1.0, modRate)
    end)

    it("returns nil for nil input", function()
      local result = AuraUtil.UnpackAuraData(nil)
      assert.is_nil(result)
    end)
  end)

  describe("C_UnitAuras.GetPlayerAuraBySpellID", function()
    it("returns nil when spell not on player", function()
      local aura = C_UnitAuras.GetPlayerAuraBySpellID(12345)
      assert.is_nil(aura)
    end)

    it("returns aura when spell is on player", function()
      local testAura = makeAura({ name = "Fireball", spellId = 133 })
      mock.SetMockAuras("player", { testAura })

      local aura = C_UnitAuras.GetPlayerAuraBySpellID(133)
      assert.is_not_nil(aura)
      assert.equals("Fireball", aura.name)
    end)
  end)
end)
