-- Variables
startingGame = false
timermax = 121
startTimer = 0

-- Commands

-- Threads

-- Events
RegisterNetEvent('gameStartTimer')
AddEventHandler('gameStartTimer', function()
	if startTimer == 0 then
		startTimer = 0
		startTimer = startTimer + timermax
		while startTimer > 0 do
			startTimer = startTimer - 1
			TriggerClientEvent('updateStartTimer', -1, startTimer)
			Citizen.Wait(1000)
			if startTimer == 1 then
				startingGame = true
				TriggerClientEvent('updateStartingGame', -1, startingGame)
				TriggerClientEvent('startGame', -1)
			end
		end
	elseif startTimer ~= 0 then
		CancelEvent()
	end
end)

RegisterServerEvent('forceStartGame')
AddEventHandler('forceStartGame', function()
	Citizen.Wait(1)
	if startTimer > 0 then
		while startTimer > 0 do
			startTimer = startTimer - 1
			TriggerClientEvent('updateStartTimer', -1, startTimer)
			Citizen.Wait(100)
			if startTimer == 1 then
				startingGame = true
				TriggerClientEvent('updateStartingGame', -1, startingGame)
				TriggerClientEvent('startGame', -1)
			end
		end
	end
end)

-- Functions
