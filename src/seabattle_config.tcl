# Flags needed to use the commands
set qstat_flag "."

# Sets BotPass
set botpass "botsky"

set skystats_max 10
set skystats_i 0

# Database connection info
set sqluser "seabattle"
set sqlpass "seabattle"
set sqlhost "localhost"
set sqldb "seabattle"

set msg_dontunderstand {
    "?"
    "Aš tavęs nesuprantu... :("
    "Ką tai galėtų reikšti?"
    "What?"
    "Baik mane floodinti!"
    "Nemanau, kad supranti pats ką rašai..."
}

array set commands_alias {
    "rodyti zemelapi" "!map"
    "rodyti zemelapius" "!map3"
    "rodyti priesininko zemelapi" "!map2"
    "zemelapis" "!map"
    "mano zemelapis" "!map"
    "musu zemelapiai" "!map3"
    "zemelapiai" "!map3"
    "priesininko zemelapis" "!map2"
    "pabaigti" "!end"
    "uzbaigti" "!end"
    "pabaiga" "!end"
    "baigti" "!end"
    "baik" "!end"
    "uzbaik" "!end"
}
