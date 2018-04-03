TableContainsKey = function(Table, SearchedFor)
	for Key, Value in pairs(Table) do
		if Key == SearchedFor then
			return true
		end
	end
    return false
end

TableContainsValue = function(Table, SearchedFor)
	for Key, Value in pairs(Table) do
		if Value == SearchedFor then
			return true
		end
	end
    return false
end

StringSplit = function(Input, Seperator)
	Result = {}
	for match in (Input .. Seperator):gmatch("(.-)" .. Seperator) do
		table.insert(Result, match)
	end
	return Result
end

GetOSSep = function()
	if os.getenv('HOME') then
		return '/'
	end
	return '\\\\'
end

