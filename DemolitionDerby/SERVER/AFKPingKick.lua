local maxPing = 400

RegisterServerEvent('DD:Server:AFKKick')
AddEventHandler('DD:Server:AFKKick', function()
  DropPlayer(source, 'You were AFK for too long. (3 minutes)')
end)

RegisterServerEvent('DD:Server:PingKick')
AddEventHandler('DD:Server:PingKick', function()
  local ping = GetPlayerPing(source)
  if ping > maxPing then
    DropPlayer(source, 'Your ping was too high. (' .. ping .. '/' .. maxPing .. ')')
  end
end)
