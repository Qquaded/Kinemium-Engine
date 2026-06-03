local Instance = require("@Instance")
local Enum = require("@Enum")

local serde = zune.serde
local crypto = zune.crypto

local EncodingService = Instance.new("EncodingService")
EncodingService.ExplorerHidden = true
EncodingService._Intents = Enum.PluginIntents.Serialization

EncodingService.InitRenderer = function(renderer, renderer_signal, datamodel)
	EncodingService:SetProperties({
		Base64Encode = function(data)
			return serde.base64.encode(data)
		end,

		Base64Decode = function(buf)
			return serde.base64.decode(buf)
		end,

		GetDecompressedBufferSize = function(input, algorithim)
			local decompressed = EncodingService.DecompressBuffer(input, algorithim)
			return buffer.len(decompressed)
		end,

		ComputeBufferHash = function(input, algorithim)
			local secret = buffer.tostring(input)
			if algorithim == Enum.HashAlgorithm.Blake2b then
				return crypto.createHash("Blake2b", secret)
			elseif algorithim == Enum.HashAlgorithm.Blake3 then
				return crypto.createHash("blake3", secret)
			elseif algorithim == Enum.HashAlgorithm.Md5 then
				return crypto.createHash("md5", secret)
			elseif algorithim == Enum.HashAlgorithm.Sha1 then
				return crypto.createHash("sha1", secret)
			elseif algorithim == Enum.HashAlgorithm.Sha256 then
				return crypto.createHash("sha256", secret)
			end
		end,

		CompressBuffer = function(buf, algorithim, compressionLevel: number)
			if algorithim == Enum.CompressionAlgorithm.Zstd then
				return serde.zstd.compress(buf, { level = compressionLevel })
			elseif algorithim == Enum.CompressionAlgorithm.Zlib then
				return serde.zlib.compress(buf, { level = compressionLevel })
			elseif algorithim == Enum.CompressionAlgorithm.lz4 then
				return serde.lz4.compress(buf, { level = compressionLevel })
			elseif algorithim == Enum.CompressionAlgorithm.flate then
				return serde.flate.compress(buf, { level = compressionLevel })
			elseif algorithim == Enum.CompressionAlgorithm.brotli then
				return serde.brotli.compress(buf, { level = compressionLevel })
			end
		end,

		DecompressBuffer = function(buf, algorithim)
			if algorithim == Enum.CompressionAlgorithm.Zstd then
				return serde.zstd.decompress(buf)
			elseif algorithim == Enum.CompressionAlgorithm.Zlib then
				return serde.zlib.decompress(buf)
			elseif algorithim == Enum.CompressionAlgorithm.lz4 then
				return serde.lz4.decompress(buf)
			elseif algorithim == Enum.CompressionAlgorithm.flate then
				return serde.flate.decompress(buf)
			elseif algorithim == Enum.CompressionAlgorithm.brotli then
				return serde.brotli.decompress(buf)
			end
		end,
	})
end

return EncodingService
