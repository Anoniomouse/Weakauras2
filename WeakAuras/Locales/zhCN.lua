if (GAME_LOCALE or GetLocale()) ~= "zhCN" then
  return
end

local L = WeakAuras.L

L["Cooldown timer accuracy is reduced in combat due to WoW 12.x API restrictions. Use 'Not on Cooldown' to reliably show/hide based on cooldown state."] = "由于 WoW 12.x API 限制，战斗中冷却计时器精度降低。使用「未冷却中」可根据冷却状态可靠地显示或隐藏。"

