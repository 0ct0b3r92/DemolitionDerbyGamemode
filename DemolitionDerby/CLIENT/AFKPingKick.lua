Citizen.CreateThread(function()
	local PlayerCoords = GetEntityCoords(PlayerPedId(), false)
	local AFKMaxDuration = 3 --[[In Minutes]]; PingTimer = GetGameTimer(); AFKTimer = GetGameTimer()
	while true do
		Citizen.Wait(0)
		
		if GetGameTimer() - PingTimer >= 2500 then
			TriggerServerEvent('DD:Server:PingCheck')
			PingTimer = GetGameTimer()
		end
		
		if not IsPlayerDead(PlayerId()) then
			if GetEntityCoords(PlayerPedId(), false) == PlayerCoords then
				if GetGameTimer() - AFKTimer >= (AFKMaxDuration * 60000) then
					TriggerServerEvent('DD:Server:AFKKick')
				elseif GetGameTimer() - AFKTimer == (AFKMaxDuration * 30000) then
					ShowNotification(GetLabelText('HUD_ILDETIME'):gsub('~a~', '1m30s'))
				end				
			else
				AFKTimer = GetGameTimer()
				PlayerCoords = GetEntityCoords(PlayerPedId(), false)
			end
		end
	end
end)
      
    
