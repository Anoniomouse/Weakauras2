if (GAME_LOCALE or GetLocale()) ~= "koKR" then
  return
end

local L = WeakAuras.L

L["Cooldown timer accuracy is reduced in combat due to WoW 12.x API restrictions. Use 'Not on Cooldown' to reliably show/hide based on cooldown state."] = "WoW 12.x API 제한으로 인해 전투 중 재사용 대기시간 타이머 정확도가 감소합니다. 재사용 대기시간 상태에 따라 신뢰할 수 있는 표시/숨기기를 위해 '재사용 대기시간 아님'을 사용하세요."

