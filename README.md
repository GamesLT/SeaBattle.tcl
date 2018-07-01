[![License](https://img.shields.io/github/license/GamesLT/SeaBattle.tcl.svg?maxAge=2592000)](License.txt)
[![GitHub release](https://img.shields.io/github/release/GamesLT/SeaBattle.tcl.svg?maxAge=2592)](https://github.com/GamesLT/SeaBattle.tcl/releases)
[![Docker Build Status](https://img.shields.io/docker/build/gameslt/seabattle.tcl.svg)](https://hub.docker.com/r/gameslt/seabattle.tcl/builds/)
[![Docker Pulls](https://img.shields.io/docker/pulls/gameslt/seabattle.tcl.svg)](https://hub.docker.com/r/gameslt/seabattle.tcl/)
[![Readme In English](https://img.shields.io/badge/readme-en-yellowgreen.svg)](https://github.com/GamesLT/SeaBattle.tcl/blob/master/README.md)
[![Readme In Lithuanian](https://img.shields.io/badge/readme-lt-lightgrey.svg)](https://github.com/GamesLT/SeaBattle.tcl/blob/master/README.LT.md)
# Seabattle

![Screenshot](https://raw.githubusercontent.com/GamesLT/SeaBattle.tcl/master/.screenshot.jpg)

### What is this?

This is scripts adds a possibility to play classical [Sea batlle/Battleship](https://en.wikipedia.org/wiki/Battleship_(game)) game in IRC channel to [Eggdrop](http://www.eggheads.org)/[Windrop](http://windrop.sourceforge.net) bots.

Features included in this script:
 * Text-only
 * Multiplayer for two users
 * Use [MySQL](http://mysql.org) for game data
 * Build-in user registrations
 * Nickserver support
 * Multilanguage support
 
### How to install?

There are two options:

#### 1. Use Docker container (recommended)

[Docker](https://docker.com) is one of best ways to quickly to run any process isolated and you can it use too also for running SeaBattle!

You need just run this command on the server:
```
docker run -d \
           -e SEABATTLE_DB_USER=seabattle \
           -e SEABATTLE_DB_PASS=seabattle \
           -e SEABATTLE_DB_HOST=hostname \
           -e SEABATTLE_DB_NAME=seabattle \
           gameslt/seabattle.tcl
```

`SEABATTLE_DB_USER`, `SEABATTLE_DB_PASS`, `SEABATTLE_DB_HOST`, `SEABATTLE_DB_NAME` values must be choiced by yourself..

Also it's possible to use other configuration option:

| Parameter | Default value | Where is used? |
| ---------- | ------------------------ | --------------- |
| SEABATTLE_BOT_PASS | botsky | Bot password |
| **_SEABATTLE_DB_USER_** | | MySQL database username |
| **_SEABATTLE_DB_PASS_** | | MySQL database password |
| **_SEABATTLE_DB_HOST_** | | MySQL database server address |
| **_SEABATTLE_DB_NAME_** | | MySQL database name |
| SEABATTLE_LANGUAGE | en | Game language. Possible values: `en`, `lt` |
| SEABATTLE_GRID_HORIZONTAL_WORD | games | Horizontal word for game (the word can't have same letters) |
| SEABATTLE_GRID_VERTICAL_WORD | 12345 | Vertical word for game (the word can't have same letters) |
| SEABATTLE_SHIPS_COUNT | 5 | How many ships will be on battlefield? |
| SEABATTLE_NICKSERV_AUTH_NEEDED | false | Do we need NickServ auth for the bot? |
| SEABATTLE_NICKSERV_HOST | irc.data.lt | NickServ hostname |
| SEABATTLE_NICKSERV_TIMEOUT | 5 | How many seconds bot should wait for NickServ answer, befeore deciding that auth didn't happened |
| SEABATTLE_LOG_QUERIES | no | Print SQL queries in console? |
| EGGDROP_BOTNET_NICK | SeaBattle | One of EggDrop/WinDrop settings: *botnet-nick*. More about it you can find in [oficiall EggDrop documentation](http://docs.eggheads.org/coreDocs/core.html). |
| EGGDROP_PROTECT_TELNET | 0 | One of EggDrop/WinDrop settings: *protect-telnet*. More about it you can find in [oficiall EggDrop documentation](http://docs.eggheads.org/coreDocs/core.html). |
| EGGDROP_DCC_SANITY_CHECK | 0 | One of EggDrop/WinDrop settings: *dcc-sanitycheck*. More about it you can find in [oficiall EggDrop documentation](http://docs.eggheads.org/coreDocs/core.html). |
| EGGDROP_IDENT_TIMEOUT | 5 | One of EggDrop/WinDrop settings: *ident-timeout*. More about it you can find in [oficiall EggDrop documentation](http://docs.eggheads.org/coreDocs/core.html). |
| EGGDROP_REQUIRE_PARTY | 0 | One of EggDrop/WinDrop settings: *require-p*. More about it you can find in [oficiall EggDrop documentation](http://docs.eggheads.org/coreDocs/core.html). |
| EGGDROP_OPEN_TELNETS | 0 | One of EggDrop/WinDrop settings: *open-telnets*. More about it you can find in [oficiall EggDrop documentation](http://docs.eggheads.org/coreDocs/core.html). |
| EGGDROP_STEALTH_TELNETS | 0 | One of EggDrop/WinDrop settings: *stealth-telnets*. More about it you can find in [oficiall EggDrop documentation](http://docs.eggheads.org/coreDocs/core.html). |
| EGGDROP_USE_TELNET_BANNER | 0 | One of EggDrop/WinDrop settings: *use-telnet-banner*. More about it you can find in [oficiall EggDrop documentation](http://docs.eggheads.org/coreDocs/core.html). |
| EGGDROP_CONNECTION_TIMEOUT | 90 | One of EggDrop/WinDrop settings: *connect-timeout*. More about it you can find in [oficiall EggDrop documentation](http://docs.eggheads.org/coreDocs/core.html). |
| EGGDROP_DCC_FLOOD_THR | 3 | One of EggDrop/WinDrop settings: *dcc-flood-thr*. More about it you can find in [oficiall EggDrop documentation](http://docs.eggheads.org/coreDocs/core.html). |
| EGGDROP_TELNET_FLOOD | 5:60 | One of EggDrop/WinDrop settings: *telnet-flood*. More about it you can find in [oficiall EggDrop documentation](http://docs.eggheads.org/coreDocs/core.html). |
| EGGDROP_PARANOID_TELNET_FLOOD | 1 | One of EggDrop/WinDrop settings: *paranoid-telnet-flood*. More about it you can find in [oficiall EggDrop documentation](http://docs.eggheads.org/coreDocs/core.html). |
| EGGDROP_RESOLVE_TIMEOUT | 15 | One of EggDrop/WinDrop settings: *resolve-timeout*. More about it you can find in [oficiall EggDrop documentation](http://docs.eggheads.org/coreDocs/core.html). |
| EGGDROP_MAX_DCC | 50 | One of EggDrop/WinDrop settings: *max-dcc*. More about it you can find in [oficiall EggDrop documentation](http://docs.eggheads.org/coreDocs/core.html). |
| EGGDROP_ALLOW_DK_CMDS | 1 | One of EggDrop/WinDrop settings: *allow-dk-cmds*. More about it you can find in [oficiall EggDrop documentation](http://docs.eggheads.org/coreDocs/core.html). |
| EGGDROP_MODULES | dns channels server ctcp irc notes console transfer share | What modules for EggDrop/WinDrop to load? |
| EGGDROP_CHECK_MODULES | blowfish | Modules for data checking/verifying |
| EGGDROP_NICK | SeaBattle | One of EggDrop/WinDrop settings: *nick*. More about it you can find in [oficiall EggDrop documentation](http://docs.eggheads.org/coreDocs/server.html). |
| EGGDROP_ALTNICK | SeaBattleBot | One of EggDrop/WinDrop settings: *altnick*. More about it you can find in [oficiall EggDrop documentation](http://docs.eggheads.org/coreDocs/server.html). |
| EGGDROP_ADMIN | owner | One of EggDrop/WinDrop settings: *admin*. More about it you can find in [oficiall EggDrop documentation](http://docs.eggheads.org/coreDocs/core.html). |
| EGGDROP_REAL | Bot for Games.lt | One of EggDrop/WinDrop settings: *realname*. More about it you can find in [oficiall EggDrop documentation](http://docs.eggheads.org/coreDocs/server.html). |
| EGGDROP_SERVERS | irc.data.lt | Servers list where to connect automatically |
| EGGDROP_CHANNELS | #seabattle | Channels where to join |
| EGGDROP_NET_TYPE | 5 | One of EggDrop/WinDrop settings: *net-type*. More about it you can find in [oficiall EggDrop documentation](http://docs.eggheads.org/coreDocs/server.html). |
| EGGDROP_LISTEN_USERS_PORT | 3333 | Port where bot should listen for users |
| EGGDROP_LISTEN_BOTS_PORT | 3333 | Port where bot should listen for other bots |
| EGGDROP_OWNERS | | One of EggDrop/WinDrop settings: *owner*. More about it you can find in [oficiall EggDrop documentation](http://docs.eggheads.org/coreDocs/core.html). |
| EGGDROP_SYSTEM_SCRIPTS | alltools action.fix compat userinfo | What system script to load |
| EGGDROP_SYSTEM_HELPS | userinfo | What system language files to load? |

#### 2. Install manually

First thing what you need is to make sure that your [Eggdrop](http://www.eggheads.org)/[Windrop](http://windrop.sourceforge.net) bot is running. How to do, you can find information at your choised bot website. Next things todo:
 * Download [the latest release archive](https://github.com/GamesLT/SeaBattle.tcl/releases/latest)
 * Unpack archive 
 * Copy `src/` files into folder for your bot scripts
 * Add `source seabattle_main.tcl` line in your `eggdrop.conf` file (NOTE: you need to prefix `seabattle_main.tcl` with correct path)
 * Install [mysqltcl](http://www.xdobry.de/mysqltcl/) library (if you use bot on windows or on shared server download compiled *3.02* version and put in `tcllibs` (create if this folder doesn't exists in your system!) subfolder in same folder where `seabattle.tcl` is placed.
 * Create new MySQL database and import there `install.sql` 
 * Edit settings in `seabattle_config.tcl`
 * Run your bot. 
 
### How to develop?

If you want to add some functionality or fix bugs, you can fork, change and create pull request. If you not sure how this works, try   [interactive GitHub tutorial](https://try.github.io/).

It's possible to run Seabattle in local machine with [Vagrant](http://vagrantup.com). All required files exists in this repo. In that case you must just clone the repo and run `vagrant up`. Than it's possible to connect to IRC server at `seabattle.test` and join #seabattle IRC channel. There the bot should sit.
