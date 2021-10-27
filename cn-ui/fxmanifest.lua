fx_version 'bodacious'
games { 'rdr3', 'gta5' }

client_script 'client/*.lua'

ui_page {
    'html/index.html',
}
files {
    'html/index.html',
}

exports {
    "DrawNotify",
    "Clear"
}