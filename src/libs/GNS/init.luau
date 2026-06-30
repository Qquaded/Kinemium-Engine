local Server = require("@GNS/Server")
local Client = require("@GNS/Client")
local Serializer = require("@GNS/Serializer")
local SerializerAdapters = require("@GNS/SerializerAdapters")

local ServerInstance = Server.new()
local ClientInstance = Client.new()

return {
	Server = ServerInstance,
	Client = ClientInstance,
	Serializer = Serializer,
	SerializerAdapters = SerializerAdapters,
}
