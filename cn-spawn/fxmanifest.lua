fx_version 'cerulean'
games {'gta5'}

ui_page "html/index.html"

files({
	"html/*",
	"html/images/*",
	"html/css/*",
	"html/webfonts/*",
	"html/js/*"
})

client_script "client/cl_*.lua"
shared_script "shared/sh_spawn.lua"
server_script '@mysql-async/lib/MySQL.lua' 
server_script "server/sv_*.lua"
