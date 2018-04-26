function TableContainsKey(Table, SearchedFor)
	for Key, Value in pairs(Table) do
		if Key == SearchedFor then
			return true
		end
	end
    return false
end

function TableContainsValue(Table, SearchedFor)
	for Key, Value in pairs(Table) do
		if Value == SearchedFor then
			return true
		end
	end
    return false
end

function GetKeyInTable(Table, SearchedFor)
	for Key, Value in pairs(Table) do
		if Value == SearchedFor then
			return Key
		end
	end
    return nil
end

function StringSplit(Input, Seperator)
    Result = {}
    for match in (Input .. Seperator):gmatch("(.-)" .. Seperator) do
        table.insert(Result, match)
    end
    return Result
end

function GetPlayers()
	local Players = {}
	for i = 0, 31 do
		if NetworkIsPlayerConnected(i) and NetworkIsPlayerActive(i) then
			table.insert(Players, {i, GetPlayerName(i)})
		end
	end
    return Players
end

function GetLivingPlayers()
	local Players = GetPlayers()
	local LivingPlayers = {}
	for Key, Player in ipairs(Players) do
		if not IsPlayerDead(Player[1]) then
			table.insert(LivingPlayers, Player[1])
		end
	end
	return LivingPlayers
end

function DrawTxt(text, x, y)
  SetTextFont(0)
  SetTextProportional(1)
  SetTextScale(0.0, 0.35)
  SetTextDropshadow(1, 0, 0, 0, 255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(x, y)
end

function Draw(Text, R, G, B, A, X, Y, Width, Height, Layer, Center, Font)
	SetTextColour(R, G, B, A)
	SetTextFont(Font)
	SetTextScale(Width, Height)
	SetTextWrap(0.0, 1.0)
	SetTextCentre(Center)
	SetTextDropshadow(0, 0, 0, 0, 0)
	SetTextEdge(1, 0, 0, 0, 205)
	SetTextEntry('STRING')
	AddTextComponentSubstringPlayerName(Text)
	Set_2dLayer(Layer)
	DrawText(X, Y)
end

function _DrawRect(X, Y, Width, Height, R, G, B, A, Layer)
	SetUiLayer(Layer)
	DrawRect(X, Y, Width, Height, R, G, B, A)
end

function ShowNotification(Text)
	SetNotificationTextEntry('STRING')
	AddTextComponentSubstringPlayerName(Text)
	DrawNotification(false, true)
end

function GetRandomVehicleClass()
	local Class = GetRandomIntInRange(0, 8)
	if Class == 8 then
		Class = 9
	end
	return Class
end

function GetRandomVehicleFromClass(Class)
	local ClassVehicles = {}
	for Key, Value in ipairs(Vehicles) do
		if GetVehicleClassFromName(GetHashKey(Value)) == Class then
			table.insert(ClassVehicles, Value)
		end
	end
	
	local RandomIndex = GetRandomIntInRange(1, #ClassVehicles)
	local Vehicle = GetHashKey(ClassVehicles[RandomIndex])
	if not IsModelValid(Vehicle) then
		return GetRandomVehicleFromClass(Class)
	end
	return Vehicle
end

function GetRandomPed()
	local RandomIndex = GetRandomIntInRange(1, #Peds)
	if not IsModelValid(GetHashKey(Peds[RandomIndex][1])) then
		return GetRandomPed()
	end
	return Peds[RandomIndex][1]
end

function ScreenFadeOut(Duration)
	DoScreenFadeOut(Duration)
	while IsScreenFadingOut() do
		Citizen.Wait(0)
	end
end

function ScreenFadeIn(Duration)
	DoScreenFadeIn(Duration)
	while IsScreenFadingIn() do
		Citizen.Wait(0)
	end
end

function Spectate(Toggle, Player)
	NetworkSetOverrideSpectatorMode(Toggle)
	NetworkSetInSpectatorMode(Toggle, GetPlayerPed(Player))
end

SpawnLocations = {
				  {261.4586, -998.8196, -99.00863}, {-18.07856, -583.6725, 79.46569},
				  {-35.31277, -580.4199, 88.71221}, {-1468.14, -541.815, 73.4442},
				  {-1477.14, -538.7499, 55.5264}, {-915.811, -379.432, 113.6748},
				  {-614.86, 40.6783, 97.60007}, {-773.407, 341.766, 211.397},
				  {-169.286, 486.4938, 137.4436}, {340.9412, 437.1798, 149.3925},
				  {373.023, 416.105, 145.7006}, {-676.127, 588.612, 145.1698},
				  {-763.107, 615.906, 144.1401}, {-857.798, 682.563, 152.6529},
				  {120.5, 549.952, 184.097}, {-1288, 440.748, 97.69459},
				  {261.4586, -998.8196, -99.00863}, {-18.07856, -583.6725, 79.46569},
				  {-35.31277, -580.4199, 88.71221}, {-1468.14, -541.815, 73.4442},
				  {-1477.14, -538.7499, 55.5264}, {-915.811, -379.432, 113.6748},
				  {-614.86, 40.6783, 97.60007}, {-773.407, 341.766, 211.397},
				  {-169.286, 486.4938, 137.4436}, {340.9412, 437.1798, 149.3925},
				  {373.023, 416.105, 145.7006}, {-676.127, 588.612, 145.1698},
				  {-763.107, 615.906, 144.1401}, {-857.798, 682.563, 152.6529},
				  {120.5, 549.952, 184.097}, {-1288, 440.748, 97.69459},
			     };
				 
function Respawn()
	if GetIsLoadingScreenActive() then
		ShutdownLoadingScreen()
		ShutdownLoadingScreenNui()
	end
	exports.spawnmanager:spawnPlayer(SpawnLocations[PlayerId() + 1])
	
	Citizen.Wait(5000)

	SetPedRandomComponentVariation(PlayerPedId(), false)
	SetPedRandomProps(PlayerPedId())
end

function PreIBUse(ScaleformName, Controls)
	local ScaleformHandle = RequestScaleformMovie(ScaleformName)
	while not HasScaleformMovieLoaded(ScaleformHandle) do
		Citizen.Wait(0)
	end
	
	PushScaleformMovieFunction(ScaleformHandle, "CLEAR_ALL")
	PopScaleformMovieFunctionVoid()
	
	PushScaleformMovieFunction(ScaleformHandle, "SET_CLEAR_SPACE")
	PushScaleformMovieFunctionParameterInt(200)
	PopScaleformMovieFunctionVoid()

	for Key, Value in pairs(Controls) do
		PushScaleformMovieFunction(ScaleformHandle, "SET_DATA_SLOT")
		PushScaleformMovieFunctionParameterInt(Value.Slot)
		if Value.Control == 'Load' then
			PushScaleformMovieMethodParameterInt(50)
		else
			PushScaleformMovieMethodParameterButtonName(GetControlInstructionalButton(0, Value.Control, true))
		end
		BeginTextCommandScaleformString("STRING")
		AddTextComponentScaleform(Value.Text)
		EndTextCommandScaleformString()
		PopScaleformMovieFunctionVoid()
	end

	PushScaleformMovieFunction(ScaleformHandle, "DRAW_INSTRUCTIONAL_BUTTONS")
	PopScaleformMovieFunctionVoid()

	PushScaleformMovieFunction(ScaleformHandle, "SET_BACKGROUND_COLOUR")
	PushScaleformMovieFunctionParameterInt(0)
	PushScaleformMovieFunctionParameterInt(0)
	PushScaleformMovieFunctionParameterInt(0)
	PushScaleformMovieFunctionParameterInt(80)
	PopScaleformMovieFunctionVoid()

	return ScaleformHandle
end

