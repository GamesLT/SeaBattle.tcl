# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#  Copyright (C) 2004-2017 Games.lt
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), 
#  to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or 
#  sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# 
#  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# 
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
#  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS 
#  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
#  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

################################################################
# This is where    the evil TCL code starts, read at your peril!  #
################################################################

set spath [file dirname [info script]]

source [file join $spath "seabattle_config.tcl"]
foreach varname [list "qstat_flag" "botpass" "nickserv_host" "skystats_max" "skystats_i" "sqluser" "sqlpass" "sqlhost" "sqldb" "language"] {
    if {![info exists $varname]} {
        puts "$varname in seabattle_config.tcl is not defined"
        exit 2
    }
}

set mpath [file join $spath "tcllibs"]
set lib_path [file join $spath "lib"]

source [file join $lib_path "db.tcl"]
source [file join $lib_path "format.tcl"]
source [file join $lib_path "language.tcl"]
source [file join $lib_path "admin_commands.tcl"]
source [file join $lib_path "user_commands.tcl"]
source [file join $lib_path "help_command.tcl"]
source [file join $lib_path "private_chat_handling.tcl"]
source [file join $lib_path "say.tcl"]

::Language::load $spath $language
::DB::try_load $mpath
::DB::connect $sqlhost $sqluser $sqlpass $sqldb

set qversion "0.7"
set tdata("unknown") ""

bind pub $qstat_flag "!admin" ::AdminCommands::handle
bind pub $qstat_flag "!help" ::HelpCommand::handle
bind msg $qstat_flag "user" ::UserCommands::handle
bind msgm $qstat_flag * ::PrivateChatHandling::handle
bind flud $qstat_flag "msg" ::PrivateChatHandling::checkForFlood

#bind JOIN -|- * pub:join

bind NOTC -|- "This nickname is registered and protected.*" nickserv_identify

proc isadmin { nick }  {
    return [::DB::count "Users" "Nick='$nick' and Admin='true'"]
}

proc nickserv_identify { nick host hand arg txt } { 
    global bot_pass nickserv_host
    putquick "PRIVMSG nickserv@$nickserv_host :identify $bot_pass"
}

proc is_good_command { type text } {
    set cmd [lindex $text 0]
    foreach {item} [binds $type] {
        set type [lindex $item 0]
        set flags [lindex $item 1]
        set name [lindex $item 2]
        set hits [lindex $item 3]
        set proc [lindex $item 4]
        if {[string equal -nocase $cmd $name]==1} {
           return 1;
        }
    }
    return 0;
}

proc is_identified { nik host } {
    global nick botnick
    if {[string equal -nocase $nik $nick]==1} {
        return 1;
    }
    set lhost [::DB::getcell "Users" "host" "nick = '$nik'"]
    if { $lhost == $host } {
        return 1;
    } else {
        return 0;
    }
}

proc WaitEvent { nick event } {
    putlog "-> $nick $event"
    set sql "UPDATE `Users` SET `Command` = '$event' WHERE `Nick` = '$nick' LIMIT 1;"
    set rez [::DB::exec $sql]
}

proc get_unixtime {} {
    set ct(hrs) [clock format [clock seconds] -format %H]
    set ct(min) [clock format [clock seconds] -format %M]
    set ct(sec) [clock format [clock seconds] -format %S]
    return [expr {$ct(hrs)*3600+$ct(min)*60+$ct(sec)}]
}

proc emptyline { } {
    return "\"
}

proc getini { setting } {
    return [::DB::getcell "settings" "value" "setting = '$setting'"]
}

proc random_item {list} {
    set random [rand [llength $list]]
    return [lindex $list $random]
}

proc ndata { nick host handle text dest} {
    global tdata db_handle nickserv_auth_needed
    set xnick $nick
    set xhost $host
    set nick [lindex $text 0]
    set host $tdata(host)
    if {[string equal -nocase $xnick NickServ]==1} {
        if {[info exists tdata(timer_id)]} {
            killutimer $tdata(timer_id)
            unset tdata(timer_id)
        }
        set tdata(nick) ""
        set chan $nick
        unbind NOTC -|- "$nick*" ndata
        set pass $tdata(pass)
        set email $tdata(email)
        set id [::DB::getcell "Users" "id" "nick = '$nick'"]
        putlog "$id>>"
        if {[string trim $id]!=""} {
            ::Say::default "error" $nick $chan [::Language::str "such_user_exists"]
            return 0;
        }
        set sql "INSERT INTO `Users` (`Nick`, `Admin`, `Host`, `Password`, `E-Mail`)"
        append sql "VALUES ("
        append sql "'$nick', 'false', '$host', '$pass', '$email'"
        append sql ");"
        set rez [::DB::exec $sql]
        ::Language::say "error" $nick $chan "registration_msg" [list $pass $email]
    }
}

