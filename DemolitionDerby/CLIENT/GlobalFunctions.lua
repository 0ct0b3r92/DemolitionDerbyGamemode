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

function Respawn()
	exports.spawnmanager:spawnPlayer(SpawnLocations[PlayerId() + 1])
	
	Citizen.Wait(5000)

	SetPedRandomComponentVariation(PlayerPedId(), false)
	SetPedRandomProps(PlayerPedId())
end

