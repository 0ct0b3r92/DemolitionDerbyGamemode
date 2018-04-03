function SyncTimeAndWeather()
	local WeatherTypes = {[GetHashKey('BLIZZARD')] = 'BLIZZARD',
						  [GetHashKey('CLEAR')] = 'CLEAR',
						  [GetHashKey('CLEARING')] = 'CLEARING',
						  [GetHashKey('CLOUDS')] = 'CLOUDS',
						  [GetHashKey('EXTRASUNNY')] = 'EXTRASUNNY',
						  [GetHashKey('FOGGY')] = 'FOGGY',
						  [GetHashKey('LIGHTSNOW')] = 'LIGHTSNOW',
						  [GetHashKey('NEUTRAL')] = 'NEUTRAL',
						  [GetHashKey('OVERCAST')] = 'OVERCAST',
						  [GetHashKey('RAIN')] = 'RAIN',
						  [GetHashKey('SMOG')] = 'SMOG',
						  [GetHashKey('SNOW')] = 'SNOW',
						  [GetHashKey('THUNDER')] = 'THUNDER',
						  [GetHashKey('XMAS')] = 'XMAS',
						 }

	local Time = {['Year'] = GetClockYear(), ['Month'] = GetClockMonth(), ['Day'] = GetClockDayOfMonth(), ['Hour'] = GetClockHours(), ['Minute'] = GetClockMinutes(), ['Second'] = GetClockSeconds()}
	local Weather = WeatherTypes[GetPrevWeatherTypeHashName()]
	TriggerServerEvent('DD:Server:SyncTimeAndWeather', Time, Weather)
end

RegisterNetEvent('DD:Client:SyncTimeAndWeather')
AddEventHandler('DD:Client:SyncTimeAndWeather', function(Time, Weather)
	if not NetworkIsHost() then
		SetClockDate(Time.Date, Time.Month, Time.Day)
		SetClockTime(Time.Hour, Time.Minute, Time.Second)
		SetWeatherTypeNow(Weather)
		SetOverrideWeather(Weather)
	end
end)

