-- Kinet | Luau-Based Network Solution
-- made by devcell

return {
	Server = require("./KiNet/Server"),
	Client = require("./KiNet/Client"),
	Serializer = require("./KiNet/Serializer"),
	SerializerAdapters = require("./KiNet/SerializerAdapters"),

	TCPServer = require("./KiNet/TCPServer"),
	TCPClient = require("./KiNet/TCPClient"),

	ClientType = require("./KiNet/ClientTypes"),
	ServerType = require("./KiNet/ServerTypes"),
}
