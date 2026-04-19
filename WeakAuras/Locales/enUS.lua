local L = WeakAuras.L


-- Make missing translations available
setmetatable(WeakAuras.L, {__index = function(self, key)
  self[key] = (key or "")
  return key
end})

L["Cooldown timer accuracy is reduced in combat due to WoW 12.x API restrictions. Use 'Not on Cooldown' to reliably show/hide based on cooldown state."] = "Cooldown timer accuracy is reduced in combat due to WoW 12.x API restrictions. Use 'Not on Cooldown' to reliably show/hide based on cooldown state."

