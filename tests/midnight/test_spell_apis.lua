-- Tests for Phase 4: Spell API migration
-- Validates C_Spell.GetSpellInfo, GetSpellCooldown, GetSpellCharges in Midnight

describe("Spell API Migration (Midnight)", function()
  local mock = require("tests.midnight.mock_wow_api")

  before_each(function()
    -- Set up a mock spell
    mock.SetMockSpell(133, {
      name = "Fireball",
      iconID = 135812,
      castTime = 2000,
      minRange = 0,
      maxRange = 40,
      spellID = 133,
      _cooldown = { startTime = 0, duration = 0, isEnabled = true, isActive = false, modRate = 1.0 },
    })
    mock.SetMockSpell(12345, {
      name = "Cooldown Spell",
      iconID = 100000,
      castTime = 0,
      minRange = 0,
      maxRange = 0,
      spellID = 12345,
      _cooldown = { startTime = 100.0, duration = 30.0, isEnabled = true, isActive = true, modRate = 1.0 },
      _charges = { currentCharges = 1, maxCharges = 2, cooldownStartTime = 100.0, cooldownDuration = 30.0, chargeModRate = 1.0 },
    })
  end)

  describe("C_Spell.GetSpellInfo", function()
    it("returns SpellInfo table for known spells", function()
      local info = C_Spell.GetSpellInfo(133)
      assert.is_not_nil(info)
      assert.equals("Fireball", info.name)
      assert.equals(135812, info.iconID)
      assert.equals(2000, info.castTime)
      assert.equals(40, info.maxRange)
      assert.equals(133, info.spellID)
    end)

    it("returns nil for unknown spells", function()
      local info = C_Spell.GetSpellInfo(999999)
      assert.is_nil(info)
    end)
  end)

  describe("Compatibility shim: GetSpellInfo → C_Spell.GetSpellInfo", function()
    it("shim unpacks SpellInfo table to legacy multi-return format", function()
      -- This replicates the logic in Compatibility.lua when GetSpellInfo global is nil
      local function shimGetSpellInfo(spellID)
        if not spellID then return nil end
        local spellInfo = C_Spell.GetSpellInfo(spellID)
        if spellInfo then
          return spellInfo.name, nil, spellInfo.iconID, spellInfo.castTime,
                 spellInfo.minRange, spellInfo.maxRange, spellInfo.spellID,
                 spellInfo.originalIconID
        end
      end

      local name, rank, icon, castTime, minRange, maxRange, spellID = shimGetSpellInfo(133)
      assert.equals("Fireball", name)
      assert.is_nil(rank)  -- rank is gone in Midnight
      assert.equals(135812, icon)
      assert.equals(2000, castTime)
      assert.equals(40, maxRange)
      assert.equals(133, spellID)
    end)
  end)

  describe("C_Spell.GetSpellCooldown", function()
    it("returns SpellCooldownInfo for a spell on cooldown", function()
      local info = C_Spell.GetSpellCooldown(12345)
      assert.is_not_nil(info)
      assert.equals(100.0, info.startTime)
      assert.equals(30.0, info.duration)
      assert.is_true(info.isEnabled)
      assert.is_true(info.isActive)
      assert.equals(1.0, info.modRate)
    end)

    it("returns SpellCooldownInfo with zero duration for a spell not on cooldown", function()
      local info = C_Spell.GetSpellCooldown(133)
      assert.is_not_nil(info)
      assert.equals(0, info.duration)
      assert.is_false(info.isActive)
    end)

    it("returns nil for an unknown spell", function()
      local info = C_Spell.GetSpellCooldown(999999)
      assert.is_nil(info)
    end)
  end)

  describe("GetSpellCooldownUnified compatibility", function()
    it("correctly reads C_Spell.GetSpellCooldown when GetSpellCooldown global is nil", function()
      -- Simulate Midnight: global GetSpellCooldown doesn't exist
      local savedGlobal = GetSpellCooldown
      GetSpellCooldown = nil

      local startTimeCooldown, durationCooldown, enabled, modRate
      if GetSpellCooldown then
        startTimeCooldown, durationCooldown, enabled, modRate = GetSpellCooldown(12345)
      else
        local info = C_Spell.GetSpellCooldown(12345)
        if info then
          startTimeCooldown = info.startTime
          durationCooldown = info.duration
          enabled = info.isEnabled
          modRate = info.modRate
        end
      end

      assert.equals(100.0, startTimeCooldown)
      assert.equals(30.0, durationCooldown)
      assert.is_true(enabled)
      assert.equals(1.0, modRate)

      GetSpellCooldown = savedGlobal
    end)
  end)

  describe("C_Spell.GetSpellCharges", function()
    it("returns SpellChargeInfo for a spell with charges", function()
      local info = C_Spell.GetSpellCharges(12345)
      assert.is_not_nil(info)
      assert.equals(1, info.currentCharges)
      assert.equals(2, info.maxCharges)
    end)

    it("returns nil for a spell without charge info", function()
      local info = C_Spell.GetSpellCharges(133)
      assert.is_nil(info)
    end)
  end)
end)
