RegisterCommand("bugreport", function(Source, Arguments, RawCommand)
	local date = os.date('*t')
	if date.month < 10 then date.month = '0' .. tostring(date.month) end
	if date.day < 10 then date.day = '0' .. tostring(date.day) end
	if date.hour < 10 then date.hour = '0' .. tostring(date.hour) end
	if date.min < 10 then date.min = '0' .. tostring(date.min) end
	if date.sec < 10 then date.sec = '0' .. tostring(date.sec) end

	local Content = ''
	local LatestBugReport = LoadResourceFile(GetCurrentResourceName(), 'BugReports' .. GetOSSep() .. 'BugReport_' .. CurrentVersion .. '_' .. date.day .. '.' .. date.month .. '.' .. date.year .. '.txt')
	if LatestBugReport then
		Content = LatestBugReport
	end
	
	local Report = ''
	for Key, Value in pairs(Arguments) do
		local Seperator = ' '
		if Key == #Arguments then
			Seperator = ''
		end
		Report = Report .. Value .. Seperator
	end
	
	Content = Content .. Report .. '\n'
	
	SaveResourceFile(GetCurrentResourceName(), 'BugReports' .. GetOSSep() .. 'BugReport_' .. CurrentVersion .. '_' .. date.day .. '.' .. date.month .. '.' .. date.year .. '.txt', Content, -1)

	print(GetPlayerName(Source) .. ' reported a bug!\n>> ' .. Content)
end, false)

