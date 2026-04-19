if (GAME_LOCALE or GetLocale()) ~= "esMX" then
  return
end

local L = WeakAuras.L

L["Cooldown timer accuracy is reduced in combat due to WoW 12.x API restrictions. Use 'Not on Cooldown' to reliably show/hide based on cooldown state."] = "La precisión del temporizador de reutilización se reduce en combate debido a las restricciones de la API de WoW 12.x. Usa 'No en reutilización' para mostrar u ocultar de forma confiable según el estado de reutilización."

