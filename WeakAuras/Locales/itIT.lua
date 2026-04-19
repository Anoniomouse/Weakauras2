if (GAME_LOCALE or GetLocale()) ~= "itIT" then
  return
end

local L = WeakAuras.L

L["Cooldown timer accuracy is reduced in combat due to WoW 12.x API restrictions. Use 'Not on Cooldown' to reliably show/hide based on cooldown state."] = "La precisione del timer di ricarica è ridotta in combattimento a causa delle restrizioni dell'API di WoW 12.x. Usa 'Non in ricarica' per mostrare o nascondere in modo affidabile in base allo stato di ricarica."

