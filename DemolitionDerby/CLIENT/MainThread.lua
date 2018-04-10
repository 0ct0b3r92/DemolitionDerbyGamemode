GameStarted = false; GameRunning = false; StartState = nil; ReadyPlayers = {}; CurrentlySpectating = -1; RequestingDone = false

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

local function ScreenFadeOut(Duration)
	DoScreenFadeOut(Duration)
	while IsScreenFadingOut() do
		Citizen.Wait(0)
	end
end

local function ScreenFadeIn(Duration)
	DoScreenFadeIn(Duration)
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

local function SpectatingControl(LivingPlayer)
	ScaleformHandle = PreIBUse("INSTRUCTIONAL_BUTTONS", {{['Slot'] = 0, ['Control'] = 175, ['Text'] = GetLabelText('HUD_SPECDN')}, {['Slot'] = 1, ['Control'] = 174, ['Text'] = GetLabelText('HUD_SPECUP')}})
	DrawScaleformMovieFullscreen(ScaleformHandle, 255, 255, 255, 255, 0)
	if IsControlJustPressed(1, 174) then
		LivingPlayer = GetLivingPlayers()
		local CurrentKey = GetKeyInTable(LivingPlayer, CurrentlySpectating)
		if CurrentKey == 1 then
			CurrentlySpectating = LivingPlayer[#LivingPlayer]
		else
			CurrentlySpectating = LivingPlayer[CurrentKey - 1]
		end
		ScreenFadeOut(1500)
		Spectate(true, CurrentlySpectating)
		ScreenFadeIn(1500)
	elseif IsControlJustPressed(1, 175) then
		LivingPlayer = GetLivingPlayers()
		local CurrentKey = GetKeyInTable(LivingPlayer, CurrentlySpectating)
		if CurrentKey < #LivingPlayer then
			CurrentlySpectating = LivingPlayer[CurrentKey + 1]
		else
			CurrentlySpectating = LivingPlayer[1]
		end
		ScreenFadeOut(1500)
		Spectate(true, CurrentlySpectating)
		ScreenFadeIn(1500)
	end
end

Citizen.CreateThread(function()
	local AT = {'fmmc'}
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
			if not GameStarted and (#Players >= 2) and IsControlJustPressed(1, 166) then
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
			SetEntityInvincible(PlayerPedId(), true)
			if #Players >= 2 then
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
				if StartState == 3 then
					Draw(GetLabelText('collision_3mddt3c'), 0, 40, 200, 255, 0.5, 0.5, 0.5, 0.5, 2, true, 0) --"Get Ready"
				elseif StartState == 2 then
					Draw('...', 0, 40, 200, 255, 0.5, 0.5, 0.5, 0.5, 2, true, 0) --"..."
				elseif StartState == 1 then
					Draw(GetLabelText('collision_yq6ipu7') .. '!', 0, 40, 200, 255, 0.5, 0.5, 0.5, 0.5, 2, true, 0) --"GO!"
				elseif StartState == 0 then
					GameRunning = true
				end
			end
		elseif GameStarted and GameRunning then
			if IsEntityDead(PlayerPedId()) then
				if not NetworkIsInSpectatorMode() then
					ScreenFadeOut(2500)
					RemoveMyVehicle()
					TeleportMyBodyAway()
					SetSpectating()
					ScreenFadeIn(2500)
				else
					if not #LivingPlayer == 1 and not #LivingPlayer == 0 then
						SpectatingControl(LivingPlayer)
					end
				end
			else
				if #LivingPlayer == 1 or #LivingPlayer == 0 then
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

