if (GAME_LOCALE or GetLocale()) ~= "ptBR" then
  return
end

local L = WeakAuras.L

L["Cooldown timer accuracy is reduced in combat due to WoW 12.x API restrictions. Use 'Not on Cooldown' to reliably show/hide based on cooldown state."] = "A precisão do temporizador de recarga é reduzida em combate devido às restrições da API do WoW 12.x. Use 'Sem recarga' para mostrar ou ocultar de forma confiável com base no estado de recarga."