###################################################################################
# Here is starting evil game code #################################################
###################################################################################

bind pub -||- "!play" pub:play
bind pub -||- "!stats" pub:stats

bind msg $qstat_flag "play" pub:play2
bind msg $qstat_flag "stats" pub:stats2

utimer 10 autoend

proc autoend {} {
    set dothiscommand [::DB::getcell "TodoList" "Arguments" "Command = 'CheckIfAutoEnd' LIMIT 1"]
    if {[string trim $dothiscommand]==""} {
        return;
    }
    set nick [lindex $dothiscommand 0]
    set player2 [lindex $dothiscommand 1]
    set player $player2
    if {[onchan $nick]==0} {
        ::Say::default "error" $player2 $player2 [::Language::str "other_player_quited" [list $nick]]
        ::Language::say "error" $nick $nick "registration_msg" [list $player2]
        ::DB::exec "DELETE FROM TodoList WHERE Arguments = '$dothiscommand' AND Command = 'CheckIfAutoEnd';"
        ::DB::exec "UPDATE `Users` SET StatNA = StatNA + 1 WHERE `Nick` IN ('$nick', '$player');"
        WaitEvent $nick ""
        WaitEvent $player2 ""
        return;
    }
    if {[onchan $player2]==0} {
        ::Say::default "error" $nick $nick [::Language::str "other_player_left_channel" [list $player2]]
        ::Language::say "error" $player2 $player2 "you_left_channel" [list $nick]
        ::DB::exec "DELETE FROM TodoList WHERE Arguments = '$dothiscommand' AND Command = 'CheckIfAutoEnd';"
        ::DB::exec "UPDATE `Users` SET StatNA = StatNA + 1 WHERE `Nick` IN ('$nick', '$player');"
        WaitEvent $nick ""
        WaitEvent $player2 ""
        return;
    }
    set lastaction1 [::DB::getcell "Users" "LastAction" "Nick = '$nick'"] 
    set lastaction2 [::DB::getcell "Users" "LastAction" "Nick = '$player2'"] 
    set laikas [get_unixtime]
    ::DB::exec "DELETE FROM TodoList WHERE Arguments = '$dothiscommand' AND Command = 'CheckIfAutoEnd'"
    if {$laikas>[expr $lastaction1+960]} {
        ::Say::default "error" $nick $nick [::Language::str "game_canceled_because_you_idled"]
        ::Say::default "error" $player2 $player2 [::Language::str "game_canceled_because_other_player_not_moved"]
        ::DB::exec "UPDATE `Users` SET StatNA = StatNA + 1 WHERE `Nick` IN ('$nick', '$player')"
        WaitEvent $nick ""
        WaitEvent $player2 ""
        return;
    }
    if {$laikas>[expr $lastaction2+960]} {
        ::Say::default "error" $player2 $player2 [::Language::str "game_canceled_because_you_idled"]
        ::Say::default "error" $nick $nick [::Language::str "game_canceled_because_other_player_not_moved"]
        ::DB::exec "UPDATE `Users` SET StatNA = StatNA + 1 WHERE `Nick` IN ('$nick', '$player')"
        WaitEvent $nick ""
        WaitEvent $player2 ""
        return;
    }
}

proc pub:stats2 { nick host handle text } {
    pub:stats $nick $host $handle $nick $text
}

proc pub:play2 { nick host handle text } {
    pub:play $nick $host $handle $nick $text
}

proc pub:stats { nick host handle chan text } {
    if {[string trim $text]==""} {
        if {[::DB::count "Users" "Nick = '$nick'"]<1} {
            ::Language::say "error" $nick $chan "cant_show_stats"
            return
        } 
        ::Say::default "error" $nick $chan [::Language::str "your_stats"]
        set user $nick
    } else {
        set user [lindex $text 0]
        if {[::DB::count "Users" "Nick = '$user'"]<1} {
            ::Language::say "error" $nick $chan "cant_show_stats_for" [list $user]
            return
        }
        ::Say::default "error" $nick $chan [::Language::str "user_stats" [list $user]]
    }
    set won [::DB::getcell "Users" "StatWon" "Nick = '$user'"] 
    set lost [::DB::getcell "Users" "StatLost" "Nick = '$user'"] 
    set na [::DB::getcell "Users" "StatNA" "Nick = '$user'"]
    ::Language::say "error" $nick $chan "stats_data" [list $won $lost $na [expr $na+$won+$lost]]
}

