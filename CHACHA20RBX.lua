local ffi = require('ffi')
local bit = require('bit')

local min = math.min
local sizeof = ffi.sizeof
local lshift, rshift, bor, band, bxor = bit.lshift, bit.rshift, bit.bor, bit.band, bit.bxor

local constants = ffi.cast('uint8_t*', 'expand 32-byte k')

local function ROTL32(v, n)
    return bor(lshift(v, n), rshift(v, (32 - n)))
end

local function LE(p)
    p = ffi.cast('uint8_t*', p)
    return bor(ffi.cast('uint32_t', p[0]),
        lshift(ffi.cast('uint32_t', p[1]), 8),
        lshift(ffi.cast('uint32_t', p[2]), 16),
        lshift(ffi.cast('uint32_t', p[3]), 24))
end

local function FROMLE(b, i)
    b = ffi.cast('uint8_t*', b)
    b[0] = band(i, 0xFF)
    b[1] = band(rshift(i, 8), 0xFF)
    b[2] = band(rshift(i, 16), 0xFF)
    b[3] = band(rshift(i, 24), 0xFF)
end

local chacha20 = {}
chacha20.__index = chacha20

ffi.cdef([[
    typedef struct {
        uint32_t schedule[16];
        uint32_t keystream[16];
        size_t available;
    } chacha20_ctx;
]])

local Chacha20Ctx = ffi.metatype('chacha20_ctx', chacha20)

-- Core Functionality
function chacha20.new(key, nonce)
    if type(key) == 'string' then
        assert(#key == 32, 'key len must be 32 byte')
        key = ffi.cast('uint8_t*', key)
    end

    if type(nonce) == 'string' then
        assert(#nonce == 8, 'nonce len must be 8 byte')
        nonce = ffi.cast('uint8_t*', nonce)
    end

    local ctx = Chacha20Ctx()
    ctx.schedule[0] = LE(constants + 0)
    ctx.schedule[1] = LE(constants + 4)
    ctx.schedule[2] = LE(constants + 8)
    ctx.schedule[3] = LE(constants + 12)
    ctx.schedule[4] = LE(key + 0)
    ctx.schedule[5] = LE(key + 4)
    ctx.schedule[6] = LE(key + 8)
    ctx.schedule[7] = LE(key + 12)
    ctx.schedule[8] = LE(key + 16)
    ctx.schedule[9] = LE(key + 20)
    ctx.schedule[10] = LE(key + 24)
    ctx.schedule[11] = LE(key + 28)
    ctx.schedule[12] = 0
    ctx.schedule[13] = 0
    ctx.schedule[14] = LE(nonce + 0)
    ctx.schedule[15] = LE(nonce + 4)
    ffi.fill(ctx.keystream, 64, 0)
    ctx.available = 0
    return ctx
end

local function chacha20Xor(keystream, input, output, length)
    local end_keystream = ffi.cast('uint8_t*', keystream + length)
    repeat
        output[0] = bxor(input[0], keystream[0])
        input = input + 1
        output = output + 1
        keystream = keystream + 1
    until keystream == end_keystream
    return input, output
end

local function chacha20Block(ctx, out)
    local nonce = ffi.cast('uint32_t*', ctx.schedule + 12)
    ffi.copy(out, ctx.schedule, ffi.sizeof(ctx.schedule))

    for i = 1, 10 do
        -- Quarter rounds manual (optimized)
        local a, b, c, d = 0, 4, 8, 12
        for _ = 1, 4 do
            out[a] = out[a] + out[b]; out[d] = ROTL32(bxor(out[d], out[a]), 16)
            out[c] = out[c] + out[d]; out[b] = ROTL32(bxor(out[b], out[c]), 12)
            out[a] = out[a] + out[b]; out[d] = ROTL32(bxor(out[d], out[a]), 8)
            out[c] = out[c] + out[d]; out[b] = ROTL32(bxor(out[b], out[c]), 7)
            a, b, c, d = a+1, b+1, c+1, d+1
        end
        -- Diagonal rounds
        local rounds = {{0,5,10,15}, {1,6,11,12}, {2,7,8,13}, {3,4,9,14}}
        for _, r in ipairs(rounds) do
            local a, b, c, d = r[1], r[2], r[3], r[4]
            out[a] = out[a] + out[b]; out[d] = ROTL32(bxor(out[d], out[a]), 16)
            out[c] = out[c] + out[d]; out[b] = ROTL32(bxor(out[b], out[c]), 12)
            out[a] = out[a] + out[b]; out[d] = ROTL32(bxor(out[d], out[a]), 8)
            out[c] = out[c] + out[d]; out[b] = ROTL32(bxor(out[b], out[c]), 7)
        end
    end

    for i = 0, 15 do FROMLE(out + i, out[i] + ctx.schedule[i]) end
    nonce[0] = nonce[0] + 1
    if nonce[0] ~= 0 then return end
    nonce[1] = nonce[1] + 1
end

function chacha20.crypt_internal(self, input, output, length)
    input = ffi.cast('uint8_t*', input)
    output = ffi.cast('uint8_t*', output)
    if length <= 0 then return end
    local k = ffi.cast('uint8_t*', self.keystream)
    local keystreamLen = sizeof(self.keystream)
    if self.available > 0 then
        local amount = min(length, self.available)
        input, output = chacha20Xor(k + (keystreamLen - self.available), input, output, amount)
        self.available = self.available - amount
        length = length - amount
    end
    while length > 0 do
        local amount = min(length, keystreamLen)
        chacha20Block(self, self.keystream)
        input, output = chacha20Xor(k, input, output, amount)
        length = length - amount
        self.available = keystreamLen - amount
    end
end

--- ==========================================
--- WRAPPER BIAR GAMPANG (MODIFIKASI DISINI)
--- ==========================================

-- Fungsi untuk Enkripsi String jadi String
function chacha20.encrypt(text, key, nonce)
    local len = #text
    local output = ffi.new('uint8_t[?]', len)
    local ctx = chacha20.new(key, nonce)
    chacha20.crypt_internal(ctx, text, output, len)
    return ffi.string(output, len)
end

-- Di ChaCha20, decrypt itu sama dengan encrypt
chacha20.decrypt = chacha20.encrypt

return chacha20
