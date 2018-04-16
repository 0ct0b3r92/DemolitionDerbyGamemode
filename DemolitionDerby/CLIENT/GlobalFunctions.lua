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

function Respawn()
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