proc pub:play { nick host handle chan text } {
    global my_games botnick

    set game [lindex $text 0]
    set player2 [lindex $text 1]

    if {[is_identified $nick $host]==0} {
        ::Say::unknown $nick
        return 0;
    }
      
    set nogame 0
    foreach game2 $my_games {
        if {[string equal -nocase $game $game2]==1} {
            set nogame 1
        }
    }

    if {$nogame==0} {
        set games " "
        foreach game2 $my_games {
            append games $game2
            append games " "
        }
        ::Say::default "error" $nick $chan [::Language::str "please_select_game" [list $games]]
        return 0
    }

    if {$player2==""} {
        ::Say::default "error" $nick $chan [::Language::str "please_select_oponent" [list $game $game $botnick]]
        return 0
    }

    if {[string equal -nocase $player2 $botnick]==1} {
        ::Say::default "error" $nick $chan [::Language::str "bot_rejects_game"]
        return 0
    }

    if {[string equal -nocase $player2 $nick]==1} {
        ::Say::default "error" $nick $chan [::Language::str "bot_cant_invite_you"]
        return 0;
    }

    if {[onchan $nick]==0} {
        ::Language::say "error" $nick $chan "you_not_in_my_channels"
        return
    }

    if {[onchan $player2]==0} {
        ::Language::say "error" $nick $chan "another_player_not_in_my_channels" [list $player2]
        return
    }

    if {[string equal -nocase [::DB::getcell "Users" "Command" "nick = '$player2'"]    ""]==0} {
        ::Say::default "error" $nick $chan [::Language::str "another_player_now_playing" [list $player2]]
        return
    }

    if {[string equal -nocase [::DB::getcell "Users" "Command" "nick = '$nick'"] ""]==0} {
        ::Language::say "error" $nick $chan "you_are_playing_other_game"
        return
    }

    set count [::DB::count "Users" "nick = '$player2'"]
    if {$count<1} {
        ::Language::say "game" $player2 $chan "got_invitation_but_not_registered" [list $nick $game $botnick]
        ::Language::say "game" $nick $chan "invited_but_another_player_must_register_first" [list $player2]
        return 0;
    }

    ::Language::say "game" $nick $chan "selected_game_info" [list $game $player2]
    WaitEvent $player2 "wagree $player2 $game"

    ::Language::say "game" $player2 $chan "invited_to_game" [list $nick $game]
    WaitEvent $player2 "agree $nick $game"
}

proc PlayGame { command game nick player text } {
    switch [string tolower $game] {
        "seabattle" {
            Game_SeaBattle $command $game $nick $player $text
        }
    }
}

