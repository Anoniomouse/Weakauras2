-- bit32 was removed in WoW 12.0. Provide a full polyfill using LuaJIT's bit library.
-- bit32.extract, bit32.replace, bit32.btest, bit32.lrotate, bit32.rrotate are not
-- present in bit, so they are implemented explicitly.
if not bit32 then
  local b = bit
  bit32 = {
    band    = b.band,
    bor     = b.bor,
    bxor    = b.bxor,
    bnot    = b.bnot,
    lshift  = b.lshift,
    rshift  = b.rshift,
    arshift = b.arshift,
    lrotate = b.rol,
    rrotate = b.ror,
    btest   = function(...) return b.band(...) ~= 0 end,
    extract = function(n, field, width)
      width = width or 1
      return b.band(b.rshift(n, field), 2 ^ width - 1)
    end,
    replace = function(n, v, field, width)
      width = width or 1
      local mask = 2 ^ width - 1
      return b.bor(b.band(n, b.bnot(b.lshift(mask, field))), b.lshift(b.band(v, mask), field))
    end,
  }
end
