name "Jixel-bbq"
author "Taylor"
version "v1.0.1"
description "BBQ Script By Taylor"
fx_version "cerulean"
game "gta5"


shared_scripts { 'config.lua', 'locales/*.lua',	'shared/*.lua' }
server_scripts { 'server/*.lua' }
client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
	'client/*.lua'
}

lua54 'yes'

dependency '/assetpacks'