proc Game_SeaBattle { command game nick player text } {
    global grid_width grid_height ship_count commands_alias
    set arg [lindex $command 1]
    set command [lindex $command 0]
    set laikas [get_unixtime]
    ::DB::exec "UPDATE `Users` SET LastAction = NOW() WHERE `Nick` = '$nick' LIMIT 1;"
    ::DB::exec "DELETE FROM TodoList WHERE Command = 'CheckIfAutoEnd' AND (Arguments LIKE '% $nick' OR Arguments LIKE '$nick %');" 
    ::DB::exec "INSERT INTO `TodoList` (`Command`, `Arguments`) VALUES ('CheckIfAutoEnd', '$nick $player');" 
    set textp [string tolower $text]
    if {[dict exists $::Language::commands_alias $textp]} {
        set textp [dict get $::Language::commands_alias $textp]
    }
    switch [string tolower $textp] {
        "!map" {
            if {[string equal -nocase "shoot" $command]==0} {
                return;
            }
            set msg [::Language::str "this_is_how_your_map_looks"]
            ::Say::default "game" $nick $nick $msg
            DrawGrid2 $nick
            ::Say::default "game" $nick $nick [::Language::str "enter_coordinates"]
            return
        }
        "!map2" {
            if {[string equal -nocase "shoot" $command]==0} {
                return;
            }
            set msg [::Language::str "this_is_how_oponent_map_looks"]
            ::Say::default "game" $nick $nick $msg
            DrawGrid3 $nick $player
            ::Say::default "game" $nick $nick [::Language::str "enter_coordinates"]
            return
        }
        "!map3" {
            if {[string equal -nocase "shoot" $command]==0} {
                return;
            }
            set msg [::Language::str "this_is_how_your_map_looks"]
            ::Say::default "game" $nick $nick $msg
            DrawGrid2 $nick
            set msg [::Language::str "this_is_how_oponent_map_looks"]
            ::Say::default "game" $nick $nick $msg
            DrawGrid3 $nick $player
            ::Say::default "game" $nick $nick [::Language::str "enter_coordinates"]
            return
        }
        "!end" {
            WaitEvent $nick ""
            WaitEvent $player ""
            ::DB::exec "DELETE FROM Seabattle WHERE (Nick = '$nick') OR (Nick = '$player');" 
            ::DB::exec "DELETE FROM TodoList WHERE Command = 'CheckIfAutoEnd' AND (Arguments LIKE '% $nick' OR Arguments LIKE '$nick %');" 
            ::DB::exec "UPDATE `Users` SET StatNA = StatNA + 1 WHERE `Nick` IN ('$nick', '$player');"
            ::Language::say "game" $nick $nick "end_iniciated_by_you" [list $player]
            ::Language::say "game" $player $player "end_iniciated_by_other_player" [list $nick]
            return
        }
    }
    switch [string tolower $command] {
        "place" {
            set text [string tolower $text]
            set coll [lindex $text 0]
            if {[string length $coll]==2} {
                set val $coll
                set coll [string range $val 0 0]
                set row [string range $val 1 1]
                set lin 0
            } else {
                set row [lindex $text 1]
                set lin 1
            }
            if {[lindex $text [expr $lin+1]]!=""} {
                if {$arg!="l"} {
                    set count [::DB::count "Seabattle" "nick = '$nick' and value = '1'"]
                    set lst {}
                    set litem {}
                    foreach item [lrange $text [expr $lin+1] end] {
                        if {[string length $item]>1} {
                            set lst [linsert $lst 0 $item]
                            set count [expr $count+1]
                        } else {
                            if {[string length "$item$litem"]>1} {
                                set lst [linsert $lst 0 $litem$item]
                                set litem {}
                                set count [expr $count+1]
                            } else {
                                set litem $item
                            }
                        }
                        if {$count>[expr $ship_count-1]} break;
                    }
                } else {
                    set lst [lrange $text [expr $lin+1] end]
                }        
                Game_SeaBattle "$command l" $game $nick $player $lst
            }
            if {[lsearch $grid_width $coll]==-1} {
                ::Say::default "game" $nick $nick [::Language::str "bad_coordinates" [list $coll $row]]
                if {$arg!="l"} {
                    ::Say::default "game" $nick $nick [::Language::str "enter_coordinates"]
                }
                return 0;
            }
            if {[lsearch $grid_height $row]==-1} {
                ::Say::default "game" $nick $nick [::Language::str "bad_coordinates" [list $coll $row]]
                if {$arg!="l"} {
                    ::Say::default "game" $nick $nick [::Language::str "enter_coordinates"]
                }
                return 0;
            }
            set count [::DB::count "Seabattle" "nick = '$nick' and value = '1'"]
            set val [::DB::getcell "Seabattle" "value" "nick ='$nick' and row = '$row' and collumn = '$coll'"]
            if {$val!="0"} {
                ::Say::default "game" $nick $nick [::Language::str "there_is_alread_a_ship" [list $coll $row]]
                if {$arg!="l"} {
                    ::Say::default "game" $nick $nick [::Language::str "enter_coordinates"]
                }
                return 0;
            }     
            set id [::DB::getcell "Seabattle" "id" "nick ='$nick' and row = '$row' and collumn = '$coll'"]
            ::DB::exec "UPDATE Seabattle SET `Value` = '1' WHERE `ID` = '$id' LIMIT 1;"
            ::Say::default "game" $nick $nick [::Language::str "you_just_places_a_ship" [list [expr $count+1] $coll $row]]
            if {$count<$ship_count} {
                if {$arg!="l"} {
                    ::Say::default "game" $nick $nick [::Language::str "enter_coordinates_for_ship" [list [expr $count+2]]]
                }
            } else {
                set txt [::DB::getcell "Users" "command" "nick = '$player'"]
                set cmd [lindex $txt 0]
                set data [list "+(none)+"]
                foreach x $grid_width {
                    foreach y $grid_height {
                        set val [::DB::getcell "Seabattle" "value" "nick ='$nick' and row = '$y' and collumn = '$x'"]
                        if {$val!="0"} {
                            lappend data $x$y
                        }
                    }
                }
                set msg [::Language::str "this_is_how_your_map_looks"]
                ::Say::default "game" $nick $nick $msg
                DrawGrid $data $nick
                switch [string tolower $cmd] {
                    "waituntilplace" {
                        WaitEvent $player "shoot $nick $game"
                        ::Language::say "game" $player $player "seabattle_starts_enter_coordinates"
                        WaitEvent $nick "waitshoot $player $game"
                        ::Language::say "game" $nick $nick "seabattle_soon_you_will_need_to_shhot_something" [list $player]
                    }
                    default {
                        WaitEvent $nick "waituntilplace $player $game"
                        ::Say::default "game" $nick $nick [::Language::str "wait_for_player_to_places_ships" [list $player]]
                    }
                }
            }
        }
        "shoot" {
            set text [string tolower $text]
            set coll [lindex $text 0]
            if {[string length $coll]==2} {
                set val $coll
                set coll [string range $val 0 0]
                set row [string range $val 1 1]
                set lin 0
            } else {
                set row [lindex $text 1]
                set lin 1
            }
            if {[lsearch $grid_width $coll]==-1} {
                ::Say::default "game" $nick $nick [::Language::str "bad_coordinates" [list $coll $row]]
                if {$arg!="l"} {
                    ::Say::default "game" $nick $nick [::Language::str "enter_coordinates"]
                }
                return 0;
            }
            if {[lsearch $grid_height $row]==-1} {
                ::Say::default "game" $nick $nick [::Language::str "bad_coordinates" [list $coll $row]]
                if {$arg!="l"} {
                    ::Say::default "game" $nick $nick [::Language::str "enter_coordinates"]
                }
                return 0;
            }
            set val [::DB::getcell "Seabattle" "value" "nick ='$player' and row = '$row' and collumn = '$coll'"]        
            switch $val {
                "1" {
                    ::Say::default "game" $player $player [::Language::str "shoot_to" [list $nick $coll $row]]
                    ::Say::default "game" $player $player [::Language::str "ship_sink"]
                    ::DB::exec "UPDATE `Seabattle` SET `Value` = '2' WHERE nick ='$player' and row = '$row' and collumn = '$coll';"
                    ::Say::default "game" $nick $nick [::Language::str "shoot_good_results"]
                    set count [::DB::count "Seabattle" "nick = '$player' and value = '1'"]
                    if {$count<1} {
                        WaitEvent $nick ""
                        WaitEvent $player ""
                        set data [list "+(none)+"]
                        foreach x $grid_width {
                            foreach y $grid_height {
                                set val [::DB::getcell "Seabattle" "value" "nick ='$nick' and row = '$y' and collumn = '$x'"]
                                if {$val=="1"} {
                                    lappend data $x$y
                                }
                                if {$val=="2"} {
                                    lappend data $x$y
                                }
                            }
                        }
                        ::Say::default "game" $player $player [::Language::str "that_was_last_ship"]
                        ::Say::default "game" $player $player [::Language::str "i_will_show_your_opnent_map" [list $nick]]
                        DrawGrid $data $player
                        ::Say::default "game" $player $player [::Language::str "has_won" [list $nick]]
                        ::DB::exec "UPDATE `Users` SET StatWon = StatWon + 1 WHERE `Nick` = '$nick' LIMIT 1;"
                        ::DB::exec "UPDATE `Users` SET StatLost = StatLost + 1 WHERE `Nick` = '$player' LIMIT 1;"
                        ::Say::default "game" $nick $nick [::Language::str "congratulations"]
                        return 0;
                    } else {
                        set count [::DB::count "Seabattle" "nick = '$player' and value = '1'"]
                        ::Say::default "game" $player $player [::Language::str "ships_count" [list $count]]
                        ::Say::default "game" $nick $nick [::Language::str "ships_count" [list $count]]
                    }
                    ::Say::default "game" $nick $nick [::Language::str "enter_coordinates"]
                }
                "0" {
                    ::Say::default "game" $player $player [::Language::str "shoot_to" [list $nick $coll $row]]
                    ::Say::default "game" $player $player [::Language::str "there_was_no_ship"]
                    ::Say::default "game" $nick $nick [::Language::str "shoot_bad_results"]
                    ::DB::exec "UPDATE `Seabattle` SET `Value` = '3' WHERE nick ='$player' and row = '$row' and collumn = '$coll';"
                    WaitEvent $nick "waitshoot $player $game"
                    WaitEvent $player "shoot $nick $game"
                    ::Say::default "game" $player $player [::Language::str "enter_coordinates"]
                }
                "3" {
                    ::Language::say "game" $player $player "bad_hands_doesnt_listens_to_head" [list $nick]
                    ::Say::default "game" $nick $nick [::Language::str "oponent_likes_that_you_decided_to_skip" [list $player]]
                    WaitEvent $nick "waitshoot $player $game"
                    WaitEvent $player "shoot $nick $game"
                }
                "2" {
                    ::Say::default "game" $nick $nick [::Language::str "already_shooted_here"]
                    ::Say::default "game" $nick $nick [::Language::str "enter_coordinates"]
                }
            }
        } 
    }
}

