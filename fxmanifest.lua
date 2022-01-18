fx_version 'adamant'
games { 'rdr3' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'OfficiallyM-'
description 'A simple panel for RedM VORPCORE server moderation'
version '2.0.0'

shared_scripts {
	'config.lua'
}

client_scripts {
	'client/main.lua',
	'client/commands.lua',
	'client/warmenu.lua'
}

server_scripts {
	'server/database.lua',
  'server/main.lua',
	'server/functions.lua',
	'server/banmanager.lua',
	'server/permissions.lua'
}
