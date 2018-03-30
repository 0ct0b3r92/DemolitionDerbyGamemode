-- Variables
local acePermissionsRequired = false
local startingGame = false
local startTimer = 0
local neededToStart = 1

-- Commands
RegisterCommand('forcestart', function(source, args, rawCommand)
    TriggerServerEvent('forceStartGame')
	ShowNotification('~r~Demolition Derby\n~w~You force started the game.')
end, acePermissionsRequired)

-- Threads
Citizen.CreateThread(function()
	while not startingGame do
		Citizen.Wait(0)
		if PlayersNeededToStart(neededToStart) and not startingGame then
			DrawTxt('Time Until Game Starts: ~r~' .. startTimer .. ' ~w~seconds')
			TriggerServerEvent('gameStartTimer')
			ShowNotification('~r~Demolition Derby\n~w~Sufficient players have joined, starting in 2 minutes.')
		else
			local onlinePlayers = GetNumberOfPlayers()
			DrawTxt('Waiting for ~r~' .. neededToStart - onlinePlayers .. ' ~w~player(s) to join.')
		end
	end
end)	

-- Events
RegisterNetEvent('startGame')
AddEventHandler('startGame', function(newStartTimer)
    
end)
	
RegisterNetEvent('updateStartTimer')
AddEventHandler('updateStartTimer', function(newStartTimer)
    startTimer = newStartTimer
end)

RegisterNetEvent('updateStartingGame')
AddEventHandler('updateStartingGame', function(newStartingGame)
    startingGame = newStartingGame
end)

-- Functions
function PlayersNeededToStart(amountNeeded)
	local onlinePlayers = GetNumberOfPlayers()
	if onlinePlayers < amountNeeded then
		return false
	else
		return true
	end
end

function DrawTxt(text)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.0, 0.45)
    SetTextDropshadow(1, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry('STRING')
    AddTextComponentString(text)
    DrawText(0.40, 0.035)
end

function ShowNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(0, 1)
end
