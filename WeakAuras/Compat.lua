-- Provide bit32 for embedded libraries that depend on it.
-- WoW 12.0 may have neither bit32 nor LuaJIT's bit library.
-- This file must never crash regardless of Lua environment.
if not bit32 then
  if type(bit) == "table" and type(bit.band) == "function" then
    -- LuaJIT's bit library is available (WoW < 12.0)
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
  else
    -- Lua 5.4+ native bitwise operators. Use load() so this file remains
    -- parseable by LuaJIT (which does not support & | ~ << >> syntax).
    local chunk = load([[
      local ops = {}
      ops.band    = function(a, b, ...) local r = a & b; return ... and ops.band(r, ...) or r end
      ops.bor     = function(a, b, ...) local r = a | b; return ... and ops.bor(r, ...) or r end
      ops.bxor    = function(a, b, ...) local r = a ~ b; return ... and ops.bxor(r, ...) or r end
      ops.bnot    = function(a) return ~a & 0xFFFFFFFF end
      ops.lshift  = function(a, b) return (a << b) & 0xFFFFFFFF end
      ops.rshift  = function(a, b) return (a & 0xFFFFFFFF) >> b end
      ops.arshift = function(a, b) return a >> b end
      ops.lrotate = function(a, b) b = b & 31; return ((a << b) | (a >> (32 - b))) & 0xFFFFFFFF end
      ops.rrotate = function(a, b) b = b & 31; return ((a >> b) | (a << (32 - b))) & 0xFFFFFFFF end
      ops.btest   = function(a, b, ...) return (a & b & ...) ~= 0 end
      ops.extract = function(n, f, w) w = w or 1; return (n >> f) & ((1 << w) - 1) end
      ops.replace = function(n, v, f, w)
        w = w or 1; local m = (1 << w) - 1
        return (n & ~(m << f)) | ((v & m) << f)
      end
      return ops
    ]])
    if chunk then
      local ok, ops = pcall(chunk)
      if ok and type(ops) == "table" then
        bit32 = ops
      end
    end
  end
end
