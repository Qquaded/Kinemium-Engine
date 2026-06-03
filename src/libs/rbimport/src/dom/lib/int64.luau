--!native
--!optimize 2

-- stylua: ignore
local HEX_TO_BINARY = {
    ["0"] = "0000", ["1"] = "0001", ["2"] = "0010", ["3"] = "0011",
    ["4"] = "0100", ["5"] = "0101", ["6"] = "0110", ["7"] = "0111",
    ["8"] = "1000", ["9"] = "1001", ["a"] = "1010", ["b"] = "1011",
    ["c"] = "1100", ["d"] = "1101", ["e"] = "1110", ["f"] = "1111",
}

--- A constant representing the 64-bit representation of `0`.
local ZERO = vector.create(0, 0, 0)
--- A constant representating the 64-bit representation of `1`.
local ONE = vector.create(0, 0, 1)
--- A constant representating the 64-bit representation of `2`.
local TWO = vector.create(0, 0, 2)

--- A constant representing the maximum possible 64-bit value
--- (`18446744073709551615`, or `2 ^ 64 - 1`)
local MAX = vector.create(0x3fffff, 0xfffff, 0x3fffff)
--- A constant representing the maximum possible 32-bit value
--- (`4294967295`, or `2 ^ 32 - 1`).
local MAX_U32 = vector.create(0, 0x3ff, 0x3fffff)
--- A constant representing the maximum integer that is exactly representable
--- by a normal Luau number (`9007199254740992` or `2 ^ 53`).
local MAX_F64 = vector.create(0x800, 0, 0)
--- A constant representing the maximum integer that is exactly representable
--- by a 32-bit floating point value (`16777216`, or `2 ^ 24`).
local MAX_F32 = vector.create(0, 4, 0)

--[=[
	Normalizes a vector, trimming off any bits that would interfere with
	the library's functionality.
]=]
local function normalize(u64: vector): vector
	return vector.create(
		bit32.band(u64.x, 0b1111_1111_1111_1111_1111_11),
		bit32.band(u64.y, 0b1111_1111_1111_1111_1111),
		bit32.band(u64.z, 0b1111_1111_1111_1111_1111_11)
	)
end

--[=[
	Constructs a 64-bit integer from the passed `u32` values.
	
	The provided `most` value fills the upper 32 bits of the integer,
	and the provided `least` value fills the lower 32-bits.
]=]
local function from_pair(most: number, least: number): vector
	-- 32 - 22 = 10
	-- x = upper 22 of most
	-- y = lower 10 of most and upper 10 of least
	-- z = lower 22 of least
	return vector.create(
		bit32.rshift(most, 10),
		bit32.bor(bit32.extract(least, 22, 10), bit32.lshift(bit32.band(most, 0b1111_1111_11), 10)),
		bit32.band(least, 0b1111_1111_1111_1111_1111_11)
	)
end

--[=[
	Constructs a 64-bit integer from the passed `u32`.
	
	This number is truncated in a 32-bit integer, even if it is larger than
	the max value.
]=]
local function from_u32(u32: number): vector
	return vector.create(0, bit32.rshift(u32, 22), bit32.band(u32, 0b1111_1111_1111_1111_1111_11))
end

