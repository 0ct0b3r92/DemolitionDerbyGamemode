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

function SpawnMe()
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
	
	
	DoScreenFadeIn(2500)
	while IsScreenFadingIn() do
		Citizen.Wait(0)
	end

	TriggerServerEvent('DD:Server:Ready', PlayerId())
	
	GameStarted = true
	return ShowNotification('~g~' .. GetLabelText('FM_COR_FLCH'):gsub('~a~', MapReceived[2]))
end

