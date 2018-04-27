Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local x = 0.825
		local y = 0.1
		DrawTxt('~y~Players Demolished: ' .. '0' .. '/' .. GetNumberOfPlayers(), x, y)
		y = y + 0.03
		DrawTxt('~y~Players left: ', x, y)
		y = y + 0.03
		DrawTxt('~b~Player', x, y)
		--DrawTxt('~b~W/L', x + 0.125, y)
		y = y + 0.03
		for i,p in pairs(GetPlayers()) do
            if IsPedDeadOrDying(GetPlayerPed(p[1])) then
                DrawTxt('~r~' .. p[2], x, y)
            else
                DrawTxt('~g~' .. p[2], x, y)
            end
            y = y + 0.03
        end
		DrawRect(x + 0.075, (0.1 + (y - 0.1) / 2), 0.16, 0.03 + (y - 0.1), 0, 0, 0, 50)
	end
end)
