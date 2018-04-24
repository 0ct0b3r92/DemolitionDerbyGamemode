GameStarted = false; GameRunning = false; StartState = nil; ReadyPlayers = {}; CurrentlySpectating = -1; RequestingDone = false; CountdownScaleform = nil

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

local function RemoveMyVehicle()
	if IsPedInAnyVehicle(PlayerPedId(), false) then
		SetEntityAsMissionEntity(GetVehiclePedIsIn(PlayerPedId(), false), true, true)
		DeleteEntity(GetVehiclePedIsIn(PlayerPedId(), false))
	end
end

local function TeleportMyBodyAway()
	if not IsEntityAtCoord(PlayerPedId(), 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0, 1, 0) then
		SetEntityVisible(PlayerPedId(), false, 0)
		SetEntityCollision(PlayerPedId(), false, 0)
		SetEntityCoords(PlayerPedId(), 0.0, 0.0, 0.0, false, false, false, false)
	end
end

local function SetSpectating()
	local LivingPlayer = GetLivingPlayers()
	CurrentlySpectating = LivingPlayer[GetRandomIntInRange(1, #LivingPlayer)]
	while IsPlayerDead(CurrentlySpectating) do
		Citizen.Wait(0)
		LivingPlayer = GetLivingPlayers()
		CurrentlySpectating = LivingPlayer[GetRandomIntInRange(1, #LivingPlayer)]
	end
	Spectate(true, CurrentlySpectating)
end

local function PreviousPlayer(LivingPlayer, CurrentKey)
	local LivingPlayer = GetLivingPlayers()
	if CurrentKey and CurrentKey == 1 then
		CurrentlySpectating = LivingPlayer[#LivingPlayer]
	else
		CurrentlySpectating = LivingPlayer[CurrentKey - 1]
	end
	ScreenFadeOut(1500)
	Spectate(true, CurrentlySpectating)
	ScreenFadeIn(1500)
end

local function NextPlayer(LivingPlayer, CurrentKey)
	local LivingPlayer = GetLivingPlayers()
	if CurrentKey and CurrentKey < #LivingPlayer then
		CurrentlySpectating = LivingPlayer[CurrentKey + 1]
	else
		CurrentlySpectating = LivingPlayer[1]
	end
	ScreenFadeOut(1500)
	Spectate(true, CurrentlySpectating)
	ScreenFadeIn(1500)
end

local function SpectatingControl()
	AttachEntityToEntity(PlayerPedId(), GetPlayerPed(CurrentlySpectating), 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, true, 1, false)
	
	local LivingPlayer = GetLivingPlayers()
	local CurrentKey = GetKeyInTable(LivingPlayer, CurrentlySpectating)
	
	if IsPlayerDead(CurrentlySpectating) then
		NextPlayer(LivingPlayer, CurrentKey)
	end
	
	ScaleformHandle = PreIBUse("INSTRUCTIONAL_BUTTONS", {{['Slot'] = 0, ['Control'] = 175, ['Text'] = GetLabelText('HUD_SPECDN')}, {['Slot'] = 1, ['Control'] = 174, ['Text'] = GetLabelText('HUD_SPECUP')}})
	DrawScaleformMovieFullscreen(ScaleformHandle, 255, 255, 255, 255, 0)
	
	if IsControlJustPressed(1, 174) then
		PreviousPlayer(LivingPlayer, CurrentKey)
	elseif IsControlJustPressed(1, 175) then
		NextPlayer(LivingPlayer, CurrentKey)
	end
end

local function Countdown(State)
	local CountdownMessages = {{GetLabelText('collision_yq6ipu7') .. '!', ''}, {'...', ''}, {GetLabelText('collision_3mddt3c'), ''}}
	if not HasScaleformMovieLoaded(CountdownScaleform) then
		CountdownScaleform = RequestScaleformMovie('MP_BIG_MESSAGE_FREEMODE')
		while not HasScaleformMovieLoaded(CountdownScaleform) do
			Citizen.Wait(0)
		end
	end

	if State ~= 0 then
		BeginScaleformMovieMethod(CountdownScaleform, 'SHOW_SHARD_WASTED_MP_MESSAGE')
		PushScaleformMovieMethodParameterString('~r~' .. CountdownMessages[State][1])
		PushScaleformMovieMethodParameterString('~y~' .. CountdownMessages[State][2])
		EndScaleformMovieMethod()
		DrawScaleformMovieFullscreen(CountdownScaleform, 255, 255, 255, 255)
	else
		if not GameRunning then
			GameRunning = true
		end
	end
	
--[[	if State == 3 then
		Draw(GetLabelText('collision_3mddt3c'), 0, 40, 200, 255, 0.5, 0.5, 0.5, 0.5, 2, true, 0) --"Get Ready"
	elseif State == 2 then
		Draw('...', 0, 40, 200, 255, 0.5, 0.5, 0.5, 0.5, 2, true, 0) --"..."
	elseif State == 1 then
		Draw(GetLabelText('collision_yq6ipu7') .. '!', 0, 40, 200, 255, 0.5, 0.5, 0.5, 0.5, 2, true, 0) --"GO!"
	elseif State == 0 then
		GameRunning = true
	end]]
end

Citizen.CreateThread(function()
	local AT = {'fmmc'}
	local Players; RescueFadedOutScreen = true
	while true do
		Citizen.Wait(0)
		if RescueFadedOutScreen then
			if IsScreenFadedOut() then
				ScreenFadeIn(2500)
			end
			RescueFadedOutScreen = false
		end
		
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
			if not GameStarted and (#Players > 1) and IsControlJustPressed(1, 166) then
				TriggerServerEvent('DD:Server:GetRandomMap')
				GameStarted = true
			end
		end
	end
end)

Citizen.CreateThread(function()
	while not RequestingDone do
		Citizen.Wait(0)
	end

	local Players, LivingPlayer, ScaleformHandle, ScaleformCheckValue = -1
	local WaitingForOtherPlayers = {{['Slot'] = 0, ['Control'] = 'Load', ['Text'] = GetLabelText('FM_COR_WAIT')}};
		  HostStart = {{['Slot'] = 0, ['Control'] = 166, ['Text'] = GetLabelText('R2P_MENU_LAU')}};
		  WaitingForHost = {{['Slot'] = 0, ['Control'] = 'Load', ['Text'] = GetLabelText('FM_COR_HEIWAIT')}};
		  MorePlayerNeeded = {{['Slot'] = 0, ['Control'] = 'Load', ['Text'] = GetLabelText('PM_WAIT')}, {['Slot'] = 1, ['Control'] = -1, ['Text'] = GetLabelText('FM_UNB_TEAM'):gsub('~1~', '2'):gsub('~a~', 'Demolition Derby'):gsub('~r~', ''):gsub('~s~', '')}};

	while true do
		Citizen.Wait(0)
		Players = GetPlayers()
		LivingPlayer = GetLivingPlayers()
		
		HideHudAndRadarThisFrame()
		BlockWeaponWheelThisFrame()
		SetCurrentPedWeapon(PlayerPedId(), GetHashKey('WEAPON_UNARMED'), true)

		if not GameStarted and not GameRunning then
			if IsScreenFadedOut() then
				ScreenFadeIn(2500)
			end
			
			if not IsPlayerDead(PlayerId()) then
				SetEntityInvincible(PlayerPedId(), true)
			end
			
			if #Players > 1 then
				if NetworkIsHost() then
					if ScaleformCheckValue ~= 1 then
						ScaleformHandle = PreIBUse("INSTRUCTIONAL_BUTTONS", HostStart)
						ScaleformCheckValue = 1
					end
					DrawScaleformMovieFullscreen(ScaleformHandle, 255, 255, 255, 255, 0)
				else
					if ScaleformCheckValue ~= 2 then
						ScaleformHandle = PreIBUse("INSTRUCTIONAL_BUTTONS", WaitingForHost)
						ScaleformCheckValue = 2
					end
					DrawScaleformMovieFullscreen(ScaleformHandle, 255, 255, 255, 255, 0)
				end
			else
				if ScaleformCheckValue ~= 3 then
					ScaleformHandle = PreIBUse("INSTRUCTIONAL_BUTTONS", MorePlayerNeeded)
					ScaleformCheckValue = 3
				end
				DrawScaleformMovieFullscreen(ScaleformHandle, 255, 255, 255, 255, 0)
			end			
		elseif GameStarted and not GameRunning then
			SetEntityInvincible(PlayerPedId(), false)
			local WaitingTime = GetGameTimer(); Waiting = true
			while Waiting do
				Citizen.Wait(0)
				Draw(GetLabelText('FM_COR_PRDY'):gsub('~1~', #ReadyPlayers, 1):gsub('~1~', #Players), 0, 40, 200, 255, 0.5, 0.5, 0.5, 0.5, 2, true, 0) --"*Specific Amount* of *Amount Players* ready"
				if ScaleformCheckValue ~= 0 then
					ScaleformHandle = PreIBUse("INSTRUCTIONAL_BUTTONS", WaitingForOtherPlayers)
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
				if StartState then
					Countdown(StartState)
				end
			end
		elseif GameStarted and GameRunning then
			if IsPlayerDead(PlayerId()) then
				if #LivingPlayer > 1 then
					if not NetworkIsInSpectatorMode() then
						ScreenFadeOut(2500)
						RemoveMyVehicle()
						TeleportMyBodyAway()
						SetSpectating()
						ScreenFadeIn(2500)
					end
					if #LivingPlayer > 1 then
						SpectatingControl()
					end
				end
			else
				if not IsPedInAnyVehicle(PlayerPedId(), false) then
					SetEntityHealth(PlayerPedId(), 0)
				end
				if #LivingPlayer <= 1 then
					GameStarted = false; GameRunning = false; StartState = nil; ReadyPlayers = {}
					ScreenFadeOut(2500)
					RemoveMyVehicle()
					TeleportMyBodyAway()
					TriggerServerEvent('DD:Server:GameFinished')
				else
					SetPedCanBeKnockedOffVehicle(PlayerPedId(), 1)
					SetPedConfigFlag(PlayerPedId(), 32, false)
					if IsPedRagdoll(PlayerPedId()) then
						SetPedIntoVehicle(PlayerPedId(), GetVehiclePedIsIn(PlayerPedId(), false), -1)
					end
					SetEntityInvincible(PlayerPedId(), false)
					FreezeEntityPosition(PlayerPedId(), false)
					FreezeEntityPosition(GetVehiclePedIsIn(PlayerPedId(), false), false)
					local MyCoords = GetEntityCoords(PlayerPedId(), true)
					
					if ReferenceZ - MyCoords.z > 10.0 then
						NetworkExplodeVehicle(GetVehiclePedIsIn(PlayerPedId(), false), true, true, 0)
					end
				end
			end
		end
	end
end)

