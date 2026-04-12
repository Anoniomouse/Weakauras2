# Midnight Compatibility Tests

These tests validate WeakAuras2 compatibility with the WoW Midnight expansion (Interface 120001).

## Running Tests

Install [busted](https://lunarmodules.github.io/busted/) via LuaRocks:

```
luarocks install busted
```

Run all Midnight tests from the repo root:

```
busted tests/midnight/
```

Or run a specific test file:

```
busted tests/midnight/test_cleu_migration.lua
```

## Test Files

| File | Phase | What it validates |
|------|-------|-------------------|
| `test_toc_files.lua` | Phase 1.1 | All 5 `_Mainline.toc` files exist with correct Interface/flavor/gameType |
| `test_init_block_removed.lua` | Phase 1.2 | Midnight load block removed from Init.lua; `WeakAuras.CLEU_EVENT` defined |
| `test_cleu_migration.lua` | Phase 2 | `COMBAT_LOG_EVENT_INTERNAL_UNFILTERED` used in Midnight; fallback to old event on pre-Midnight |
| `test_unit_auras.lua` | Phase 3 | `C_UnitAuras.GetAuraDataByIndex`, `AuraUtil.UnpackAuraData` behave correctly |
| `test_spell_apis.lua` | Phase 4 | `C_Spell.GetSpellInfo`, `GetSpellCooldown`, `GetSpellCharges` and their compat shims |
| `test_restriction_handling.lua` | Phase 6 | `C_RestrictedActions` and `ADDON_RESTRICTION_STATE_CHANGED` handling |

## Mock API

`mock_wow_api.lua` provides stubs for Midnight-era WoW globals:
- `C_CombatLogInternal` — unrestricted combat log
- `C_UnitAuras` — aura API with `SetMockAuras(unit, auras)` helper
- `C_Spell` — spell info/cooldown API with `SetMockSpell(id, info)` helper
- `C_RestrictedActions` — restriction state with `SetRestrictionActive(bool)` helper
- `AuraUtil.UnpackAuraData` — legacy multi-return unpacker
