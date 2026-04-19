if (GAME_LOCALE or GetLocale()) ~= "ruRU" then
  return
end

local L = WeakAuras.L

L["Cooldown timer accuracy is reduced in combat due to WoW 12.x API restrictions. Use 'Not on Cooldown' to reliably show/hide based on cooldown state."] = "Точность таймера перезарядки снижена в бою из-за ограничений API WoW 12.x. Используйте 'Не на перезарядке', чтобы надёжно показывать или скрывать ауру в зависимости от состояния перезарядки."

