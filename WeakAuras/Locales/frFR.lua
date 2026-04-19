if (GAME_LOCALE or GetLocale()) ~= "frFR" then
  return
end

local L = WeakAuras.L

L["Cooldown timer accuracy is reduced in combat due to WoW 12.x API restrictions. Use 'Not on Cooldown' to reliably show/hide based on cooldown state."] = "La précision du minuteur de recharge est réduite en combat en raison des restrictions de l'API WoW 12.x. Utilisez 'Hors recharge' pour afficher ou masquer de manière fiable selon l'état de recharge."

