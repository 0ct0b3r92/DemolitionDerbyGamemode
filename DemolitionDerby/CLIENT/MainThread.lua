GameStarted = false; GameRunning = false; StartState = nil; ReadyPlayers = {}; CurrentlySpectating = -1

local function GetLivingPlayers()
	local Players = GetPlayers()
	local LivingPlayers = {}
	for Key, Player in ipairs(Players) do
		if not IsPlayerDead(Player[1]) then
			table.insert(LivingPlayers, Player[1])
		end
	end
	return LivingPlayers
end

local function ScreenFadeOut()
	DoScreenFadeOut(2500)
	while IsScreenFadingOut() do
		Citizen.Wait(0)
	end
end

local function ScreenFadeIn()
	DoScreenFadeIn(2500)
	while IsScreenFadingIn() do
		Citizen.Wait(0)
	end
end

local function RemoveMyVehicle()
	if IsPedInAnyVehicle(PlayerPedId(), false) then
		SetEntityAsMissionEntity(GetVehiclePedIsIn(PlayerPedId(), false), true, true)
		DeleteEntity(GetVehiclePedIsIn(PlayerPedId(), false))
	end
end

local function TeleportMyBodyAway()
	if not IsEntityAtCoord(PlayerPedId(), 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0, 1, 0) then
		FreezeEntityPosition(PlayerPedId(), true)
		SetEntityCoords(PlayerPedId(), 0.0, 0.0, 0.0, false, false, false, false)
	end
end

local function Spectate(Toggle, Player)
	NetworkSetOverrideSpectatorMode(Toggle)
	NetworkSetInSpectatorMode(Toggle, GetPlayerPed(Player))
end

