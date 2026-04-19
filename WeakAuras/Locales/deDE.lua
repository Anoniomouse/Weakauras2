if (GAME_LOCALE or GetLocale()) ~= "deDE" then
  return
end

local L = WeakAuras.L

L["Cooldown timer accuracy is reduced in combat due to WoW 12.x API restrictions. Use 'Not on Cooldown' to reliably show/hide based on cooldown state."] = "Die Genauigkeit des Abklingzeit-Timers ist im Kampf aufgrund von WoW 12.x API-Einschränkungen verringert. Verwende 'Nicht auf Abklingzeit', um die Anzeige zuverlässig vom Abklingzeitstatus abhängig zu machen."

