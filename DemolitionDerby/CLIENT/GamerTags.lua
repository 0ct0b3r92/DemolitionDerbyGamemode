Citizen.CreateThread(function()
	local PlayerTags = {}
	local Players = GetPlayers()
	while true do
		Citizen.Wait(0)
		
		for Player = 0, 256 do
			if Player ~= PlayerId() then
				if PlayerTags[Player + 1] and IsMpGamerTagActive(PlayerTags[Player + 1]) then
					if NetworkIsPlayerActive(Player) and not IsPlayerDead(Player) then
						SetMpGamerTagVisibility(PlayerTags[Player + 1], 0, true)
						SetMpGamerTagVisibility(PlayerTags[Player + 1], 9, NetworkIsPlayerTalking(Player))
					else
						if IsMpGamerTagActive(PlayerTags[Player + 1]) then
							RemoveMpGamerTag(PlayerTags[Player + 1])
						end
						table.remove(PlayerTags, Player + 1)
					end
				else
					if NetworkIsPlayerActive(Player) and not IsPlayerDead(Player) then
						if not PlayerTags[Player + 1] or not IsMpGamerTagActive(PlayerTags[Player + 1]) then
							PlayerTags[Player + 1] = CreateMpGamerTag(GetPlayerPed(Player), GetPlayerName(Player), false, false, '', false)
						end
					end
				end
			end
		end
	end
end)

