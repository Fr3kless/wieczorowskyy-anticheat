
fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'wieczorovskyyy'

client_script {
    'cloader.lua'
}

server_script {
	'@oxmysql/lib/MySQL.lua',
    'config/svconfig.lua',
    'server/server.lua',
    'sloader.lua'
}

ui_page('html/index.html') 

files { 	
    'html/*.html',      
}