--[=[
	Constructs a 64-bit integer from the passed `f64`.
	Put more plainly, converts a normal Luau number to a 64-bit integer.

	The number is truncated into an integer first. Note that Luau numbers
	cannot accurately represent integers past `2 ^ 53`.
]=]
local function from_f64(f64: number): vector
	return from_pair(bit32.bor(f64 // 2 ^ 32), bit32.bor(f64 % 2 ^ 32))
end

--[=[
	Converts the provided `u64` into two 32-bit integers.

	This returns the most significant portion of the number first.
]=]
local function to_pair(u64: vector): (number, number)
	-- x = upper 22 of most
	-- y = lower 10 of most and upper 10 of least
	-- z = lower 22 of least
	local most = bit32.bor(bit32.lshift(u64.x, 10), bit32.rshift(u64.y, 10))
	local least = bit32.bor(bit32.lshift(u64.y, 22), u64.z)

	return most, least
end

--[=[
	Converts the provided `u64` into four 16-bit integers.

	This returns the most significant portion of the number first.
]=]
local function to_quartet(u64: vector): (number, number, number, number)
	-- 0000000000000000000000 00000000000000000000 0000000000000000000000
	-- 0000000000000000 000000 0000000000 0000000000 000000 0000000000000000
	-- 1111000111100010 1101001111000100 1000000010011010 1011110011011110
	local most, least = to_pair(u64)
	local q1, q2 = bit32.rshift(most, 16), bit32.band(most, 0xffff)
	local q3, q4 = bit32.rshift(least, 16), bit32.band(least, 0xffff)
	-- local q1 = bit32.rshift(u64.x, 6)
	-- local q2 = bit32.bor(bit32.lshift(u64.y, 16), bit32.rshift(u64.y, 10))
	-- local q3 = bit32.bor(bit32.band(u64.y, 0b1111_1111_11), bit32.rshift(u64.z, 16))
	-- local q4 = bit32.band(0b1111_1111_1111_1111)
	return q1, q2, q3, q4
end

--[=[
	Converts the provided `u64` to an `f64` (or put plainly: a normal Luau
	number).

	This function does not check for precision loss. `f64` values lose precision
	past `2 ^ 53`.
]=]
local function to_f64(u64: vector): number
	local most, least = to_pair(u64)
	return most * 2 ^ 32 + least
end

--[=[
	Returns whether the provided `u64` is zero or not.

	Equivalent to `u64 == from_u32(0)`.
]=]
local function is_zero(u64: vector): boolean
	return u64 == ZERO
end

--[=[
	Computes the bitwise AND of the two provide values.

	This does not accept a vararg like the `bit32` equivalent for performance
	reasons.
]=]
local function band(lhs: vector, rhs: vector): vector
	return vector.create(bit32.band(lhs.x, rhs.x), bit32.band(lhs.y, rhs.y), bit32.band(lhs.z, rhs.z))
end

--[=[
	Computes the bitwise OR of the two provide values.

	This does not accept a vararg like the `bit32` equivalent for performance
	reasons.
]=]
local function bor(lhs: vector, rhs: vector): vector
	return vector.create(bit32.bor(lhs.x, rhs.x), bit32.bor(lhs.y, rhs.y), bit32.bor(lhs.z, rhs.z))
end

--[=[
	Computes the bitwise XOR of the two provide values.

	This does not accept a vararg like the `bit32` equivalent for performance
	reasons.
]=]
local function bxor(lhs: vector, rhs: vector): vector
	return vector.create(bit32.bxor(lhs.x, rhs.x), bit32.bxor(lhs.y, rhs.y), bit32.bxor(lhs.z, rhs.z))
end

--[=[
	Computes the bitwise negation of the provided value.
]=]
local function bnot(u64: vector): vector
	return vector.create(
		bit32.band(bit32.bnot(u64.x), 0b1111_1111_1111_1111_1111_11),
		bit32.band(bit32.bnot(u64.y), 0b1111_1111_1111_1111_1111),
		bit32.band(bit32.bnot(u64.z), 0b1111_1111_1111_1111_1111_11)
	)
end

--[=[
	Shifts the provided `u64` logically left by `n` bits.

	This function will error if `n` is negative.
]=]
local function lshift(u64: vector, n: number): vector
	if n >= 64 then
		return vector.zero
	elseif n == 0 then
		return u64
	end
	local most, least = to_pair(u64)
	if n < 32 then
		local remainder = 32 - n
		local ret = from_pair(bit32.replace(bit32.rshift(least, remainder), most, n, remainder), bit32.lshift(least, n))
		return ret
	else
		local ret = from_pair(bit32.lshift(least, n - 32), 0)
		return ret
	end
end

--[=[
	Shifts the provided `u64` logically right by `n` bits.

	This function will error if `n` is negative.
]=]
local function rshift(u64: vector, n: number): vector
	if n == 0 then
		return u64
	end
	local most, least = to_pair(u64)
	if n < 32 then
		local ret = from_pair(bit32.rshift(most, n), bit32.replace(bit32.rshift(least, n), most, 32 - n, n))
		return ret
	else
		local ret = from_pair(0, bit32.rshift(most, n - 32))
		return ret
	end
end

--[=[
	Shifts the provided `u64` arithmetically right by `n` bits. Since these
	numbers are unsigned, this effectively just copies the most significant
	bit into the empty space rather than filling them with zeros.

	This function will error if `n` is negative.
]=]
local function arshift(u64: vector, n: number): vector
	-- If the sign bit is set, we do arshift
	if bit32.btest(u64.x, 0x20_0000) then
		if n >= 64 then
			return MAX
		else
			return bor(rshift(u64, n), bnot(rshift(MAX, n)))
		end
	else
		-- Otherwise it's just an rshift
		return rshift(u64, n)
	end
end

--[=[
	Rotates the bits of the provided `u64` left by `n` bits. 

	If `n` is negative, this is equivalent to `rrotate`. Otherwise, if `n` is
	greater than 64-bits, it will wrap around.
]=]
local function lrotate(u64: vector, n: number): vector
	n = bit32.band(n, 63)
	local lshifted = lshift(u64, n)
	local rshifted = rshift(u64, 64 - n)
	return bor(lshifted, rshifted)
end

--[=[
	Rotates the bits of the provided `u64` right by `n` bits. 

	If `n` is negative, this is equivalent to `lrotate`. Otherwise, if `n` is
	greater than 64-bits, it will wrap around.
]=]
local function rrotate(u64: vector, n: number): vector
	n = bit32.band(n, 63)
	local lshifted = lshift(u64, 64 - n)
	local rshifted = rshift(u64, n)
	return bor(lshifted, rshifted)
end

--[=[
	Returns the number of consecutive zero bits in the provided `u64` starting
	from the left-most (most significant) bit.
]=]
local function countlz(u64: vector): number
	local most, least = to_pair(u64)
	if most == 0 then
		return bit32.countlz(least) + 32
	else
		return bit32.countlz(most)
	end
end

--[=[
	Returns the number of consecutive zero bits in the provided `u64` starting
	from the right-most (least significant) bit.
]=]
local function countrz(u64: vector): number
	local most, least = to_pair(u64)
	if least == 0 then
		return bit32.countrz(most) + 32
	else
		return bit32.countrz(least)
	end
end

--[=[
	Returns a boolean describing whether the bitwise AND of `lhs` and
	`rhs` are different than zero.

	This does not accept a vararg like the `bit32` equivalent for performance
	reasons.
]=]
local function btest(lhs: vector, rhs: vector): boolean
	return band(lhs, rhs) ~= ZERO
end

--[=[
	Returns the provided `u64` with the order of bytes swapped.
]=]
local function byteswap(u64: vector): vector
	local most, least = to_pair(u64)
	return from_pair(bit32.byteswap(least), bit32.byteswap(most))
end

--[=[
	Returns whether `lhs` is greater than `rhs`.
]=]
local function gt(lhs: vector, rhs: vector): boolean
	local l_most, l_least = to_pair(lhs)
	local r_most, r_least = to_pair(rhs)

	if l_most == r_most then
		return l_least > r_least
	else
		return l_most > r_most
	end
end

--[=[
	Returns whether `lhs` is greater than or equal to `rhs`.
]=]
local function gt_equal(lhs: vector, rhs: vector): boolean
	return lhs == rhs or gt(lhs, rhs)
end

--[=[
	Returns whether `lhs` is less than `rhs`.
]=]
local function lt(lhs: vector, rhs: vector): boolean
	local l_most, l_least = to_pair(lhs)
	local r_most, r_least = to_pair(rhs)

	if l_most == r_most then
		return l_least < r_least
	else
		return l_most < r_most
	end
end

--[=[
	Returns whether `lhs` is less than or equal to `rhs`.
]=]
local function lt_equal(lhs: vector, rhs: vector): boolean
	return lhs == rhs or lt(lhs, rhs)
end

--[=[
	Calculates the quotient of the two provided values and returns it,
	along with the remainder from that operation.

	This function operates on a single 64-bit integer and a 32-bit integer.
	For dividing two 64-bit integers, see `div`.
	
	Equivalent to `//` for normal integers.
	This function will error if `divisor` is 0.
]=]
local function div_32(dividend: vector, divisor: number): (vector, number)
	if divisor == 0 then
		error("cannot divide integers by zero")
	end
	local hi, lo = to_pair(dividend)
	local q_hi, q_lo = 0, 0
	local rem = 0

	for i = 31, 0, -1 do
		rem = bit32.bor(bit32.lshift(rem, 1), bit32.band(bit32.rshift(hi, i), 1))

		if rem >= divisor then
			rem -= divisor
			q_hi = bit32.bor(q_hi, bit32.lshift(1, i))
		end
	end
	for i = 31, 0, -1 do
		rem = bit32.bor(bit32.lshift(rem, 1), bit32.band(bit32.rshift(lo, i), 1))

		if rem >= divisor then
			rem -= divisor
			q_lo = bit32.bor(q_lo, bit32.lshift(1, i))
		end
	end

	return from_pair(q_hi, q_lo), rem
end

--[=[
	Calculates the sum of the two provided values. Equivalent to `+` for
	normal integers.
	
	If the sum is equal to or greater than `2 ^ 64`, the returned value will
	overflow rather than expanding beyond 64 bits.
]=]
local function add(augend: vector, addend: vector): vector
	local prime = augend + addend

	prime += vector.create(0, if prime.z > (2 ^ 22 - 1) then 1 else 0, 0)
	prime += vector.create(if prime.y > (2 ^ 20 - 1) then 1 else 0, 0, 0)

	return normalize(prime)
end

--[=[
	Calculates the difference of the two provided values. Equivalent to `-` for
	normal integers.
	
	If the difference is less than `0`, the returned value will overflow rather
	than going negative.
]=]
local function sub(minuend: vector, subtrahend: vector): vector
	local prime = minuend - subtrahend

	local adjust_z = prime.z
	local adjust_y = prime.y
	local adjust_x = prime.x

	local borrow_z = prime.z < 0
	if borrow_z then
		adjust_z += 2 ^ 22
	end

	if borrow_z then
		adjust_y -= 1
	end
	local borrow_y = adjust_y < 0
	if borrow_y then
		adjust_y += 2 ^ 20
	end

	if borrow_y then
		adjust_x -= 1
	end
	local borrow_x = adjust_x < 0
	if borrow_x then
		adjust_x += 2 ^ 22
	end

	return vector.create(adjust_x, adjust_y, adjust_z)
end

--[=[
	Calculates the product of the two provided values. Equivalent to `*` for
	normal integers.
	
	If the product is greater than or equal to `2 ^ 64`, the returned value will
	overflow rather than expanding beyond 64 bits.
]=]
local function mult(multiplier: vector, multiplicand: vector): vector
	-- We represent 64-bit numbers as two 32-bit ones.
	-- Multiplying them is:
	-- (A + B) * (C + D) = (A * C) + (A * D) + (B * C) + (B * D)
	--
	-- However, multiplying two 32-bit numbers might overflow. So, we need to
	-- use 16-bit numbers. This turns our math into this:
	-- (A + B + C + D) * (E + F + G + H) =
	-- 		(A * E) + (A * F) + (A * G) + (A * H) +
	-- 		(B * E) + (B * F) + (B * G) + (B * H) +
	-- 		(C * E) + (C * F) + (C * G) + (C * H) +
	-- 		(D * E) + (D * F) + (D * G) + (D * H)
	--
	-- We can skip (A * E), (A * F), (A * G), (B * E), (B * F), and (C * F)
	-- because they don't exist within the bounds of the final product.
	-- Since the numbers are built as A * 2 ^ 48 + B * 2 ^ 32 + C * 2 ^ 16 + D
	-- you end up with e.g. (A * 2 ^ 48 * E * 2 ^ 48) which is A * E * 2^96.
	-- Otherwise... Here we go.

	local a, b, c, d = to_quartet(multiplier)
	local e, f, g, h = to_quartet(multiplicand)

	local product_4 = d * h
	local product_3 = bit32.rshift(product_4, 16) + c * h
	local product_2 = bit32.rshift(product_3, 16)
	product_3 = bit32.band(product_3, 0xFFFF) + d * g

	product_2 += bit32.rshift(product_3, 16) + b * h
	local product_1 = bit32.rshift(product_2, 16)

	product_2 = bit32.band(product_2, 0xFFFF) + c * g
	product_1 += bit32.rshift(product_2, 16)
	product_2 = bit32.band(product_2, 0xFFFF) + d * f
	product_1 += bit32.rshift(product_2, 16) + a * h + b * g + c * f + d * e

	-- We skip truncating any of the products the last time since they'll never
	-- overflow and bit32 will truncate them for us.

	return from_pair(bit32.replace(product_2, product_1, 16, 16), bit32.replace(product_4, product_3, 16, 16))
end

--[=[
	Calculates the quotient of the two provided values and returns it, along
	with the remainder.

	Equivalent to `//` and `%` for normal integers.
	This function will error if `divisor` is `0`.
]=]
local function div(dividend: vector, divisor: vector): (vector, vector)
	if is_zero(divisor) then
		error("cannot divide integers by zero")
	elseif countlz(dividend) >= 11 and countlz(divisor) >= 11 then
		local l_real = to_f64(dividend)
		local r_real = to_f64(divisor)
		return from_f64(l_real // r_real), from_f64(l_real % r_real)
	end

	local quotient = ZERO
	local remainder = dividend

	-- Doing extra iterations of this is very bad!
	for i = math.abs(countlz(dividend) - countlz(divisor)), 0, -1 do
		local shifted_divisor = lshift(divisor, i)

		if gt_equal(remainder, shifted_divisor) then
			remainder = sub(remainder, shifted_divisor)
			quotient = bor(quotient, lshift(ONE, i))
		end
	end

	return quotient, remainder
end

--[=[
	Calculates the result of `base` raised to `power`. Equivalent to `^` for
	normal integers. `power` is interpreted as a 32-bit integer.

	If the result is greater than or equal to `2 ^ 64`, the returned value will
	overflow rather than expanding beyond 64 bits.
	
	Additionally, `0 ^ 0` is treated as being `1`.
]=]
local function pow(base: vector, power: number): vector
	if power == 0 then
		return ONE
	elseif power % 2 == 1 then
		return mult(base, pow(base, power - 1))
	else
		local temp = pow(base, power / 2)
		return mult(temp, temp)
	end
end

--[=[
	Reads a `u64` from the provided buffer. If offset is provided, reads from
	that spot in the buffer. Otherwise, reads from the beginning.

	This function reads a little-endian value from the buffer.
]=]
local function from_buffer(buf: buffer, offset: number?): vector
	offset = offset or 0
	local least = buffer.readu32(buf, offset :: number)
	local most = buffer.readu32(buf, offset :: number + 4)

	return from_pair(most, least)
end

--[=[
	Reads a `u64` from the provided string. If offset is provided, reads from
	that point in the string. Otherwise starts at the beginning.

	This function reads a little-endian value from the string.
]=]
local function from_byte_string(str: string, offset: number?): vector
	offset = offset or 1
	-- This is deliberately backwards because we expect a little endian input
	local d, c, b, a, h, g, f, e = string.byte(str, offset, offset :: number + 7)
	local least = bit32.bor(bit32.lshift(bit32.replace(b, a, 8, 8), 16), bit32.replace(d, c, 8, 8))
	local most = bit32.bor(bit32.lshift(bit32.replace(f, e, 8, 8), 16), bit32.replace(h, g, 8, 8))

	return from_pair(most, least)
end

--[=[
	Converts the provided `u64` to a buffer.

	The integer is written as a little-endian value.
]=]
local function to_buffer(u64: vector): buffer
	local most, least = to_pair(u64)
	local buf = buffer.create(8)
	-- We use a little endian format because it doesn't matter and most
	-- systems we run on are little endian so it'll be nicer for them.
	buffer.writeu32(buf, 0, least)
	buffer.writeu32(buf, 4, most)
	return buf
end

--[=[
	Writes the provided `u64` to the provided buffer. The value is written
	to the buffer at the provided offset.

	The integer is written as a little-endian value.
]=]
local function write_to_buffer(b: buffer, u64: vector, offset: number)
	local most, least = to_pair(u64)
	buffer.writeu32(b, offset, least)
	buffer.writeu32(b, offset + 4, most)
end

--[=[
	Converts the provided `u64` to string of binary data.

	The integer is written as if it were little-endian.
]=]
local function to_byte_string(u64: vector): string
	local most, least = to_pair(u64)
	-- Previous implementation of this used `%c` but it turns out that
	-- `string.format("%c", 0)` results in a zero length string!
	return string.char(
		bit32.band(least, 0xFF),
		bit32.extract(least, 8, 8),
		bit32.extract(least, 16, 8),
		bit32.rshift(least, 24),
		bit32.band(most, 0xFF),
		bit32.extract(most, 8, 8),
		bit32.extract(most, 16, 8),
		bit32.rshift(most, 24)
	)
end

--[=[
	Converts the provided `u64` to a string of 16 hexadecimal digits.

	The returned string will always be 16 bytes and the number is formatted as
	if it were big-endian. It also always uses lowercase letters.
]=]
local function to_hex_string(u64: vector): string
	local most, least = to_pair(u64)
	return string.format("%08x%08x", most, least)
end

--[=[
	Converts the provided `u64` to a string of 64 binary digits.

	The returned string will always be 64 bytes and the number is formatted as
	if it were big-endian.
]=]
local function to_bin_string(u64: vector): string
	-- Manually implemtning a binary conversion is not any faster, and
	-- this is a lot easier.
	return (string.gsub(to_hex_string(u64), "(.)", HEX_TO_BINARY))
end

--[=[
	Returns the provided value parsed as a 64-bit integer. Expects the provided
	string to contain only the digits 0-9 and will error if it does not.
	
	Leading zeros are accepted and parsed appropriately.

	Due to the implementation, the resulting integer will wrap around if it is
	too large to fit in a 64-bit integer rather than erroring.
]=]
local function from_dec_string(str: string): vector
	if string.find(str, "%D") then
		local pos, digit = string.match(str, "()(%D)")
		local hex = string.format("0x%02x", string.byte(digit :: any))
		error(`unexpected character '{digit}' ({hex}) at position {pos} while parsing decimal string`)
	end
	local low, high = 0, 0
	for i = 1, #str do
		-- The ascii code for zero is `48`.
		local digit = string.byte(str, i, i) - 48

		low *= 10
		high = high * 10 + low // 2 ^ 32
		low = bit32.bor(low, 0) + digit

		if low >= 2 ^ 32 then
			low -= 2 ^ 32
			high += 1
		end
	end

	return from_pair(high, low)
end

--[=[
	Returns the provided value as a string of decimal digits.
	
	Equivalent to formatting normal numbers with `%u` or
	calling `tostring` on them.
]=]
local function to_dec_string(u64: vector): string
	if countlz(u64) >= 11 then
		return tostring(to_f64(u64))
	else
		local q, rem = div_32(u64, 1e9)
		local q_hi, q_lo = to_pair(q)
		if q_hi == 0 and q_lo < 1e9 then
			return string.format("%u%09u", q_lo, rem)
		else
			return string.format("%s%09u", to_dec_string(q), rem)
		end
	end
end

-- TODO: replace and extract
-- TODO: vararg versions of band, bor, bxor

return {
	--- A constant representing the 64-bit representation of `0`.
	ZERO = ZERO,
	--- A constant representating the 64-bit representation of `1`.
	ONE = ONE,
	--- A constant representating the 64-bit representation of `2`.
	TWO = TWO,
	--- A constant representing the maximum possible 64-bit value
	--- (`18446744073709551615`, or `2 ^ 64 - 1`)
	MAX = MAX,
	--- A constant representing the maximum possible 32-bit value
	--- (`4294967295`, or `2 ^ 32 - 1`).
	MAX_U32 = MAX_U32,
	--- A constant representing the maximum integer that is exactly representable
	--- by a normal Luau number (`9007199254740992` or `2 ^ 53`).
	MAX_F64 = MAX_F64,
	--- A constant representing the maximum integer that is exactly representable
	--- by a 32-bit floating point value (`16777216`, or `2 ^ 24`).
	MAX_F32 = MAX_F32,

	from_pair = from_pair,
	from_u32 = from_u32,
	from_f64 = from_f64,

	to_pair = to_pair,
	to_quartet = to_quartet,
	to_f64 = to_f64,

	lt = lt,
	lt_equal = lt_equal,
	gt = gt,
	gt_equal = gt_equal,
	is_zero = is_zero,

	band = band,
	bor = bor,
	bxor = bxor,
	btest = btest,

	bnot = bnot,
	byteswap = byteswap,
	countlz = countlz,
	countrz = countrz,

	rshift = rshift,
	arshift = arshift,
	rrotate = rrotate,
	lshift = lshift,
	lrotate = lrotate,

	add = add,
	sub = sub,
	mult = mult,
	div = div,
	pow = pow,

	to_byte_string = to_byte_string,
	from_byte_string = from_byte_string,

	to_buffer = to_buffer,
	write_to_buffer = write_to_buffer,
	from_buffer = from_buffer,

	to_hex_string = to_hex_string,
	to_bin_string = to_bin_string,

	to_dec_string = to_dec_string,
	from_dec_string = from_dec_string,
}
