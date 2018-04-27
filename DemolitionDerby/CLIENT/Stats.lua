wins = 0;losses = 0;kills = 0

AddEventHandler("playerSpawned", function()
	TriggerServerEvent("DD:Server:DB:CheckAndInsert")
	Citizen.Wait(2000)
	TriggerServerEvent('DD:Server:UpdateWins')
end)

RegisterNetEvent('DD:Client:UpdateWins')
AddEventHandler('DD:Client:UpdateWins', function(newWins)
    wins = newWins
end)

RegisterNetEvent('DD:Client:UpdateLosses')
AddEventHandler('DD:Client:UpdateLosses', function(newLosses)
    losses = newLosses
end)
