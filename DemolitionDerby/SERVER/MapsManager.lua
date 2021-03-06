Maps = {}

local function GetMapsFromPath()
 	print('>>> Getting Maps now!\n')
   Content = ''
	local TMPFile = os.tmpname()
	if os.getenv('HOME') then
		local Result = os.execute('ls -a1 DemolitionDerbyMaps >' .. TMPFile)
	else
		local Result = os.execute('dir "DemolitionDerbyMaps" /b >' .. TMPFile)
	end
	local File = io.open(TMPFile, 'r')
	Content = File:read('*a')
	File:close()
	os.remove(TMPFile)
	local ContentSplitted = StringSplit(Content, '\n')
	for Index, Value in ipairs(ContentSplitted) do
		if Value and Value ~= '.' and Value ~= '..' and Value ~= '' then
			local XMLStart, XMLFinish = Value:lower():find('xml')
			if XMLStart and XMLFinish then
				table.insert(Maps, Value:sub(1, XMLFinish))
			end
		end
	end
end

local function CheckForDefaultMap()
	for i = 1, 3 do
		local DefaultFile = io.open('DemolitionDerbyMaps' .. GetOSSep() .. 'DefaultMap' .. i .. '.xml', 'r')
		if not DefaultFile then
			local BackupMap = LoadResourceFile(GetCurrentResourceName(), 'SERVER' .. GetOSSep() .. 'BackupMaps' .. GetOSSep() .. 'BackupMap' .. i .. '.xml')
			DefaultFile = io.open('DemolitionDerbyMaps' .. GetOSSep() .. 'DefaultMap' .. i .. '.xml', 'w+')
			DefaultFile:write(BackupMap)
			DefaultFile:flush()
		end
		DefaultFile:close()
	end
	GetMapsFromPath()
end

local function CreateFolder()
	print('>>> Creating it!')
	os.execute('mkdir DemolitionDerbyMaps')
	CheckForDefaultMap()
	print('>>> Created the folder "DemolitionDerbyMaps"!\n\n')
end

local function CheckForMapsFolder()
	print('\n\n>> Demolition Derby Gamemode:')
	print('>>> Checking for the folder "DemolitionDerbyMaps"!')
	local Result = os.execute('cd DemolitionDerbyMaps')
	if not Result then
		print('>>> The folder "DemolitionDerbyMaps" does not exist!')
		CreateFolder()
	else
		print('>>> The folder "DemolitionDerbyMaps" does exist!\n\n')
		CheckForDefaultMap()
	end
end

CheckForMapsFolder()