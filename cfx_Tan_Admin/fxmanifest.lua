fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'TAN_Admin - version améliorée'
description 'Menu administration ESX avec ox_lib'
version '2.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
    'config.lua'
}

server_script 'server/server.lua'
client_scripts {
    'client/core/init.lua',
    'client/features/coordinates.lua',
    'client/features/noclip.lua',
    'client/features/staff_duty.lua',
    'client/events/player.lua',
    'client/menus/self.lua',
    'client/menus/players.lua',
    'client/menus/vehicles.lua',
    'client/menus/developer.lua',
    'client/menus/reports.lua',
    'client/menus/main.lua',
    'client/features/reports.lua',
    'client/core/commands.lua'
}

dependencies {
    'ox_lib',
    'es_extended',
    'illenium-appearance'
}
