fx_version 'cerulean'
game 'gta5'
name 'Supreme_Crafting'
version '1.0.0'
description 'Crafting'
lua54 'yes'

shared_script {
	'@ox_lib/init.lua',
	'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}


