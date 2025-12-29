return {
	-- Basic Logic Gates
	AND = function(one, two)
		return one == true and two == true
	end,
	NOT = function(one)
		return one ~= true
	end,
	NAND = function(one, two)
		return not (one == true and two == true)
	end,
	NOR = function(one, two)
		return not (one == true or two == true)
	end,
	OR = function(one, two)
		return one == true or two == true
	end,
	XOR = function(one, two)
		return (one == true) ~= (two == true)
	end,
	XNOR = function(one, two)
		return (one == true) == (two == true)
	end,

	BUFFER = function(one)
		return one == true
	end,
	IMPLY = function(a, b)
		return (a ~= true) or (b == true)
	end,

	-- Multi-input Gates
	AND3 = function(a, b, c)
		return a == true and b == true and c == true
	end,
	OR3 = function(a, b, c)
		return a == true or b == true or c == true
	end,
	XOR3 = function(a, b, c)
		local count = 0
		if a == true then
			count = count + 1
		end
		if b == true then
			count = count + 1
		end
		if c == true then
			count = count + 1
		end
		return count % 2 == 1
	end,
	NAND3 = function(a, b, c)
		return not (a == true and b == true and c == true)
	end,
	ANDn = function(...)
		for _, v in ipairs({ ... }) do
			if v ~= true then
				return false
			end
		end
		return true
	end,
	ORn = function(...)
		for _, v in ipairs({ ... }) do
			if v == true then
				return true
			end
		end
		return false
	end,
	XORn = function(...)
		local count = 0
		for _, v in ipairs({ ... }) do
			if v == true then
				count = count + 1
			end
		end
		return count % 2 == 1
	end,

	-- Multiplexers and Demultiplexers
	MUX2 = function(sel, a, b)
		return sel == true and b == true or sel ~= true and a == true
	end,
	MUX4 = function(sel1, sel0, a, b, c, d)
		if sel1 == false and sel0 == false then
			return a == true
		elseif sel1 == false and sel0 == true then
			return b == true
		elseif sel1 == true and sel0 == false then
			return c == true
		elseif sel1 == true and sel0 == true then
			return d == true
		end
	end,
	MUX8 = function(sel2, sel1, sel0, a, b, c, d, e, f, g, h)
		local inputs = { a, b, c, d, e, f, g, h }
		local index = 1
		if sel0 == true then
			index = index + 1
		end
		if sel1 == true then
			index = index + 2
		end
		if sel2 == true then
			index = index + 4
		end
		return inputs[index] == true
	end,
	DEMUX2 = function(sel, input)
		return sel == false and input == true, sel == true and input == true
	end,
	DEMUX4 = function(sel1, sel0, input)
		return {
			(sel1 == false and sel0 == false and input == true) or false,
			(sel1 == false and sel0 == true and input == true) or false,
			(sel1 == true and sel0 == false and input == true) or false,
			(sel1 == true and sel0 == true and input == true) or false,
		}
	end,

	-- Arithmetic Functions
	HalfAdder = function(a, b)
		local sum = (a == true) ~= (b == true) -- XOR
		local carry = a == true and b == true -- AND
		return sum, carry
	end,
	FullAdder = function(a, b, cin)
		local sum1, carry1 = (a == true) ~= (b == true), a == true and b == true
		local sum2, carry2 = sum1 ~= (cin == true), sum1 and cin == true
		local finalSum = sum2
		local finalCarry = carry1 or carry2
		return finalSum, finalCarry
	end,
	HalfSubtractor = function(a, b)
		local diff = (a == true) ~= (b == true) -- XOR
		local borrow = (a ~= true) and (b == true) -- NOT A AND B
		return diff, borrow
	end,
	FullSubtractor = function(a, b, bin)
		local diff1 = (a == true) ~= (b == true) -- XOR
		local borrow1 = (a ~= true) and (b == true) -- NOT A AND B
		local diff2 = diff1 ~= (bin == true) -- XOR with borrow in
		local borrow2 = (diff1 ~= true) and (bin == true) -- NOT diff1 AND bin
		local finalDiff = diff2
		local finalBorrow = borrow1 or borrow2
		return finalDiff, finalBorrow
	end,

	-- Flip-Flops and Latches
	SRLatch = function(s, r, prev_q)
		if s == true and r == true then
			return nil, nil -- Invalid state
		elseif s == true and r == false then
			return true, false -- Set
		elseif s == false and r == true then
			return false, true -- Reset
		else
			return prev_q, prev_q ~= true -- Hold previous state
		end
	end,
	DLatch = function(d, enable, prev_q)
		if enable == true then
			return d == true, d ~= true
		else
			return prev_q, prev_q ~= true -- Hold previous state
		end
	end,
	JKFlipFlop = function(j, k, clk, prev_q)
		if clk == true then -- Rising edge trigger (simplified)
			if j == false and k == false then
				return prev_q, prev_q ~= true -- Hold
			elseif j == false and k == true then
				return false, true -- Reset
			elseif j == true and k == false then
				return true, false -- Set
			else -- j == true and k == true
				return prev_q ~= true, prev_q -- Toggle
			end
		else
			return prev_q, prev_q ~= true -- Hold on non-clock
		end
	end,

	-- Encoders and Decoders
	Encoder4to2 = function(i0, i1, i2, i3)
		if i3 == true then
			return true, true
		elseif i2 == true then
			return true, false
		elseif i1 == true then
			return false, true
		else
			return false, false
		end
	end,
	Encoder8to3 = function(i0, i1, i2, i3, i4, i5, i6, i7)
		if i7 == true then
			return true, true, true
		elseif i6 == true then
			return true, true, false
		elseif i5 == true then
			return true, false, true
		elseif i4 == true then
			return true, false, false
		elseif i3 == true then
			return false, true, true
		elseif i2 == true then
			return false, true, false
		elseif i1 == true then
			return false, false, true
		else
			return false, false, false
		end
	end,
	Decoder2to4 = function(a1, a0, enable)
		enable = enable or true -- Default enable to true if not provided
		local outputs = {}
		for i = 0, 3 do
			local match = ((i % 2 == 1) == (a0 == true)) and (math.floor(i / 2) == 1) == (a1 == true)
			outputs[i + 1] = enable == true and match
		end
		return outputs[1], outputs[2], outputs[3], outputs[4]
	end,
	Decoder3to8 = function(a2, a1, a0, enable)
		enable = enable or true
		local outputs = {}
		for i = 0, 7 do
			local match = ((i % 2 == 1) == (a0 == true))
				and (math.floor(i / 2) % 2 == 1) == (a1 == true)
				and (math.floor(i / 4) == 1) == (a2 == true)
			outputs[i + 1] = enable == true and match
		end
		return table.unpack(outputs)
	end,

	-- Comparators
	Comparator1Bit = function(a, b)
		local equal = (a == true) == (b == true)
		local greater = (a == true) and (b ~= true)
		local less = (a ~= true) and (b == true)
		return equal, greater, less
	end,

	-- Priority Encoders
	PriorityEncoder4to2 = function(i0, i1, i2, i3)
		if i3 == true then
			return true, true, true -- Valid output
		elseif i2 == true then
			return true, false, true
		elseif i1 == true then
			return false, true, true
		elseif i0 == true then
			return false, false, true
		else
			return false, false, false -- No valid input
		end
	end,

	-- Parity Generators/Checkers
	ParityGenEven = function(...)
		local count = 0
		for _, v in ipairs({ ... }) do
			if v == true then
				count = count + 1
			end
		end
		return count % 2 == 0 -- Even parity: return true if even number of 1s
	end,
	ParityGenOdd = function(...)
		local count = 0
		for _, v in ipairs({ ... }) do
			if v == true then
				count = count + 1
			end
		end
		return count % 2 == 1 -- Odd parity: return true if odd number of 1s
	end,

	-- Magnitude Comparator
	MagnitudeComp4Bit = function(a3, a2, a1, a0, b3, b2, b1, b0)
		local a_bits = { a3, a2, a1, a0 }
		local b_bits = { b3, b2, b1, b0 }

		-- Compare from MSB to LSB
		for i = 1, 4 do
			if (a_bits[i] == true) and (b_bits[i] ~= true) then
				return false, true, false -- A > B
			elseif (a_bits[i] ~= true) and (b_bits[i] == true) then
				return false, false, true -- A < B
			end
		end
		return true, false, false -- A == B
	end,

	-- Barrel Shifter (4-bit)
	BarrelShift4 = function(d3, d2, d1, d0, s1, s0, direction)
		local data = { d3, d2, d1, d0 }
		local shift_amount = 0
		if s0 == true then
			shift_amount = shift_amount + 1
		end
		if s1 == true then
			shift_amount = shift_amount + 2
		end

		local result = { false, false, false, false }
		for i = 1, 4 do
			local src_idx
			if direction == "left" then
				src_idx = ((i - 1 - shift_amount) % 4) + 1
			else -- right shift
				src_idx = ((i - 1 + shift_amount) % 4) + 1
			end
			if src_idx >= 1 and src_idx <= 4 then
				result[i] = data[src_idx]
			end
		end
		return result[1], result[2], result[3], result[4]
	end,

	-- Text/Binary Conversion
	TextToBinary = function(text)
		local binary = {}
		for i = 1, #text do
			local char = text:sub(i, i)
			local byte = string.byte(char)
			local bin = ""
			for j = 7, 0, -1 do
				bin = bin .. ((math.floor(byte / (2 ^ j)) % 2 == 1) and "1" or "0")
			end
			table.insert(binary, bin)
		end
		return table.concat(binary, " ")
	end,

	BinaryToText = function(binary)
		local text = ""
		for bin in binary:gmatch("[01][01][01][01][01][01][01][01]") do
			local byte = tonumber(bin, 2)
			if byte and byte >= 0 and byte <= 255 then
				text = text .. string.char(byte)
			end
		end
		return text
	end,

	-- Utility Functions
	ToBinary = function(num, bits)
		bits = bits or 8
		local binary = ""
		for i = bits - 1, 0, -1 do
			binary = binary .. ((math.floor(num / (2 ^ i)) % 2 == 1) and "1" or "0")
		end
		return binary
	end,

	FromBinary = function(binary)
		local num = 0
		for i = 1, #binary do
			local bit = binary:sub(i, i)
			if bit == "1" then
				num = num + 2 ^ (#binary - i)
			end
		end
		return num
	end,

	-- Gray Code Converter
	BinaryToGray = function(b3, b2, b1, b0)
		local g3 = b3
		local g2 = (b3 == true) ~= (b2 == true) -- XOR
		local g1 = (b2 == true) ~= (b1 == true) -- XOR
		local g0 = (b1 == true) ~= (b0 == true) -- XOR
		return g3, g2, g1, g0
	end,

	GrayToBinary = function(g3, g2, g1, g0)
		local b3 = g3
		local b2 = (b3 == true) ~= (g2 == true) -- XOR
		local b1 = (b2 == true) ~= (g1 == true) -- XOR
		local b0 = (b1 == true) ~= (g0 == true) -- XOR
		return b3, b2, b1, b0
	end,

	-- BCD Functions
	BCD7Segment = function(b3, b2, b1, b0)
		-- Returns segments a,b,c,d,e,f,g for 7-segment display
		local patterns = {
			[0] = { true, true, true, true, true, true, false }, -- 0
			[1] = { false, true, true, false, false, false, false }, -- 1
			[2] = { true, true, false, true, true, false, true }, -- 2
			[3] = { true, true, true, true, false, false, true }, -- 3
			[4] = { false, true, true, false, false, true, true }, -- 4
			[5] = { true, false, true, true, false, true, true }, -- 5
			[6] = { true, false, true, true, true, true, true }, -- 6
			[7] = { true, true, true, false, false, false, false }, -- 7
			[8] = { true, true, true, true, true, true, true }, -- 8
			[9] = { true, true, true, true, false, true, true }, -- 9
		}

		local value = 0
		if b0 == true then
			value = value + 1
		end
		if b1 == true then
			value = value + 2
		end
		if b2 == true then
			value = value + 4
		end
		if b3 == true then
			value = value + 8
		end

		if patterns[value] then
			return table.unpack(patterns[value])
		else
			return false, false, false, false, false, false, false -- Invalid BCD
		end
	end,
}
