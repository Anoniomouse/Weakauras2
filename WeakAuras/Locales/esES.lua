if (GAME_LOCALE or GetLocale()) ~= "esES" then
  return
end

local L = WeakAuras.L

L["Cooldown timer accuracy is reduced in combat due to WoW 12.x API restrictions. Use 'Not on Cooldown' to reliably show/hide based on cooldown state."] = "La precisión del temporizador de recarga se reduce en combate debido a las restricciones de la API de WoW 12.x. Usa 'No en recarga' para mostrar u ocultar de forma fiable según el estado de recarga."

