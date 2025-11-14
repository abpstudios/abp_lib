fx_version 'cerulean'
game 'gta5'

name "abp_lib"
description "A library of shared functions to utilise in other resources."
author "AlexBanPer"
version "1.1.0"

lua54 'yes'

shared_script 'resource/init.lua'

dependencies {
    '/server:7290',
    '/onesync',
}

client_scripts {
    'resource/**/client.lua',
    'resource/**/client/*.lua'
}

shared_scripts {
	-- '@ox_lib/init.lua',
    'config.lua',
    'resource/**/shared.lua',
    'resource/**/shared/*.lua'
}

server_scripts {
    'configServer.lua',
    'resource/**/server.lua',
    'resource/**/server/*.lua',
}

files {
    'init.lua',
    'bridge/*.lua',
    'bridge/inventory/*.lua',
    'imports/**/client.lua',
    'imports/**/shared.lua',
    'config/**'
}

escrow_ignore {
    'init.lua',
    'config.lua',
    'configServer.lua',
    'bridge/inventory/*.lua',
    'bridge/*.lua',
    'config/**',
    'imports/**/**',
    'resource/**/**',
    'resource/init.lua',
}
dependency '/assetpacks'
