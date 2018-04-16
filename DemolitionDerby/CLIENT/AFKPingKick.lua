local  timeUntilKicked = 180
local  timeUntilChecked = 1
local time = timeUntilKicked

Citizen.CreateThread(function()
  while true do
    TriggerServerEvent('DD:Server:PingKick')
    local prevPlyCoords = GetEntityCoords(GetPlayerPed(-1))
    Citizen.Wait(timeUntilChecked * 1000)
    local plyCoords = GetEntityCoords(GetPlayerPed(-1))
    if prevPlyCoords == plyCoords then
      if time > 0 then
        time = time - 1
      else
        TriggerServerEvent('DD:Server:AFKKick')
      end
    else
      time = 0
    end
  end
end)
      
    
