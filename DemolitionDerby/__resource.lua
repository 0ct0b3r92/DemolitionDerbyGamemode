resource_type 'gametype' { name = 'Demolition Derby' }

resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'Demolition Derby - A gamemode by Scotty & Flatracer'

client_script {
	'CLIENT/client.lua',
}

server_script {
	'SERVER/SlotReserving.lua',
	'SERVER/server.lua',
}
