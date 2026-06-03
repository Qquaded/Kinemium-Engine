local fs = zune.fs

local executableData = {}

local MAGIC_SIGNATURE = "KINDATA_"
local TRAILER_SIZE = #MAGIC_SIGNATURE + 4 -- 4 bytes for uint32 size

function executableData.appendFile(executablePath, dataPath, outputPath)
	local exeData = fs.readFile(executablePath)
	local appendData = fs.readFile(dataPath)

	if not exeData then
		error("Failed to read executable file: " .. tostring(executablePath))
	end
	if not appendData then
		error("Failed to read data file: " .. tostring(dataPath))
	end

	local size = #appendData
	local sizeStr = string.pack("<I4", size)

	local finalData = exeData .. appendData .. MAGIC_SIGNATURE .. sizeStr
	fs.writeFile(outputPath or executablePath, finalData)
	return true
end

function executableData.appendData(executablePath, rawData, outputPath)
	if typeof(rawData) == "buffer" then
		rawData = buffer.tostring(rawData)
	end
	local exeData = fs.readFile(executablePath)

	if not exeData then
		error("Failed to read executable file: " .. tostring(executablePath))
	end

	local size = #rawData
	local sizeStr = string.pack("<I4", size)

	local finalData = exeData .. rawData .. MAGIC_SIGNATURE .. sizeStr
	fs.writeFile(outputPath or executablePath, finalData)
	return true
end

function executableData.appendBuffer(executablePath, bufferData, outputPath)
	if typeof(bufferData) ~= "buffer" then
		error("appendBuffer expected a buffer, got " .. typeof(bufferData))
	end
	return executableData.appendData(executablePath, bufferData, outputPath)
end

function executableData.readData(executablePath)
	local exeData = fs.readFile(executablePath)

	if not exeData then
		error("Failed to read executable file: " .. tostring(executablePath))
	end

	if #exeData < TRAILER_SIZE then
		return nil, "File too small to contain appended data"
	end

	local endPart = string.sub(exeData, -TRAILER_SIZE, -1)
	local magic = string.sub(endPart, 1, #MAGIC_SIGNATURE)

	if magic ~= MAGIC_SIGNATURE then
		return nil, "No appended data signature found"
	end

	local sizeStr = string.sub(endPart, #MAGIC_SIGNATURE + 1, -1)
	local size = string.unpack("<I4", sizeStr)

	if #exeData < size + TRAILER_SIZE then
		return nil, "Appended data is corrupted or incomplete"
	end

	local appendData = string.sub(exeData, -TRAILER_SIZE - size, -TRAILER_SIZE - 1)
	return appendData
end

function executableData.readDataAsBuffer(executablePath)
	local data, err = executableData.readData(executablePath)
	if data then
		return buffer.fromstring(data)
	end
	return nil, err
end

function executableData.hasAppendedData(executablePath)
	local exeData = fs.readFile(executablePath)

	if not exeData or #exeData < TRAILER_SIZE then
		return false
	end

	local endPart = string.sub(exeData, -TRAILER_SIZE, -1)
	local magic = string.sub(endPart, 1, #MAGIC_SIGNATURE)

	return magic == MAGIC_SIGNATURE
end

return executableData
