local CurrentlySpawnedProps = {}

RegisterServerEvent('DD:Server:MapInformations')
AddEventHandler('DD:Server:MapInformations', function(SpawnedProps, ReferenceZ, RandomVehicleClass)
	CurrentlySpawnedProps = SpawnedProps
	TriggerClientEvent('DD:Client:MapInformations', -1, CurrentlySpawnedProps, ReferenceZ, RandomVehicleClass)
end)

RegisterServerEvent('DD:Server:SyncTimeAndWeather')
AddEventHandler('DD:Server:SyncTimeAndWeather', function(Time, Weather)
	TriggerClientEvent('DD:Client:SyncTimeAndWeather', -1, Time, Weather)
end)

RegisterServerEvent('DD:Server:Ready')
AddEventHandler('DD:Server:Ready', function(Player)
	TriggerClientEvent('DD:Client:Ready', -1, Player)
end)

RegisterServerEvent('DD:Server:GetRandomMap')
AddEventHandler('DD:Server:GetRandomMap', function()
	local Source = source
	local RandomMapName = Maps[math.random(#Maps)]
	local MapFile = io.open('DemolitionDerbyMaps' .. GetOSSep() .. RandomMapName, 'r')
	local MapFileContent = MapFile:read('*a')
	local MapFileContentToLUA = MapToLUA(MapFileContent)
	MapFile:close()
	TriggerClientEvent('DD:Client:SpawnMap', -1, RandomMapName, MapFileContentToLUA, Source)
end)

RegisterServerEvent('DD:Server:Countdown')
AddEventHandler('DD:Server:Countdown', function(State)
	TriggerClientEvent('DD:Client:Countdown', -1, State)
end)

RegisterServerEvent('DD:Server:GameFinished')
AddEventHandler('DD:Server:GameFinished', function()
	TriggerClientEvent('DD:Client:GameFinished', -1)
end)

RegisterServerEvent('DD:Server:IsGameRunning')
AddEventHandler('DD:Server:IsGameRunning', function()
	if GetNumPlayerIndices() > 1 then
		TriggerClientEvent('DD:Client:IsGameRunning', -1, source)
	else
		TriggerClientEvent('DD:Client:IsGameRunningAnswer', source, false)
	end
end)

RegisterServerEvent('DD:Server:IsGameRunningAnswer')
AddEventHandler('DD:Server:IsGameRunningAnswer', function(Player, State)
	TriggerClientEvent('DD:Client:IsGameRunningAnswer', Player, State)
end)

