fx_version "adamant"
games {"rdr3"}
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'Nosmakos'
description 'TPZ-CORE Weapons'

version '1.0.1'

ui_page 'html/index.html'

shared_scripts { 'config.lua', 'config_store_products.lua', 'locales.lua' }
client_scripts { '@tpz_core/client/tp-client_dataview.lua', 'client/*.lua' }
server_scripts { 'server/*.lua' }

files { 'html/**/*' }

dependencies {
    'tpz_core',
    'tpz_characters',
    'tpz_inventory',
}

lua54 'yes'

