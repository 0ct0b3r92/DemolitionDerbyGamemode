SpawnMeNow = false; VehicleClass = 0

function SpawnMe()
	if IsPedInAnyVehicle(PlayerPedId(), false) then
		SetEntityAsMissionEntity(GetVehiclePedIsIn(PlayerPedId(), false), true, true)
		DeleteEntity(GetVehiclePedIsIn(PlayerPedId(), false))
	end
	
	local Vehicle = GetRandomVehicleFromClass(VehicleClass); SpawnLocation = MapReceived[3].Vehicles[PlayerId() + 1];
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
	SetEntityRotation(VehicleHandle, Pitch, Roll, Yaw, 0, true)
	SetPedCanBeKnockedOffVehicle(PlayerPedId(), 1)
	SetPedCanBeDraggedOut(PlayerPedId(), false)
	SetPedConfigFlag(PlayerPedId(), 32, false)
	
	FreezeEntityPosition(VehicleHandle, true)
	
	SetVehicleDoorsLocked(VehicleHandle, 4)
	SetVehicleDoorsLockedForAllPlayers(VehicleHandle, true)
	SetVehicleHasBeenOwnedByPlayer(VehicleHandle, true)
	
	SetModelAsNoLongerNeeded(Vehicle)
	
	while not IsEntityAtCoord(VehicleHandle, X, Y, Z, 2.5, 2.5, 1.0, 0, 1, 0) do
		Citizen.Wait(0)
		SetEntityCoords(VehicleHandle, X, Y, Z, false, false, false, false)
		SetEntityRotation(VehicleHandle, Pitch, Roll, Yaw, 0, true)
		SetVehicleOnGroundProperly(VehicleHandle)
	end
	
	ScreenFadeIn(2500)

	TriggerServerEvent('DD:Server:Ready', PlayerId())
	
	GameStarted = true
	return ShowNotification('~g~' .. GetLabelText('FM_COR_FLCH'):gsub('~a~', MapReceived[2]))
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if SpawnMeNow then
			SpawnMe()
			SpawnMeNow = false
		end
	end
end)

