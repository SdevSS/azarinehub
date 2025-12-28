-- ENCRYPTORAZG - SHA1 Module for Roblox
-- Public domain style usage

local ENCRYPTORAZG = {}

local ASSERTIONS_ENABLED = true

local INIT_0 = 0x67452301
local INIT_1 = 0xEFCDAB89
local INIT_2 = 0x98BADCFE
local INIT_3 = 0x10325476
local INIT_4 = 0xC3D2E1F0

local APPEND_CHAR = string.char(0x80)
local INT_32_CAP = 2^32

-- Packs four 8-bit integers into one 32-bit integer
local function packUint32(a, b, c, d)
	return bit32.lshift(a, 24)
		+ bit32.lshift(b, 16)
		+ bit32.lshift(c, 8)
		+ d
end

-- Unpacks one 32-bit integer into four 8-bit integers
local function unpackUint32(int)
	return bit32.extract(int, 24, 8),
		   bit32.extract(int, 16, 8),
		   bit32.extract(int, 8, 8),
		   bit32.extract(int, 0, 8)
end

local function F(t, A, B, C)
	if t <= 19 then
		return bit32.bxor(C, bit32.band(A, bit32.bxor(B, C)))
	elseif t <= 39 then
		return bit32.bxor(A, B, C)
	elseif t <= 59 then
		return bit32.bor(
			bit32.band(A, bit32.bor(B, C)),
			bit32.band(B, C)
		)
	else
		return bit32.bxor(A, B, C)
	end
end

local function K(t)
	if t <= 19 then
		return 0x5A827999
	elseif t <= 39 then
		return 0x6ED9EBA1
	elseif t <= 59 then
		return 0x8F1BBCDC
	else
		return 0xCA62C1D6
	end
end

local function preprocessMessage(message)
	local initMsgLen = #message * 8
	local msgLen = initMsgLen + 8
	local nulCount = 4

	message ..= APPEND_CHAR

	while (msgLen + 64) % 512 ~= 0 do
		nulCount += 1
		msgLen += 8
	end

	message ..= string.rep("\0", nulCount)
	message ..= string.char(unpackUint32(initMsgLen))

	if ASSERTIONS_ENABLED then
		assert(msgLen % 512 == 448)
		assert(#message % 64 == 0)
	end

	return message
end

function ENCRYPTORAZG.sha1(message)
	message = preprocessMessage(message)

	local H0, H1, H2, H3, H4 =
		INIT_0, INIT_1, INIT_2, INIT_3, INIT_4

	local W = {}

	for chunkStart = 1, #message, 64 do
		local place = chunkStart

		for t = 0, 15 do
			W[t] = packUint32(string.byte(message, place, place + 3))
			place += 4
		end

		for t = 16, 79 do
			W[t] = bit32.lrotate(
				bit32.bxor(W[t-3], W[t-8], W[t-14], W[t-16]), 1
			)
		end

		local A, B, C, D, E = H0, H1, H2, H3, H4

		for t = 0, 79 do
			local TEMP = (
				bit32.lrotate(A, 5)
				+ F(t, B, C, D)
				+ E
				+ W[t]
				+ K(t)
			) % INT_32_CAP

			E, D, C, B, A = D, C, bit32.lrotate(B, 30), A, TEMP
		end

		H0 = (H0 + A) % INT_32_CAP
		H1 = (H1 + B) % INT_32_CAP
		H2 = (H2 + C) % INT_32_CAP
		H3 = (H3 + D) % INT_32_CAP
		H4 = (H4 + E) % INT_32_CAP
	end

	return string.format(
		"%08x%08x%08x%08x%08x",
		H0, H1, H2, H3, H4
	)
end

-- Self-test (safe for Roblox)
if ASSERTIONS_ENABLED then
	local t = os.clock()

	assert(ENCRYPTORAZG.sha1("abc") == "a9993e364706816aba3e25717850c26c9cd0d89d")
	assert(ENCRYPTORAZG.sha1("") == "da39a3ee5e6b4b0d3255bfef95601890afd80709")
	assert(ENCRYPTORAZG.sha1("foo") == "0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33")

end

return ENCRYPTORAZG
