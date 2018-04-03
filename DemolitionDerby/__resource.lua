resource_manifest_version '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

description 'Demolition Derby - A gamemode by Scotty & Flatracer'

client_script {
	'CLIENT/Peds.lua',
	'CLIENT/Vehicles.lua',
	'CLIENT/GlobalFunctions.lua',
	'CLIENT/TimeAndWeatherSync.lua',
	'CLIENT/MapSpawn.lua',
	'CLIENT/PlayerSpawn.lua',
	'CLIENT/MainThread.lua',
	'CLIENT/Client.lua',
}

server_script {
	'SERVER/GlobalFunctions.lua',
	'SERVER/SlotReserving.lua',
	'SERVER/MapToLUA.lua',
	'SERVER/MapsManager.lua',
	'SERVER/Events.lua',
	'SERVER/Server.lua',
}