local function SetSpectating(LivingPlayer)
	if not NetworkIsInSpectatorMode() then
		CurrentlySpectating = LivingPlayer[GetRandomIntInRange(1, #LivingPlayer)]
		while IsPlayerDead(CurrentlySpectating) do
			Citizen.Wait(0)
			LivingPlayer = GetLivingPlayers()
			CurrentlySpectating = LivingPlayer[GetRandomIntInRange(1, #LivingPlayer)]
		end
		Spectate(true, CurrentlySpectating)
	end
end

local function SpectatingControl(LivingPlayer)
	if IsControlJustPressed(1, 34) or IsControlJustPressed(1, 174) then
		LivingPlayer = GetLivingPlayers()
		local CurrentKey = GetKeyInTable(LivingPlayer, CurrentlySpectating)
		if CurrentKey == 1 then
			CurrentlySpectating = LivingPlayer[#LivingPlayer]
		else
			CurrentlySpectating = LivingPlayer[CurrentKey - 1]
		end
		Spectate(true, CurrentlySpectating)
	elseif IsControlJustPressed(1, 35) or IsControlJustPressed(1, 175) then
		LivingPlayer = GetLivingPlayers()
		local CurrentKey = GetKeyInTable(LivingPlayer, CurrentlySpectating)
		if CurrentKey < #LivingPlayer then
			CurrentlySpectating = LivingPlayer[CurrentKey + 1]
		else
			CurrentlySpectating = LivingPlayer[1]
		end
		Spectate(true, CurrentlySpectating)
	end
end

Citizen.CreateThread(function()
	local AT = {'fmmc'}; RequestingDone = false
	local Players
	while true do
		Citizen.Wait(0)
		Players = GetPlayers()
		
		if not RequestingDone then
			local CurrentSlot = 0
			for i, CAT in ipairs(AT) do
				while HasAdditionalTextLoaded(CurrentSlot) and not HasThisAdditionalTextLoaded(CAT, CurrentSlot) do
					Citizen.Wait(0)
					CurrentSlot = CurrentSlot + 1
				end
				if not HasThisAdditionalTextLoaded(CAT, CurrentSlot) then
					ClearAdditionalText(CurrentSlot, true)
					RequestAdditionalText(CAT, CurrentSlot)
					while not HasThisAdditionalTextLoaded(CAT, CurrentSlot) do
						Citizen.Wait(0)
					end
				end
			end
			RequestingDone = true
		end
		
		HideHudAndRadarThisFrame()
		BlockWeaponWheelThisFrame()
		SetCurrentPedWeapon(PlayerPedId(), GetHashKey('WEAPON_UNARMED'), true)

		if NetworkIsHost() then
			SyncTimeAndWeather()
			if not GameStarted and (#Players >= 1) and IsControlJustPressed(1, 166) then
				TriggerServerEvent('DD:Server:GetRandomMap')
			end
		end
	end
end)

Citizen.CreateThread(function()
	local Players, LivingPlayer, ScaleformHandle, ScaleformCheckValue = -1
	while true do
		Citizen.Wait(0)
		Players = GetPlayers()
		LivingPlayer = GetLivingPlayers()
		
		HideHudAndRadarThisFrame()
		BlockWeaponWheelThisFrame()
		SetCurrentPedWeapon(PlayerPedId(), GetHashKey('WEAPON_UNARMED'), true)

		if GameStarted and not GameRunning then
			local WaitingTime = GetGameTimer(); Waiting = true
			while Waiting do
				Citizen.Wait(0)
				if ScaleformCheckValue ~= 0 then
					ScaleformHandle = PreIBUse("INSTRUCTIONAL_BUTTONS", {{['Slot'] = 0, ['Control'] = 'Load', ['Text'] = GetLabelText('FM_COR_WAIT')}})
					ScaleformCheckValue = 0
				end
				DrawScaleformMovieFullscreen(ScaleformHandle, 255, 255, 255, 255, 0)
				
				if (#ReadyPlayers == #Players) or ((GetGameTimer() - WaitingTime) >= 10000) then
					Waiting = false
				end
			end
			
			local Timer = GetGameTimer(); State = 3
			while not GameRunning do
				Citizen.Wait(0)
				if NetworkIsHost() then
					if ((GetGameTimer() - Timer) >= (1500 * State)) and not (State == 0) then
						Timer = GetGameTimer()
						State = State - 1
					end
					TriggerServerEvent('DD:Server:Countdown', State)
				end
				if StartState == 3 then
					Draw(GetLabelText('collision_3mddt3c'), 0, 40, 200, 255, 0.5, 0.5, 0.5, 0.5, 2, true, 0) --"Get Ready"
				elseif StartState == 2 then
					Draw('...', 0, 40, 200, 255, 0.5, 0.5, 0.5, 0.5, 2, true, 0) --"..."
				elseif StartState == 1 then
					Draw(GetLabelText('collision_yq6ipu7') .. '!', 0, 40, 200, 255, 0.5, 0.5, 0.5, 0.5, 2, true, 0) --"GO"
				elseif StartState == 0 then
					GameRunning = true
				end
			end
		end
		if GameRunning then
			if IsEntityDead(PlayerPedId()) then
				if not NetworkIsInSpectatorMode() then
					ScreenFadeOut()
					RemoveMyVehicle()
					TeleportMyBodyAway()
					if not #LivingPlayer == 1 then
						SetSpectating(LivingPlayer)
						ScreenFadeIn()
					end
				else
					SpectatingControl(LivingPlayer)
				end
			else
				if #LivingPlayer == 1 then
					ScreenFadeOut()
					RemoveMyVehicle()
					TeleportMyBodyAway()
					GameStarted = false; GameRunning = false; StartState = nil
					TriggerServerEvent('DD:Server:GameFinished')
				else
					FreezeEntityPosition(PlayerPedId(), false)
					FreezeEntityPosition(GetVehiclePedIsIn(PlayerPedId(), false), false)
					local MyCoords = GetEntityCoords(PlayerPedId(), true)
					
					if ReferenceZ - MyCoords.z > 10.0 then
						NetworkExplodeVehicle(GetVehiclePedIsIn(PlayerPedId(), false), true, true, 0)
					end
				end
			end
		else
			if #Players >= 2 then
				if NetworkIsHost() then
					if ScaleformCheckValue ~= 1 then
						ScaleformHandle = PreIBUse("INSTRUCTIONAL_BUTTONS", {{['Slot'] = 0, ['Control'] = 166, ['Text'] = GetLabelText('R2P_MENU_LAU')}})
						ScaleformCheckValue = 1
					end
					DrawScaleformMovieFullscreen(ScaleformHandle, 255, 255, 255, 255, 0)
				else
					if ScaleformCheckValue ~= 2 then
						ScaleformHandle = PreIBUse("INSTRUCTIONAL_BUTTONS", {{['Slot'] = 0, ['Control'] = 'Load', ['Text'] = GetLabelText('FM_COR_HEIWAIT')}})
						ScaleformCheckValue = 2
					end
					DrawScaleformMovieFullscreen(ScaleformHandle, 255, 255, 255, 255, 0)
				end
			else
				if ScaleformCheckValue ~= 3 then
					ScaleformHandle = PreIBUse("INSTRUCTIONAL_BUTTONS", {{['Slot'] = 0, ['Control'] = 'Load', ['Text'] = GetLabelText('FM_UNB_TEAM'):gsub('~1~', '2'):gsub('~a~', 'Demolition Derby')}})
					ScaleformCheckValue = 3
				end
				DrawScaleformMovieFullscreen(ScaleformHandle, 255, 255, 255, 255, 0)
			end
		end
	end
end)

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

