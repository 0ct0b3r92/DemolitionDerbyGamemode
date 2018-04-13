RegisterServerEvent('DD:Server:AFKKick')
AddEventHandler('DD:Server:AFKKick', function()
  DropPlayer(source, 'You were AFK for too long. (3 minutes)')
end)
