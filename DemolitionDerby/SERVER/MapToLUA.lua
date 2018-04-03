local function GetMenyooSub(String)
	local StringSplitted = StringSplit(String, '\n')
	local NewString = ''
	for k, Line in ipairs(StringSplitted) do
		if k >= 19 and k < #StringSplitted then
			NewString = NewString .. Line .. '\n'
		end
	end
	return NewString
end

local function MenyooToLUA(String)
	local StringSplitted = StringSplit(String, '\n')
	local ReturnTable = {['Props'] = {}, ['Vehicles'] = {}};
	local TempTable = {}; PlacementStart = false
	for k, Line in ipairs(StringSplitted) do
		if Line:find('<Placement>') then
			PlacementStart = true
		elseif Line:find('</Placement>') then
			if TempTable.Type == '3' then
				table.insert(ReturnTable.Props, TempTable)
			elseif TempTable.Type == '2' then
				table.insert(ReturnTable.Vehicles, TempTable)
			end
			TempTable = {}
			PlacementStart = false
		elseif PlacementStart then
			if Line:find('</') then
				local KeyBegin = Line:find('<'); KeyEnd = Line:find('>'); ValueEnd = Line:find('</')
				if KeyBegin ~= ValueEnd then
					TempTable[Line:sub(KeyBegin + 1, KeyEnd - 1)] = Line:sub(KeyEnd + 1, ValueEnd - 1)
				end
			end
		end
	end
	return ReturnTable
end

local function MapEditorToLUA(String)
	local StringSplitted = StringSplit(String, '\n'); ReturnTable = {['Props'] = {}, ['Vehicles'] = {}};
		  TempTable = {}; MapObjectStart = false; Rotation = false; Quaternion = false
	for k, Line in ipairs(StringSplitted) do
		if String:find('xml') then
			local Replace = {['Hash'] = 'ModelHash', ['rX'] = 'Pitch', ['rY'] = 'Roll', ['rZ'] = 'Yaw'}
			if Line:find('<MapObject>') then
				MapObjectStart = true
			elseif Line:find('</MapObject>') then
				if TempTable.Type == 'Prop' then
					table.insert(ReturnTable.Props, TempTable)
				elseif TempTable.Type == 'Vehicle' then
					table.insert(ReturnTable.Vehicles, TempTable)
				end
				TempTable = {}
				MapObjectStart = false
			elseif MapObjectStart then
				if Line:find('<Rotation>') then
					Rotation = true
				elseif Line:find('</Rotation>') then
					Rotation = false
				elseif Line:find('<Quaternion>') then
					Quaternion = true
				elseif Line:find('</Quaternion>') then
					Quaternion = false
				elseif Line:find('</') and not Quaternion then
					local KeyBegin = Line:find('<'); KeyEnd = Line:find('>'); ValueEnd = Line:find('</')
					local Key = Line:sub(KeyBegin + 1, KeyEnd - 1)
					if Rotation then
						Key = 'r' .. Key
					end
					if TableContainsKey(Replace, Key) then
						Key = Replace[Key]
					end
					if KeyBegin ~= ValueEnd then
						TempTable[Key] = Line:sub(KeyEnd + 1, ValueEnd - 1)
					end
				end
			end
		else
			local Replace = {['Prop name'] = 'HashName', ['hash'] = 'ModelHash', ['x'] = 'X', ['y'] = 'Y', ['z'] = 'Z', ['rotationx'] = 'Pitch', ['rotationy'] = 'Roll', ['rotationz'] = 'Yaw'}
			local LineSplitted = StringSplit(Line, ', ')
			for i, Part in ipairs(LineSplitted) do
				local PartSplitted = StringSplit(Part, ' = ')
				if PartSplitted[1] ~= 'Prop name' and PartSplitted[1] ~= 'hash' then
					PartSplitted[2] = PartSplitted[2]:gsub(',', '.')
				end
				TempTable[Replace[PartSplitted[1]]] = PartSplitted[2]
			end
			table.insert(ReturnTable, TempTable)
			TempTable = {}
		end
	end
	return ReturnTable
end

function MapToLUA(String)
	local Table
	if String:find('SpoonerPlacements') then
		String = GetMenyooSub(String)
		Table = MenyooToLUA(String)
	else
		Table = MapEditorToLUA(String)
	end
	return Table
end
