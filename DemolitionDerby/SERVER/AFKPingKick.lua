local MaxPing = 300; MaxPingPoints = 10
PingPoints = {}

RegisterServerEvent('DD:Server:AFKKick')
AddEventHandler('DD:Server:AFKKick', function()
	DropPlayer(source, 'AFK for too long!')
end)

RegisterServerEvent('DD:Server:PingCheck')
AddEventHandler('DD:Server:PingCheck', function()
	if not PingPoints[source] then PingPoints[source] = 0 end
	if GetPlayerPing(source) > MaxPing then
		PingPoints[source] = PingPoints[source] + 1
	end
	if PingPoints[source] > MaxPingPoints then
		PingPoints[source] = 0
		DropPlayer(source, 'Ping too high. (' .. GetPlayerPing(source) .. '/' .. MaxPing .. ')')
	end
end)

