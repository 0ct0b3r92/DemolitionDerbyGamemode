local MaxSlots = 32
local WaitingDuration = 5 --Seconds

AddEventHandler('playerConnecting', function(PlayerName, KickReason, Deferrals)
	if GetConvarInt('UseQueue', 0) == 1 then
		Deferrals.defer()

		local Source = source
		
		local Tries = 0
		Citizen.CreateThread(function()
			while Tries < tonumber(GetConvarInt('QueueMaxTries', 10)) do
				Tries = Tries + 1
				if GetNumPlayerIndices() < (MaxSlots - tonumber(GetConvar('ReservedSlots', 0))) then
					Deferrals.update('Yeah, got a free Slot. Joining now!')
					Deferrals.done()
					return
				elseif GetNumPlayerIndices() >= (MaxSlots - tonumber(GetConvar('ReservedSlots', 0))) then
					if IsPlayerAceAllowed(Source, 'DD') and not (GetNumPlayerIndices() == MaxSlots) then
						Deferrals.update('Admin detected, using reserved slot. Joining now!')
						Deferrals.done()
					else
						Deferrals.update('No free Slot, trying again in ' .. WaitingDuration .. ' Seconds. - Tries: ' .. Tries .. '/' .. (GetConvar('QueueMaxTries', 10)))
					end
				end
				if Tries ~= tonumber(GetConvarInt('ReservedSlots', 0)) then
					Citizen.Wait(WaitingDuration * 1000)
				end
			end
			Deferrals.done('No free Slot, try again later.')
		end)
	end
end)

