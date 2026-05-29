local Instance = require("@Instance")
local Enum = require("@EnumMap")

local SQLiteService = Instance.new("SQLiteBaseService")
SQLiteService.ExplorerHidden = true
SQLiteService._Intents = Enum.PluginIntents.Filesystem

local SQLiteBases = {}

SQLiteService.InitRenderer = function(renderer, renderer_signal, datamodel)
	task.spawn(function()
		local sqlite = zune.sqlite
		repeat
			task.wait()
		until datamodel.SerializationService
		local SerializationService = datamodel.SerializationService
		local userdata = SerializationService.userdata

		SQLiteService:SetProperties({
			CreateBase = function(name: string)
				if SQLiteBases[name] then
					return SQLiteBases[name]
				end
				local store = Instance.new("SQLiteStore")
				store.Name = name
				SQLiteBases[name] = store

				local db = sqlite.open(name .. ".db")

				db:exec("CREATE TABLE IF NOT EXISTS datastore(key TEXT PRIMARY KEY, value TEXT)")

				store:SetProperties({
					Open = function(self)
						return db
					end,

					GetAsync = function(key, callback)
						task.spawn(function()
							local success, result = pcall(function()
								local stmt = db:query("SELECT value FROM datastore WHERE key = :key")
								local row = stmt:get({ [":key"] = key })
								if row then
									return userdata.Decode(row.value)
								end
								return nil
							end)
							if callback then
								callback(success, result)
							end
							return result
						end)
					end,

					SetAsync = function(key, value, callback)
						task.spawn(function()
							local success, err = pcall(function()
								db:exec(
									"INSERT INTO datastore(key, value) VALUES (:key, :value) ON CONFLICT(key) DO UPDATE SET value=excluded.value",
									{ [":key"] = key, [":value"] = userdata.Encode(value) }
								)
							end)
							if callback then
								callback(success, err)
							end
						end)
					end,

					UpdateAsync = function(self, key, transform)
						local old = store:GetAsync(key)
						local new = transform(old)
						store:SetAsync(key, new)
						return new
					end,

					Close = function(self)
						db:close()
					end,
				})

				return store
			end,
		})
	end)
end

return SQLiteService