proc PlayGameInfo_Start { game nick } {
    global grid_width grid_height
    switch [string tolower $game] {
        "seabattle" {
            ::Language::say "game" $nick $nick "seabattle_start_info"
            DrawGrid [list null] $nick
        }
    }
}

proc DrawGrid { data nick } {
    global grid_width grid_height
    set msg {}
    set width $grid_width
    set height $grid_height
    append msg "\*\"
    foreach x $width {
        append msg "\|"
        append msg $x
    }
    append msg "\n"
    foreach y $height {
        append msg "$y"
        foreach x $width {
           append msg "\|"
           if {[lsearch $data "$x$y"]>-1} {
                append msg "\x\"
           } else {
                append msg "\o\"
           }
        }
        append msg "\n"
    }
    ::Say::default "game" $nick $nick $msg
}

proc DrawGrid2 { nick } {
    global grid_width grid_height
    set msg {}
    set width $grid_width
    set height $grid_height
    append msg "\*\"
    foreach x $width {
        append msg "\|"
        append msg $x
    }
    append msg "\n"
    foreach y $height {
        append msg "$y"
        foreach x $width {
            set val [::DB::getcell "Seabattle" "value" "nick ='$nick' and row = '$y' and collumn = '$x'"]
            append msg "\|"
            append msg "\"
            append msg $val
            append msg "\"
        }
        append msg "\n"
    }
    ::Say::default "game" $nick $nick $msg
}

