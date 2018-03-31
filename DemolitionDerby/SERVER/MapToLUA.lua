function TableContains(Table, SearchedFor)
	for k, v in pairs(Table) do
		if k == SearchedFor then
			return true
		end
	end
    return false
end

function stringsplit(input, seperator)
    result = {}
    for match in (input .. seperator):gmatch("(.-)" .. seperator) do
        table.insert(result, match)
    end
    return result
end

function GetMenyooSub(String)
	local StringSplitted = stringsplit(String, '\n')
	local NewString = ''
	for k, Line in ipairs(StringSplitted) do
		if k >= 19 and k < #StringSplitted then
			NewString = NewString .. '\n' .. Line
		end
	end
	return NewString
end

function MenyooToLUA(String)
	local StringSplitted = stringsplit(String, '\n'); ReturnTable = {};
		  TempTable = {}; PlacementStart = false
	for k, Line in ipairs(StringSplitted) do
		if Line:find('<Placement>') then
			PlacementStart = true
		elseif Line:find('</Placement>') then
			table.insert(ReturnTable, TempTable)
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

function MapEditorToLUA(String)
	local StringSplitted = stringsplit(String, '\n'); ReturnTable = {};
		  TempTable = {}; MapObjectStart = false; Rotation = false; Quaternion = false
	for k, Line in ipairs(StringSplitted) do
		if String:find('xml') then
			local Replace = {['Hash'] = 'ModelHash', ['rX'] = 'Pitch', ['rY'] = 'Roll', ['rZ'] = 'Yaw'}
			if Line:find('<MapObject>') then
				MapObjectStart = true
			elseif Line:find('</MapObject>') then
				table.insert(ReturnTable, TempTable)
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
					if TableContains(Replace, Key) then
						Key = Replace[Key]
					end
					if KeyBegin ~= ValueEnd then
						TempTable[Key] = Line:sub(KeyEnd + 1, ValueEnd - 1)
					end
				end
			end
		else
			local Replace = {['Prop name'] = 'HashName', ['hash'] = 'ModelHash', ['x'] = 'X', ['y'] = 'Y', ['z'] = 'Z', ['rotationx'] = 'Pitch', ['rotationy'] = 'Roll', ['rotationz'] = 'Yaw'}
			local LineSplitted = stringsplit(Line, ', ')
			for i, Part in ipairs(LineSplitted) do
				local PartSplitted = stringsplit(Part, ' = ')
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
	if String:find('<SpoonerPlacements>') then
		Table = MenyooToLUA(GetMenyooSub(String))
	else
		Table = MapEditorToLUA(String)
	end
	return Table
end
