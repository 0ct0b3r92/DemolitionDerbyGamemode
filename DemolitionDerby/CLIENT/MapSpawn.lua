SpawnedProps = {}; MapReceived = {false}; SpawnMeNow = false; MapSpawned = false; MySpawnPosition = nil; ReferenceZ = 0.0

function SpawnMap(MapName, MapTable)
	if #MapTable.Vehicles >= 32 then
		for Key, Value in ipairs(SpawnedProps) do
			while DoesEntityExist(NetworkGetEntityFromNetworkId(Value)) do
				Citizen.Wait(0)
				NetworkRequestControlOfNetworkId(Value)
				NetworkRequestControlOfEntity(NetworkGetEntityFromNetworkId(Value))
				DeleteObject(NetworkGetEntityFromNetworkId(Value))
			end
		end
		SpawnedProps = {}
		
		for Key, Value in ipairs(MapTable.Props) do
			if Key == 1 then
				ReferenceZ = tonumber(Value.Z)
			end
			if IsModelValid(tonumber(Value.ModelHash)) then
				if not HasModelLoaded(tonumber(Value.ModelHash)) then
					RequestModel(tonumber(Value.ModelHash))
					while not HasModelLoaded(tonumber(Value.ModelHash)) do
						Citizen.Wait(0)
					end
					local Dynamic = false
					if Value.Dynamic == 'true' then
						Dynamic = true
					end
				end
				local Prop = CreateObjectNoOffset(tonumber(Value.ModelHash), tonumber(Value.X), tonumber(Value.Y), tonumber(Value.Z), true, false, Dynamic)
				SetEntityCoords(Prop, tonumber(Value.X), tonumber(Value.Y), tonumber(Value.Z), false, false, false, false)
				if tonumber(Value.Pitch) < 0.0 then
					Value.Pitch = 180.0 + math.abs(tonumber(Value.Pitch))
				end
				SetEntityRotation(Prop, tonumber(Value.Pitch), tonumber(Value.Roll), tonumber(Value.Yaw), 3, 0)
				FreezeEntityPosition(Prop, true)
				SetEntityAsMissionEntity(Prop, true, true)
				SetModelAsNoLongerNeeded(tonumber(Value.ModelHash))
				
				local PropNetID = NetworkGetNetworkIdFromEntity(Prop)
				for i = 1, 10 do
					PropNetID = NetworkGetNetworkIdFromEntity(Prop)
					NetworkRegisterEntityAsNetworked(Prop)
					SetNetworkIdCanMigrate(PropNetID, true)
					SetNetworkIdExistsOnAllMachines(PropNetID, true)
					NetworkRequestControlOfEntity(Prop)
				end

				table.insert(SpawnedProps, PropNetID)
			end
		end
		MapSpawned = true
	else
		GameStarted = false
		ShowNotification('~r~' .. GetLabelText('FMMC_RANDFAIL'))
		ShowNotification('~y~' .. GetLabelText('USJ_FAILSAFE'))
	end
end

RegisterNetEvent('DD:Client:SpawnMap')
AddEventHandler('DD:Client:SpawnMap', function(MapName, MapTable, Source)
	MapReceived[2] = MapName
	MapReceived[3] = MapTable
	if GetPlayerServerId(PlayerId()) == Source then
		MapReceived[1] = true
	end
end)

RegisterNetEvent('DD:Client:Props')
AddEventHandler('DD:Client:Props', function(Props, RefZ)
	ReferenceZ = RefZ
	SpawnedProps = Props
	
	MySpawnPosition = MapReceived[3].Vehicles[PlayerId() + 1]
	if MySpawnPosition then
		SpawnMeNow = true
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if MapReceived[1] then
			SpawnMap(MapReceived[2], MapReceived[3])
			MapReceived[1] = false
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if MapSpawned then
			TriggerServerEvent('DD:Server:Props', SpawnedProps, ReferenceZ)
			MapSpawned = false
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if SpawnMeNow then
			SpawnMe()
			SpawnMeNow = false
		end
	end
end)