local MaxPing = 400

RegisterServerEvent('DD:Server:AFKKick')
AddEventHandler('DD:Server:AFKKick', function()
	DropPlayer(source, 'AFK for too long!')
end)

RegisterServerEvent('DD:Server:PingCheck')
AddEventHandler('DD:Server:PingCheck', function()
	if GetPlayerPing(source) > MaxPing then
		DropPlayer(source, 'Ping too high. (' .. GetPlayerPing(source) .. '/' .. MaxPing .. ')')
	end
end)
