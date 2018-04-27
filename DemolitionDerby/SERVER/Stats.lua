wins = nil;losses = nil;kills = nil

RegisterServerEvent('DD:Server:DB:CheckAndInsert')
AddEventHandler('DD:Server:DB:CheckAndInsert', function()
	local source = source
	local identifier = GetPlayerIdentifiers(source)[1]

	MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier=@identifier', {['@identifier'] = identifier}, function(result)
		if result[1] == nil then
			MySQL.Async.execute("INSERT INTO users (identifier, wins, losses, kills) VALUES (@identifier, @wins, @losses, @kills)", {['@identifier'] = identifier, ['@wins'] = 0, ['@losses'] = 0, ['@kills'] = 0})
		end
	end)
end)

RegisterServerEvent("DD:Server:AddWin")
AddEventHandler("DD:Server:AddWin", function()
	local identifier = GetPlayerIdentifiers(source)[1]
    MySQL.Async.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {
        ["@identifier"] = identifier
    }, function(user_data)
        MySQL.Async.execute("UPDATE users SET wins = @new_wins WHERE identifier = @identifier", {
            ["@identifier"] = identifier,
            ["@new_wins"] = user_data[1].wins + 1
        }, function(rows_changed)
        
            print(tostring("Win Added To " .. identifier))

        end)
    end)
end)

RegisterServerEvent("DD:Server:UpdateWins")
AddEventHandler("DD:Server:UpdateWins", function()
	local identifier = GetPlayerIdentifiers(source)[1]
    MySQL.Async.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {
        ["@identifier"] = identifier
    }, function(user_data)
	
		local wins = user_data[1].wins
		TriggerClientEvent('DD:Client:UpdateWins', wins)
		print(tostring("Win Updated For " .. identifier))
		 
	end)
end)

RegisterServerEvent("DD:Server:AddLoss")
AddEventHandler("DD:Server:AddLoss", function()
	local identifier = GetPlayerIdentifiers(source)[1]
    MySQL.Async.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {
        ["@identifier"] = identifier
    }, function(user_data)
        MySQL.Async.execute("UPDATE users SET losses = @new_losses WHERE identifier = @identifier", {
            ["@identifier"] = identifier,
            ["@new_losses"] = user_data[1].losses + 1
        }, function(rows_changed)
        
            print(tostring("Loss Added To " .. identifier))

        end)
    end)
end)