proc DrawGrid3 { nick player } {
    global grid_width grid_height
    set msg {}
    set width $grid_width
    set height $grid_height
    append msg "\*\"
    foreach x $width {
        append msg "\|"
        append msg $x
    }
    append msg "\n"
    foreach y $height {
        append msg "$y"
        foreach x $width {
            set val [::DB::getcell "Seabattle" "value" "nick ='$player' and row = '$y' and collumn = '$x'"]
            append msg "\|"
            append msg "\"
            if {[string equal $val "1"]==1} {
                set val "0";
            }
            append msg $val
            append msg "\"
            append msg "\n"
        }
        ::Say::default "game" $nick $nick $msg
    }
}

proc PlayBegin { game nick player } {
    global grid_width grid_height
    ::DB::exec "DELETE FROM `Seabattle` WHERE `Nick` IN ('$nick', '$player');"
    set sql "INSERT INTO `Seabattle` (`Nick` ,`Row` ,`Collumn` ,`Value` ) VALUES "
    set parts [list]
    foreach y $grid_height {
        foreach x $grid_width {
            lappend parts "('$nick', '$y', '$x', '0')"
            lappend parts "('$player', '$y', '$x', '0')"
        }
    } 
    ::DB::exec [concat $sql [join $parts ", "] ";"]
    WaitEvent $nick "place $player $game"
    WaitEvent $player "place $nick $game"
    PlayGameInfo_Start $game $nick
    ::Say::default "game" $nick $nick [::Language::str "enter_coordinate"]
    PlayGameInfo_Start $game $player
    ::Say::default "game" $player $player [::Language::str "enter_coordinate"]
}

set my_games [string map {"Game_" ""} [info commands "Game_*"]]
###################################################################################
