RegisterNetEvent('DD:Client:Countdown')
AddEventHandler('DD:Client:Countdown', function(State)
	StartState = State
end)

RegisterNetEvent('DD:Client:Ready')
AddEventHandler('DD:Client:Ready', function(Player)
	table.insert(ReadyPlayers, Player)
end)

RegisterNetEvent('DD:Client:GameFinished')
AddEventHandler('DD:Client:GameFinished', function()
	GameStarted = false; GameRunning = false; StartState = nil; ReadyPlayers = {}
	if NetworkIsInSpectatorMode() then
		Spectate(false, PlayerId())
	end
	CurrentlySpectating = -1
	Respawn()
end)

RegisterNetEvent('DD:Client:SpawnMap')
AddEventHandler('DD:Client:SpawnMap', function(MapName, MapTable, Source)
	MapReceived[2] = MapName
	MapReceived[3] = MapTable
	MapReceived[4] = Source
--	if GetPlayerServerId(PlayerId()) == Source then
		MapReceived[1] = true
--[[	else
		MapReceived[1] = false
	end]]
end)

RegisterNetEvent('DD:Client:MapInformations')
--AddEventHandler('DD:Client:MapInformations', function(Props, RefZ, RandomVehicleClass)
AddEventHandler('DD:Client:MapInformations', function(RandomVehicleClass)
--	ReferenceZ = RefZ
--	SpawnedProps = Props
	VehicleClass = RandomVehicleClass
	
	MySpawnPosition = MapReceived[3].Vehicles[PlayerId() + 1]
	if MySpawnPosition then
		SpawnMeNow = true
	end
end)

RegisterNetEvent('DD:Client:SyncTimeAndWeather')
AddEventHandler('DD:Client:SyncTimeAndWeather', function(Time, Weather)
	if not NetworkIsHost() then
		SetClockDate(Time.Day, Time.Month, Time.Year)
		SetClockTime(Time.Hour, Time.Minute, Time.Second)
		SetWeatherTypeNow(Weather)
		SetOverrideWeather(Weather)
	end
end)

RegisterNetEvent('DD:Client:IsGameRunning')
AddEventHandler('DD:Client:IsGameRunning', function(Player)
	if NetworkIsHost() then
		TriggerServerEvent('DD:Server:IsGameRunningAnswer', Player, GameStarted)
	end
end)

RegisterNetEvent('DD:Client:IsGameRunningAnswer')
AddEventHandler('DD:Client:IsGameRunningAnswer', function(State)
	GameStarted = State; GameRunning = State
	if not GameStarted then
		Respawn()
	end
end)

AddEventHandler('onClientGameTypeStart', function()
	for Key, Value in ipairs(SpawnLocations) do
		local SpawnPoint = exports.spawnmanager:addSpawnPoint(
															  {
															   x = Value[1],
															   y = Value[2],
															   z = Value[3],
															   heading = 0.0,
															   model = GetRandomPed()
															  }
															 )
		SpawnLocations[Key] = SpawnPoint
	end

	exports.spawnmanager:setAutoSpawn(false)
	
	if NetworkGetNumConnectedPlayers() > 1 then
		TriggerServerEvent('DD:Server:IsGameRunning')
	else
		TriggerEvent('DD:Client:IsGameRunningAnswer', false)
	end
end)

