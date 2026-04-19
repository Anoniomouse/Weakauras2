if (GAME_LOCALE or GetLocale()) ~= "zhTW" then
  return
end

local L = WeakAuras.L

L["Cooldown timer accuracy is reduced in combat due to WoW 12.x API restrictions. Use 'Not on Cooldown' to reliably show/hide based on cooldown state."] = "由於 WoW 12.x API 限制，戰鬥中冷卻計時器精確度降低。使用「未冷卻中」可根據冷卻狀態可靠地顯示或隱藏。"

