-- Mock WoW API for Midnight compatibility testing
-- Simulates Midnight-era globals: C_CombatLogInternal, C_UnitAuras, C_Spell, etc.

local M = {}

-- ============================================================
-- WeakAuras stub (minimal, for testing Init.lua logic)
-- ============================================================
WeakAuras = WeakAuras or {}
WeakAuras.BuildInfo = 120001  -- Midnight
WeakAuras.CLEU_EVENT = "COMBAT_LOG_EVENT_INTERNAL_UNFILTERED"

function WeakAuras.IsRetail() return true end
function WeakAuras.IsMidnight() return WeakAuras.BuildInfo >= 120000 end
function WeakAuras.IsTWW() return WeakAuras.BuildInfo >= 110000 end
function WeakAuras.IsClassicEra() return false end
function WeakAuras.IsMists() return false end
function WeakAuras.IsPaused() return false end

-- ============================================================
-- C_CombatLogInternal (Midnight unrestricted combat log)
-- ============================================================
C_CombatLogInternal = {
  _currentEvent = nil,
  GetCurrentEventInfo = function()
    if C_CombatLogInternal._currentEvent then
      return table.unpack(C_CombatLogInternal._currentEvent)
    end
  end,
}

-- ============================================================
-- C_CombatLog (Midnight filtered combat log)
-- ============================================================
C_CombatLog = {
  IsCombatLogRestricted = function() return false end,
}

-- ============================================================
-- C_UnitAuras (Midnight aura API)
-- ============================================================
local _mockAuras = {}
C_UnitAuras = {
  GetAuraDataByIndex = function(unit, index, filter)
    local unitAuras = _mockAuras[unit]
    if not unitAuras then return nil end
    local filtered = {}
    for _, aura in ipairs(unitAuras) do
      local matchFilter = true
      if filter then
        local f = filter:upper()
        if f:find("HELPFUL") and not aura.isHelpful then matchFilter = false end
        if f:find("HARMFUL") and not aura.isHarmful then matchFilter = false end
      end
      if matchFilter then
        filtered[#filtered + 1] = aura
      end
    end
    return filtered[index]
  end,
  GetPlayerAuraBySpellID = function(spellID)
    local unit = "player"
    local unitAuras = _mockAuras[unit] or {}
    for _, aura in ipairs(unitAuras) do
      if aura.spellId == spellID then return aura end
    end
    return nil
  end,
}

function M.SetMockAuras(unit, auras)
  _mockAuras[unit] = auras
end

-- ============================================================
-- AuraUtil (needed by AuraEnvironment.lua shim)
-- ============================================================
AuraUtil = {
  UnpackAuraData = function(auraData)
    if not auraData then return nil end
    return auraData.name, auraData.icon, auraData.applications, auraData.dispelName,
           auraData.duration, auraData.expirationTime, auraData.sourceUnit, auraData.isStealable,
           nil, auraData.spellId, nil, auraData.isBossAura, auraData.isFromPlayerOrPlayerPet,
           nil, auraData.timeMod
  end,
  ForEachAura = function(unit, filter, maxCount, func, buffed)
    local index = 1
    while true do
      local aura = C_UnitAuras.GetAuraDataByIndex(unit, index, filter)
      if not aura then break end
      local done = func(aura)
      if done then break end
      index = index + 1
    end
  end,
}

-- ============================================================
-- C_Spell (Midnight spell API)
-- ============================================================
local _mockSpells = {}
C_Spell = {
  GetSpellInfo = function(spellID)
    return _mockSpells[spellID]
  end,
  GetSpellCooldown = function(spellID)
    local spell = _mockSpells[spellID]
    if not spell then return nil end
    return spell._cooldown or { startTime = 0, duration = 0, isEnabled = true, isActive = false, modRate = 1.0 }
  end,
  GetSpellCharges = function(spellID)
    local spell = _mockSpells[spellID]
    if not spell then return nil end
    return spell._charges
  end,
  GetSpellName = function(spellID)
    local spell = _mockSpells[spellID]
    return spell and spell.name
  end,
  GetSpellTexture = function(spellID)
    local spell = _mockSpells[spellID]
    return spell and spell.iconID
  end,
  IsSpellUsable = function(spellID)
    return true
  end,
}

function M.SetMockSpell(spellID, info)
  _mockSpells[spellID] = info
end

-- ============================================================
-- C_RestrictedActions
-- ============================================================
local _restrictionActive = false
C_RestrictedActions = {
  IsAddOnRestrictionActive = function(restrictionType)
    return _restrictionActive
  end,
  GetAddOnRestrictionState = function(restrictionType)
    return _restrictionActive and 2 or 0  -- Active = 2, Inactive = 0
  end,
}

function M.SetRestrictionActive(active)
  _restrictionActive = active
end

-- ============================================================
-- InCombatLockdown (standard WoW global)
-- ============================================================
local _inCombat = false
function InCombatLockdown() return _inCombat end
function M.SetInCombat(combat) _inCombat = combat end

-- ============================================================
-- Other stubs needed at module load time
-- ============================================================
GetTime = GetTime or function() return 0 end
UnitGUID = UnitGUID or function(unit) return "Player-0000-00000001" end

return M
