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
    -- Try Lua 5.4+ native bitwise operators via load() so this file stays
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

    -- Pure-arithmetic fallback: works in any Lua version (5.1, 5.2, 5.3, 5.4).
    -- Used when load() is unavailable or the Lua version doesn't support & | ~ << >>.
    if not bit32 then
      local floor = math.floor

      -- Precompute 4-bit lookup tables for AND / OR / XOR (256 entries each).
      local b4and, b4or, b4xor = {}, {}, {}
      for a = 0, 15 do
        for b = 0, 15 do
          local ra, rb = a, b
          local va, vo, vx = 0, 0, 0
          for i = 0, 3 do
            local da = ra % 2; ra = floor(ra / 2)
            local db = rb % 2; rb = floor(rb / 2)
            local p = 2 ^ i
            if da == 1 and db == 1 then va = va + p end
            if da == 1 or  db == 1 then vo = vo + p end
            if da ~= db             then vx = vx + p end
          end
          local k = a * 16 + b
          b4and[k] = va; b4or[k] = vo; b4xor[k] = vx
        end
      end

      -- Powers of 2 cache (0..32).
      local pow2 = {}
      for i = 0, 32 do pow2[i] = 2 ^ i end

      -- Apply a 4-bit lookup across all 8 nibbles of two 32-bit values.
      local function apply(a, b, tbl)
        a = a % 4294967296; b = b % 4294967296
        local r, m = 0, 1
        for _ = 1, 8 do
          r = r + tbl[(a % 16) * 16 + (b % 16)] * m
          a = floor(a / 16); b = floor(b / 16)
          m = m * 16
        end
        return r
      end

      local ops = {}
      ops.band = function(a, b, ...) local r = apply(a, b, b4and); return ... and ops.band(r, ...) or r end
      ops.bor  = function(a, b, ...) local r = apply(a, b, b4or);  return ... and ops.bor(r, ...) or r end
      ops.bxor = function(a, b, ...) local r = apply(a, b, b4xor); return ... and ops.bxor(r, ...) or r end
      ops.bnot = function(a) return 4294967295 - a % 4294967296 end
      ops.lshift = function(a, b)
        b = b % 64; if b >= 32 then return 0 end
        -- Split to avoid double-precision overflow: max result = 2^32 - 1
        a = a % 4294967296
        return (a % pow2[32 - b]) * pow2[b]
      end
      ops.rshift = function(a, b)
        b = b % 64; if b >= 32 then return 0 end
        return floor((a % 4294967296) / pow2[b])
      end
      ops.arshift = function(a, b)
        a = a % 4294967296
        local shift = b < 32 and b or 31
        local r = floor(a / pow2[shift])
        if a >= 2147483648 and b > 0 then   -- sign bit set → fill with 1s
          r = r + (b < 32 and (4294967296 - pow2[32 - b]) or 4294967295)
        end
        return r
      end
      ops.lrotate = function(a, b)
        b = b % 32; if b == 0 then return a % 4294967296 end
        a = a % 4294967296
        return apply(floor(a / pow2[32 - b]) + (a % pow2[32 - b]) * pow2[b], 0, b4or)
            -- simpler: bor(lshift(a,b), rshift(a, 32-b))
      end
      ops.rrotate = function(a, b)
        b = b % 32; if b == 0 then return a % 4294967296 end
        a = a % 4294967296
        return ops.bor(ops.rshift(a, b), ops.lshift(a, 32 - b))
      end
      -- fix lrotate to use the same approach as rrotate for consistency
      ops.lrotate = function(a, b)
        b = b % 32; if b == 0 then return a % 4294967296 end
        return ops.bor(ops.lshift(a, b), ops.rshift(a, 32 - b))
      end
      ops.btest   = function(a, b, ...) return ops.band(a, b, ...) ~= 0 end
      ops.extract = function(n, f, w)
        w = w or 1
        return ops.band(ops.rshift(n, f), pow2[w] - 1)
      end
      ops.replace = function(n, v, f, w)
        w = w or 1
        local mask = pow2[w] - 1
        return ops.bor(ops.band(n, ops.bnot(ops.lshift(mask, f))), ops.lshift(ops.band(v, mask), f))
      end
      bit32 = ops
    end
  end
end
