[![License](https://img.shields.io/github/license/GamesLT/SeaBattle.tcl.svg?maxAge=2592000)](License.txt) ![GitHub release](https://img.shields.io/github/release/GamesLT/SeaBattle.tcl.svg?maxAge=2592) 
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

First thing what you need is to make sure that your [Eggdrop](http://www.eggheads.org)/[Windrop](http://windrop.sourceforge.net) bot is running. How to do, you can find information at your choised bot website. Next things todo:
 * Download [the latest release archive](https://github.com/GamesLT/SeaBattle.tcl/releases/latest)
 * Unpack archive 
 * Copy `src/` files into folder for your bot scripts
 * Add `source seabattle_main.tcl` line in your `eggdrop.conf` file (NOTE: you need to prefix `seabattle_main.tcl` with correct path)
 * Install [mysqltcl](http://www.xdobry.de/mysqltcl/) library (if you use bot on windows or on shared server download compiled *3.02* version and put in `tcllibs` (create if this folder doesn't exists in your system!) subfolder in same folder where `seabattle.tcl` is placed.
 * Create new MySQL database and import there `seabattle.sql` 
 * Edit settings in `seabattle_config.tcl`
 * Run your bot. 
 
### How to develop?

If you want to add some functionality or fix bugs, you can fork, change and create pull request. If you not sure how this works, try   [interactive GitHub tutorial](https://try.github.io/).

It's possible to run Seabattle in local machine with [Vagrant](http://vagrantup.com). All required files exists in this repo. In that case you must just clone the repo and run `vagrant up`. Than it's possible to connect to IRC server at `seabattle.dev` and join #seabattle IRC channel. There the bot should sit.
