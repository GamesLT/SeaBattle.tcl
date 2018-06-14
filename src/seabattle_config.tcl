# Flags needed to use the commands
set qstat_flag [::read_env "SEABATTLE_QSTAT_FLAG" "."]

# Sets BotPass
set botpass [::read_env "SEABATTLE_BOT_PASS" "botsky"]

# Skystats
set skystats_max [::read_env "SEABATTLE_SKYSTATS_MAX" 10]
set skystats_i [::read_env "SEABATTLE_SKYSTATS_I" 0]

# Database connection info
set sqluser [::read_env "SEABATTLE_DB_USER" "seabattle"]
set sqlpass [::read_env "SEABATTLE_DB_PASS" "seabattle"]
set sqlhost [::read_env "SEABATTLE_DB_HOST" "127.0.0.1"]
set sqldb [::read_env "SEABATTLE_DB_NAME" "seabattle"]

# Language
set language [::read_env "SEABATTLE_LANGUAGE" "en"]

# Ships playfield data
set grid_horizontal_word [::read_env "SEABATTLE_GRID_HORIZONTAL_WORD" "games"]
set grid_vertical_word [::read_env "SEABATTLE_GRID_VERTICAL_WORD" "12345"]
set ship_count [::read_env "SEABATTLE_SHIPS_COUNT" 5]

# Registrations
set nickserv_auth_needed [::read_env "SEABATTLE_NICKSERV_AUTH_NEEDED" false]
set nickserv_host [::read_env "SEABATTLE_NICKSERV_HOST" "aitvarasnet.org"]
set nickserv_timeout [::read_env "SEABATTLE_NICKSERV_TIMEOUT" 5]

# debug
set log_queries [::read_env "SEABATTLE_LOG_QUERIES" no]
