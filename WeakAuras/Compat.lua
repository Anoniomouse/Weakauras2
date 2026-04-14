-- bit32 was removed in WoW 12.0; LuaJIT's bit library is equivalent for all
-- operations used by embedded libraries (band, bor, bxor, bnot, lshift, rshift).
if not bit32 then
  bit32 = bit
end
