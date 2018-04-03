SpawnLocations = {
				  {261.4586, -998.8196, -99.00863},
				  {-18.07856, -583.6725, 79.46569},
				  {-35.31277, -580.4199, 88.71221},
				  {-1468.14, -541.815, 73.4442},
				  {-1477.14, -538.7499, 55.5264},
				  {-915.811, -379.432, 113.6748},
				  {-614.86, 40.6783, 97.60007},
				  {-773.407, 341.766, 211.397},
				  {-169.286, 486.4938, 137.4436},
				  {340.9412, 437.1798, 149.3925},
				  {373.023, 416.105, 145.7006},
				  {-676.127, 588.612, 145.1698},
				  {-763.107, 615.906, 144.1401},
				  {-857.798, 682.563, 152.6529},
				  {120.5, 549.952, 184.097},
				  {-1288, 440.748, 97.69459},
				  {261.4586, -998.8196, -99.00863},
				  {-18.07856, -583.6725, 79.46569},
				  {-35.31277, -580.4199, 88.71221},
				  {-1468.14, -541.815, 73.4442},
				  {-1477.14, -538.7499, 55.5264},
				  {-915.811, -379.432, 113.6748},
				  {-614.86, 40.6783, 97.60007},
				  {-773.407, 341.766, 211.397},
				  {-169.286, 486.4938, 137.4436},
				  {340.9412, 437.1798, 149.3925},
				  {373.023, 416.105, 145.7006},
				  {-676.127, 588.612, 145.1698},
				  {-763.107, 615.906, 144.1401},
				  {-857.798, 682.563, 152.6529},
				  {120.5, 549.952, 184.097},
				  {-1288, 440.748, 97.69459},
			     }



local function GetRandomVehicle()
	local RandomIndex = GetRandomIntInRange(1, #Vehicles)
	if not IsModelValid(GetHashKey(Vehicles[RandomIndex])) then
		return GetRandomVehicle()
	end
	return GetHashKey(Vehicles[RandomIndex])
end

local function GetRandomPed()
	local RandomIndex = GetRandomIntInRange(1, #Peds)
	if not IsModelValid(GetHashKey(Peds[RandomIndex][1])) then
		return GetRandomPed()
	end
	return Peds[RandomIndex][1]
end

function SpawnMe()
	ReferenceProp = NetworkGetEntityFromNetworkId(SpawnedProps[1])
	if IsPedInAnyVehicle(PlayerPedId(), false) then
		SetEntityAsMissionEntity(GetVehiclePedIsIn(PlayerPedId(), false), true, true)
		DeleteEntity(GetVehiclePedIsIn(PlayerPedId(), false))
	end
	
	local Vehicle = GetRandomVehicle(); SpawnLocation = MapReceived[3].Vehicles[PlayerId() + 1];
		  X = tonumber(SpawnLocation.X); Y = tonumber(SpawnLocation.Y); Z = tonumber(SpawnLocation.Z);
		  Pitch = tonumber(SpawnLocation.Pitch); Roll = tonumber(SpawnLocation.Roll); Yaw = tonumber(SpawnLocation.Yaw);
	
	if not HasModelLoaded(Vehicle) then
		RequestModel(Vehicle)
		while not HasModelLoaded(Vehicle) do
			Citizen.Wait(0)
		end
	end
	
	local VehicleHandle = CreateVehicle(Vehicle, X, Y, Z, 0.0, true, false)
	while not VehicleHandle do
		Citizen.Wait(0)
	end
	SetPedIntoVehicle(PlayerPedId(), VehicleHandle, -1)
	SetEntityCoords(VehicleHandle, X, Y, Z, false, false, false, false)
	SetEntityRotation(VehicleHandle, Pitch, Roll, Yaw, 0, true)
	
	SetVehicleDoorsLocked(VehicleHandle, 4)
	SetVehicleDoorsLockedForAllPlayers(VehicleHandle, true)
	SetVehicleHasBeenOwnedByPlayer(VehicleHandle, true)
	
	SetModelAsNoLongerNeeded(Vehicle)
	
	Citizen.Wait(2500)
	
	SetVehicleOnGroundProperly(VehicleHandle)
	FreezeEntityPosition(VehicleHandle, true)
	
	DoScreenFadeIn(2500)
	while IsScreenFadingIn() do
		Citizen.Wait(0)
	end

	TriggerServerEvent('DD:Server:Ready', PlayerId())
	
	GameStarted = true
	return ShowNotification('~g~' .. GetLabelText('FM_COR_FLCH'):gsub('~a~', MapReceived[2]))
end

RegisterNetEvent('DD:Client:SpawnMe')
AddEventHandler('DD:Client:SpawnMe', function(Vehicle, MapName, Prop, SpawnLocation)
end)

AddEventHandler('onClientMapStart', function()
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

	Respawn()
	exports.spawnmanager:setAutoSpawn(false)
	TriggerServerEvent('DD:Server:IsGameRunning')
end)

