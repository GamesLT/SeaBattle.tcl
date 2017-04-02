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
foreach varname [list "qstat_flag" "botpass" "skystats_max" "skystats_i" "sqluser" "sqlpass" "sqlhost" "sqldb" "language"] {
    if {![info exists $varname]} {
        puts "$varname in seabattle_config.tcl is not defined"
        exit 2
    }
}

source [file join $spath "translations" "$language.tcl"]
foreach varname [list "msg_dontunderstand" "commands_alias" "translation"] {
    if {![info exists $varname]} {
        puts "$varname in translations/$language.tcl is not defined"
        exit 3
    }
}

set mpath [file join $spath "tcllibs"]

set lib_m_path [file join $mpath "libmysqltcl3.02.so"]
if { [file exists $lib_m_path] } {
    package ifneeded mysqltcl [list load $lib_m_path mysqltcl]
}
unset lib_m_path
package require mysqltcl

set qversion "0.7"
set db_handle [mysqlconnect -host $sqlhost -user $sqluser -password $sqlpass -db $sqldb]

bind pub $qstat_flag "!admin" pub:admin_commands
bind pub $qstat_flag "!help" pub:help
bind msg $qstat_flag "user" pub:user
bind msgm $qstat_flag * pub:private_chat

#bind JOIN -|- * pub:join

bind NOTC -|- "This nickname is registered and protected.*" nickserv_identify

proc db_count { table query } {
    global db_handle
    
    set sql "select count(*) as count from $table where $query"; 
    set result [mysqlquery $db_handle $sql]
    set row [mysqlnext $result]
    
    mysqlendquery $result
    
    return $row
}

proc isadmin { nick }  {
    return [db_count "Users" "Nick='$nick' and Admin='true'"]
}

proc nickserv_identify { nick host hand arg txt } { 
    global bot_pass
    putquick "PRIVMSG nickserv@aitvaras.omnitel.net :identify $bot_pass"
}

proc say { md ns chan text } {
    global nick
    set lst [list "%botname%" "$nick"]
    set text [string map $lst $text]
    set txt [split $text " "]
    set text "$text"
    set txt [split $text "\n"]
    foreach item $txt {
        switch [string tolower $md] {
            "error" {
                putserv "NOTICE $ns :$item"
            }
            "public" {
                putserv "PRIVMSG $chan :$item"
            }
            default {
                putserv "PRIVMSG $ns :$item"
            }
        }
    }
}

proc mysql_getcell { table cell where } {
    global db_handle
    
    set sql "select $cell from $table where $where"; 
    set result [mysqlquery $db_handle $sql]
    set row [mysqlnext $result]
    set first [string range $row 0 0]
    
    mysqlendquery $result
    
    if { $first == "\{" } {
        set row [string range $row 1 end-1]
    }
    return $row
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
    set lhost [mysql_getcell "Users" "host" "nick = '$nik'"]
    if { $lhost == $host } {
        return 1;
    } else {
        return 0;
    }
}

proc WaitEvent { nick event } {
    global db_handle
    putlog "-> $nick $event"
    set sql "UPDATE `Users` SET `Command` = '$event' WHERE `Nick` = '$nick' LIMIT 1;"
    set rez [mysqlexec $db_handle $sql]
}

proc lang_str { kind {params {}} {return_as_list false} } {
    global translation
    set ret $translation($kind)
    if { [llength $ret] > 0 } {
        set ret [join $ret "\n"]
    }
    if { $ret == "" } {
        return [emptyline]
    }
    set ret [make_codes_live $ret]
    if {[llength $params] > 0} {
        set ret [format $ret $params]
    }
    if { $return_as_list == true } {
        return [split $ret "\n"]
    } else {
        return $ret
    }
}

proc make_codes_live { text } {
    set ret [regsub -all "<b>(.+)<\/b>" $text [boldtext "\\1"]]
    set ret [regsub -all "<i>(.+)<\/i>" $ret [italictext "\\1"]]
    set ret [regsub -all "<u>(.+)<\/u>" $ret [underlinetext "\\1"]]
    return [regsub -all "<color[\ ]+([^>]+)>(.+)<\/color>" $ret [colortext "\\2" "\\1"]]
}

proc multiline_translated_say { ni lang_string {params {}}} {
    foreach line [lang_str $lang_string $params true] {
        putquick "PRIVMSG $ni :$line"
    }
}

proc multiline_translated_say2 { type nick1 nick2 lang_string {params {}}} {
    foreach line [lang_str $lang_string $params true] {
        say $type $nick1 $nick2 $line
    }
}

proc say_unknown { ni } {
    global nick
    set id [mysql_getcell "Users" "id" "nick = '$ni'"]
    if {[string trim $id]==""} {
        multiline_translated_say $ni "please_register"
    } else {
        multiline_translated_say $ni "enter_pass"
        WaitEvent $ni "enterpass"
    }
}

proc get_unixtime {} {
    set ct(hrs) [clock format [clock seconds] -format %H]
    set ct(min) [clock format [clock seconds] -format %M]
    set ct(sec) [clock format [clock seconds] -format %S]
    return [expr $ct(hrs)*3600+$ct(min)*60+$ct(sec)]
}

proc pub:admin_commands { nick host handle chan text } {
    global db_handle
    if {[is_identified $nick $host]==0} {
        say_unknown $nick
        return 0
    }
    if {[isadmin $nick]<1} {
        say "error" $nick $chan [lang_str "you_are_not_my_admin"];
        return 0;
    }
    set command [lindex $text 0]
    set params [lrange $text 1 end]    
    switch [string tolower $command] {
        "rehash" {
            say "error" $nick $chan [lang_str "rehashing"]
            rehash
        }
        "restart" {
            say "error" $nick $chan [lang_str "restarting"]
            restart
        }
        "die" {
            say "error" $nick $chan [lang_str "shutdowning"]
            die $params
        }
        "channels" {
            set command [lindex $text 1]
            set chan2 [lindex $text 2]
            switch [string tolower $command] {
                "add" {
                    say "error" $nick $chan [lang_str "shutdowning" [list $chan2]]
                    channel add $chan2
                }
                "remove" {
                    say "error" $nick $chan [lang_str "channel_removed_from" [list $chan2]]
                    channel remove $chan2
                }
                "info" {
                    set rez [channel info $chan2]
                    say "error" $nick $chan [lang_str "channel_info" [list $chan2 $rez]]
                }
            }
        }
        "admins" {
            set command [lindex $text 1]
            set user [lindex $text 2]
            switch [string tolower $command] {
                "add" {
                    set id [mysql_getcell "Users" "id" "nick = '$user'"] 
                    if { [string trim $id] == "" } {
                        set sql "INSERT INTO `Users` (`Nick` ,`Admin`) VALUES ('$user', 'true');"
                        set rez [mysqlexec $db_handle $sql]
                    } else {
                        set sql "UPDATE `Users` SET `Admin` = 'true' WHERE `ID` = '$id' LIMIT 1;"
                        set rez [mysqlexec $db_handle $sql]
                    }
                    say "error" $nick $chan [lang_str "user_got_promoted_to_admin" [list $user]]
                }
                "is" {
                    if {[isadmin $user]} {
                        say "error" $nick $chan [lang_str "is_admin" [list $user]]
                    } else {
                        say "error" $nick $chan [lang_str "is_not_admin" [list $user]]
                    }
                }
                "remove" {
                    set id [mysql_getcell "Users" "id" "nick = '$user'"] 
                    if { [string trim $id] == "" } {
                        say "error" $nick $chan [lang_str "user_not_found"]
                    } else {
                        set sql "UPDATE `Users` SET `Admin` = 'false' WHERE `ID` = '$id' LIMIT 1 ;"
                        set rez [mysqlexec $db_handle $sql]
                        say "error" $nick $chan [lang_str "admin_revoked" [list $user]]
                    }
                }
                "list" {
                    say "error" $nick $chan [lang_str "admins_list_start"]
                    set sql "SELECT nick FROM `Users` WHERE admin ='true';"
                    set query1 [mysqlquery $db_handle $sql]
                    set i [expr int(0)]
                    set is 0
                    while {[set row [mysqlnext $query1]]!=""} {
                        set i [expr $i+1]
                        set is 1
                        say "error" $nick $chan "$i\.\ $row"
                    }
                    if {$is==0}    {
                        say "error" $nick $chan [lang_str "admins_list_empty"]
                    }
                    mysqlendquery $query1
                }
            }
        }
        "sethelp" {
            set item [lindex $text 1]
            set syntax [lindex $text 2]
            set description [lrange $text 3 end]
            set id [mysql_getcell "Help" "id" "item = '$item'"] 
            if { [string trim $id] == "" } {
                set sql "INSERT INTO `Help` ( `Item`, `Description`, `Syntax`) VALUES ('$item', '$description','$syntax');"
                set rez [mysqlexec $db_handle $sql]
            } else {
                set sql "UPDATE `Help` SET `Description` = '$description' WHERE `ID` = '$id' LIMIT 1 ;"
                set rez [mysqlexec $db_handle $sql]
                set sql "UPDATE `Help` SET `Syntax` = '$syntax' WHERE `ID` = '$id' LIMIT 1 ;"
                set rez [mysqlexec $db_handle $sql]
            }
            say "error" $nick $chan [lang_str "help_updated"]
        }
        "delhelp" {
            set item [lindex $text 1 end]
            set id [mysql_getcell "Help" "id" "item = '$item'"] 
            if { [string trim $id] == "" } {
                say "error" $nick $chan [lang_str "help_cant_remove"]
            } else {
                set sql "DELETE FROM `Help` WHERE `ID` = '$id';"
                set rez [mysqlexec $db_handle $sql]
                say "error" $nick $chan [lang_str "help_updated"]
            }
        }
        "set" {
            set item [lindex $text 1]
            set value [lrange $text 2 end]
            set id [mysql_getcell "settings" "id" "setting = '$item'"] 
            if { [string trim $id] == "" } {
                set sql "INSERT INTO `settings` (`Setting` ,`Value`) VALUES ('$item', '$value');"
                set rez [mysqlexec $db_handle $sql]
            } else {
                set sql "UPDATE `settings` SET `Value` = '$value' WHERE `ID` = '$id' LIMIT 1 ;"
                set rez [mysqlexec $db_handle $sql]
            }
            say "error" $nick $chan [lang_str "bot_settings_updated"]
        }
        "nick" {
            change_nick [lindex $text 1]
        }
        "say" {
           set nk [lindex $text 1]
           set msg [lrange $text 2 end]
           putquick "PRIVMSG $nk : $msg"
        }
    }
}

proc change_nick { new_nick } {
    global nick
    set nick $new_nick
}

proc emptyline { } {
    return "\"
}

proc boldtext { text } {
    return "\$text\"
}

proc italictext { text } {
    return "\$text\"
}

proc underlinetext { text } {
    return "\$text\"
}

proc colortext { text color } {
    switch [string tolower $color] {
        1 -
        "black" {
            set c 1
        }
        2 -
        "navyblue" {
            set c 2
        }
        3 -
        "green" {
            set c 3
        }
        4 -
        "red" {
            set c 4
        }
        5 -
        "brown" {
            set c 5
        }
        6 -
        "purple" {
            set c 6
        }
        7 -
        "olive" {
            set c 7
        }
        8 -
        "yellow" {
            set c 8
        }
        9 -
        "limegreen" {
            set c 9
        }
        10 -
        "teal" {
            set c 10
        }
        11 -
        "aqualight" {
            set c 11
        }
        12 -
        "royalblue" {
            set c 12
        }
        13 -
        "hotpink" {
            set c 13
        }
        14 -
        "darkgray" {
            set c 14
        }
        15 -
        "lightgray" {
            set c 15
        }
        16 -
        "white" {
            set c 16
        }
        default {
            set c 0
        }
    }
    return "\$c$text\0"
}

proc getini { setting } {
    return [mysql_getcell "settings" "value" "setting = '$setting'"]
}

proc pub:help { nick host handle chan text } {
    global db_handle
    if { [string trim $text] == ""} {
        set sql "SELECT id FROM `Help`;"
        say "error" $nick $chan [getini "about"]
    }
    set text [string tolower $text]
    set description [mysql_getcell "Help" "description" "item = '$text'"]
    set syntax [mysql_getcell "Help" "syntax" "item = '$text'"]
    if { [string trim $description] == "" } {
        # to tikriausiai nebus :)
    } else {
        set text [string toupper $text]
        say "error" $nick $chan [lang_str "help_syntax" [list $text $syntax]]
        say "error" $nick $chan [emptyline]
        say "error" $nick $chan "$description"
        set sql "SELECT id FROM `Help` WHERE item LIKE '$text %';"
    }
    if {![info exists sql]} {
        say "error" $nick $chan [lang_str "help_nothing"]
        return 0;
    }
    set query1 [mysqlquery $db_handle $sql]
    set i 0
    while {[set row [mysqlnext $query1]]!=""} {
        set id $row
        if {$i==0} {
           say "error" $nick $chan [emptyline]
        }
        set i 1
        set item [mysql_getcell "Help" "item" "id = '$id'"]
        set le [expr [string length $text]+1]
        if { $le == 1 } {
            set le 0
        }
        set item [string toupper [string range $item $le end]]
        set syntax [mysql_getcell "Help" "syntax" "id = '$id'"]
        set description [mysql_getcell "Help" "description" "id = '$id'"]
        set txt "$item $syntax - $description"
        set cg [string first " " $item]
        if {$cg==-1} {
            say "error" $nick $chan $txt
        }
    }
    mysqlendquery $query1
}

proc random_item {list} {
    set random [rand [llength $list]]
    return [lindex $list $random]
}

proc DoSQL { sql } {
    global db_handle 
    return [mysqlexec $db_handle $sql]
}

proc lang_privmsg { nick msg_str } {
    set msg [lang_str $msg_str]
    putquick "PRIVMSG $nick :$msg"
}

proc pub:private_chat { nick host handle text } {
    global db_handle msg_dontunderstand botnick
    set id [mysql_getcell "Users" "id" "nick = '$nick'"] 
    if {[string trim $id]==""} {
        if {[is_good_command msg $text]==1} {
            return 0;
        }
        multiline_translated_say2 "error" $nick $nick "you_should_register_first"
        return 0;
    }
    set txt [mysql_getcell "Users" "command" "nick = '$nick'"]
    set cmd [lindex $txt 0]
    switch [string tolower $cmd] {
        "enterpass" {
            set pass [mysql_getcell "Users" "password" "nick = '$nick'"] 
            if { $pass == $text } {
                set sql "UPDATE `Users` SET `Host` = '$host' WHERE `ID` = '$id' LIMIT 1;"
                set rez [mysqlexec $db_handle $sql]
                lang_privmsg $nick "thanks_fo_reminding"
                WaitEvent $nick ""
                return 1
            } else {
                lang_privmsg $nick "do_yoooou_try_to_cheat_me"
                lang_privmsg $nick "enter_pass2"
            }
        }
        "agree" {
            set player [lindex $txt 1]
            set game [lindex $txt 2]
            if {[string equal -nocase $text [lang_str "no"]]==1} {
                say "game" $player $player [lang_str "rejected_invitation" [list $nick $game]]
                WaitEvent $nick ""
                WaitEvent $player ""
                return 1;
            }
            if {[string equal -nocase $text [lang_str "yes"]]==1}    {
                say "game" $player $player [lang_str "accepted_invitation" [list $nick]]
                say "game" $player $player [lang_str "game_will_start_soon"]
                say "game" $nick $nick [lang_str "game_will_start_soon"]
                WaitEvent $nick ""
                WaitEvent $player ""
                putlog toliau
                PlayBegin $game $nick $player
                putlog toliaua
                return 1;
            }
            say "game" $nick $nick [lang_str "i_cant_understand"]
            say "game" $nick $nick [lang_str "write_yes_or_no"]
        }
        default {
            set command [lindex $txt 0]
            set game [lindex $txt 2]
            set player [lindex $txt 1]
            PlayGame $command $game $nick $player $text
        }
    }
}

set tdata("unknown") ""

proc pub:user { nick host handle text } {
    global db_handle tdata
    set command [lindex $text 0]
    set params [lrange $text 1 end]
    set chan $nick
    switch [string tolower $command] {
        "logout" {
            set id [mysql_getcell "Users" "id" "nick = '$nick'"] 
            if {[string trim $id]==""} {
                multiline_translated_say2 "error" $nick $nick "you_should_register_first"
                return 0;
            }
            set host [mysql_getcell "Users" "host" "id = '$id'"] 
            if {[string trim $host]==""} {
                say "error" $nick $chan [lang_str "please_login"]
                return 0;
            }
            set sql "UPDATE `Users` SET `Host` = '' WHERE `ID` = '$id' LIMIT 1 ;"
            set rez [mysqlexec $db_handle $sql]
            say "error" $nick $chan [lang_str "logged_out"]
            return 1;
        }
        "set" {
            set item [lindex $params 0]
            set value [lindex $params 1]
            if {[is_identified $nick $host]==0} {
                say_unknown $nick
                return 0;
            }
            switch [string tolower $item] {
                "password" {
                    set id [mysql_getcell "Users" "id" "nick = '$nick'"] 
                    set oldpass [mysql_getcell "Users" "password" "id = '$id'"] 
                    set sql "UPDATE `Users` SET `Password` = '$value' WHERE `ID` = '$id' LIMIT 1 ;"
                    set rez [mysqlexec $db_handle $sql]
                    say "error" $nick $chan [lang_str "changed_password" [list $oldpass $value]]
                }
                "email" {
                    set id [mysql_getcell "Users" "id" "nick = '$nick'"] 
                    set email [mysql_getcell "Users" "`E-Mail`" "id = '$id'"] 
                    set sql "UPDATE `Users` SET `E-Mail` = '$value' WHERE `ID` = '$id' LIMIT 1 ;"
                    set rez [mysqlexec $db_handle $sql]
                    say "error" $nick $chan [lang_str "changed_email" [list $email $value]]
                }
                default {
                    say "error" $nick $chan [lang_str "this_setting_cant_be_changed"]
                }
            }
        }
        "register" {
            if {[isignore "*!*@aitvaras.net"]==1} {
                killignore "*!*@aitvaras.net";
            }
            if {[isignore "*!ubaldas@aitvaras.net"]==1} {
                killignore "*!ubaldas@aitvaras.net";
            }
            bind NOTC -|- "$nick*" ndata
            set tdata(nick) $nick
            set tdata(pass) [lindex $params 0]
            set tdata(email) [lindex $params 1]
            set tdata(host) $host
            set tnick $nick
            utimer 10 regerror
            putserv "PRIVMSG nickserv@aitvaras.omnitel.net :info $nick"
        }
    }
}

proc regerror {} {
    global tdata
    if {$tdata(nick)==""} {
        return;
    }
    set nick $tdata(nick)
    multiline_translated_say2 "error" $nick $nick "nickserv_registration_is_must"
    unbind NOTC -|- "$nick*" ndata
}

proc ndata { nick host handle text dest} {
    global tdata db_handle
    set xnick $nick
    set xhost $host
    set nick [lindex $text 0]
    set host $tdata(host)
    if {[string equal -nocase $xnick NickServ]==1} {
        set tdata(nick) ""
        set chan $nick
        unbind NOTC -|- "$nick*" ndata
        set pass $tdata(pass)
        set email $tdata(email)
        set id [mysql_getcell "Users" "id" "nick = '$nick'"]
        putlog "$id>>"
        if {[string trim $id]!=""} {
            say "error" $nick $chan [lang_str "such_user_exists"]
            return 0;
        }
        set sql "INSERT INTO `Users` (`ID`, `Nick`, `Admin`, `Host`, `Password`, `E-Mail`, `LastLogged`)"
        append sql "VALUES ("
        append sql "'', '$nick', 'false', '$host', '$pass', '$email', ''"
        append sql ");"
        set rez [mysqlexec $db_handle $sql]
        multiline_translated_say2 "error" $nick $chan "registration_msg" [list $pass $email]
    }
}

###################################################################################
# Here is starting evil game code #################################################
###################################################################################

bind pub -||- "!play" pub:play
bind pub -||- "!stats" pub:stats

bind msg $qstat_flag "play" pub:play2
bind msg $qstat_flag "stats" pub:stats2

timer 1 autoend

proc autoend {}    {
    global db_handle
    set dothiscommand [mysql_getcell "TodoList" "Arguments" "Command = 'CheckIfAutoEnd' LIMIT 1"]
    timer 1 autoend
    if {[string trim $dothiscommand]==""} {
        return;
    }
    set nick [lindex $dothiscommand 0]
    set player2 [lindex $dothiscommand 1]
    set player $player2
    if {[onchan $nick]==0} {
        say "error" $player2 $player2 [lang_str "other_player_quited" [list $nick]]
        multiline_translated_say2 "error" $nick $nick "registration_msg" [list $player2]
        DoSQL "DELETE FROM TodoList WHERE Arguments = '$dothiscommand' AND Command = 'CheckIfAutoEnd';"
        DoSQL "UPDATE `Users` SET StatNA = StatNA + 1 WHERE `Nick` IN ('$nick', '$player');"
        WaitEvent $nick ""
        WaitEvent $player2 ""
        return;
    }
    if {[onchan $player2]==0} {
        say "error" $nick $nick [lang_str "other_player_left_channel" [list $player2]]
        multiline_translated_say2 "error" $player2 $player2 "you_left_channel" [list $nick]
        DoSQL "DELETE FROM TodoList WHERE Arguments = '$dothiscommand' AND Command = 'CheckIfAutoEnd';"
        DoSQL "UPDATE `Users` SET StatNA = StatNA + 1 WHERE `Nick` IN ('$nick', '$player');"
        WaitEvent $nick ""
        WaitEvent $player2 ""
        return;
    }
    set lastaction1 [mysql_getcell "Users" "LastAction" "Nick = '$nick'"] 
    set lastaction2 [mysql_getcell "Users" "LastAction" "Nick = '$player2'"] 
    set laikas [get_unixtime]
    DoSQL "DELETE FROM TodoList WHERE Arguments = '$dothiscommand' AND Command = 'CheckIfAutoEnd'"
    if {$laikas>[expr $lastaction1+960]} {
        say "error" $nick $nick [lang_str "game_canceled_because_you_idled"]
        say "error" $player2 $player2 [lang_str "game_canceled_because_other_player_not_moved"]
        DoSQL "UPDATE `Users` SET StatNA = StatNA + 1 WHERE `Nick` IN ('$nick', '$player')"
        WaitEvent $nick ""
        WaitEvent $player2 ""
        return;
    }
    if {$laikas>[expr $lastaction2+960]} {
        say "error" $player2 $player2 [lang_str "game_canceled_because_you_idled"]
        say "error" $nick $nick [lang_str "game_canceled_because_other_player_not_moved"]
        DoSQL "UPDATE `Users` SET StatNA = StatNA + 1 WHERE `Nick` IN ('$nick', '$player')"
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
        if {[db_count "Users" "Nick = '$nick'"]<1} {
            multiline_translated_say2 "error" $nick $chan "cant_show_stats"
            return
        } 
        say "error" $nick $chan [lang_str "your_stats"]
        set user $nick
    } else {
        set user [lindex $text 0]
        if {[db_count "Users" "Nick = '$user'"]<1} {
            multiline_translated_say2 "error" $nick $chan "cant_show_stats_for" [list $user]
            return
        }
        say "error" $nick $chan [lang_str "user_stats" [list $user]]
    }
    set won [mysql_getcell "Users" "StatWon" "Nick = '$user'"] 
    set lost [mysql_getcell "Users" "StatLost" "Nick = '$user'"] 
    set na [mysql_getcell "Users" "StatNA" "Nick = '$user'"]
    multiline_translated_say2 "error" $nick $chan "stats_data" [list $won $lost $na [expr $na+$won+$lost]]
}

proc pub:play { nick host handle chan text } {
    global my_games botnick

    set game [lindex $text 0]
    set player2 [lindex $text 1]

    if {[is_identified $nick $host]==0} {
        say_unknown $nick
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
        say "error" $nick $chan [lang_str "please_select_game" [list $games]]
        return 0
    }

    if {$player2==""} {
        say "error" $nick $chan [lang_str "please_select_oponent" [list $game $game $botnick]]
        return 0
    }

    if {[string equal -nocase $player2 $botnick]==1} {
        say "error" $nick $chan [lang_str "bot_rejects_game"]
        return 0
    }

    if {[string equal -nocase $player2 $nick]==1} {
        say "error" $nick $chan [lang_str "bot_cant_invite_you"]
        return 0;
    }

    if {[onchan $nick]==0} {
        multiline_translated_say2 "error" $nick $chan "you_not_in_my_channels"
        return
    }

    if {[onchan $player2]==0} {
        multiline_translated_say2 "error" $nick $chan "another_player_not_in_my_channels" [list $player2]
        return
    }

    if {[string equal -nocase [mysql_getcell "Users" "Command" "nick = '$player2'"]    ""]==0} {
        say "error" $nick $chan [lang_str "another_player_now_playing" [list $player2]]
        return
    }

    if {[string equal -nocase [mysql_getcell "Users" "Command" "nick = '$nick'"] ""]==0} {
        multiline_translated_say2 "error" $nick $chan "you_are_playing_other_game"
        return
    }

    set count [db_count "Users" "nick = '$player2'"]
    if {$count<1} {
        multiline_translated_say2 "game" $player2 $chan "got_invitation_but_not_registered" [list $nick $game $botnick]
        multiline_translated_say2 "game" $nick $chan "invited_but_another_player_must_register_first" [list $player2]
        return 0;
    }

    multiline_translated_say2 "game" $nick $chan "selected_game_info" [list $game $player2]
    WaitEvent $player2 "wagree $player2 $game"

    multiline_translated_say2 "game" $player2 $chan "invited_to_game" [list $nick $game]
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
    DoSQL "UPDATE `Users` SET LastAction = '$laikas' WHERE `Nick` = '$nick' LIMIT 1;"
    DoSQL "DELETE FROM TodoList WHERE Command = 'CheckIfAutoEnd' AND (Arguments LIKE '% $nick' OR Arguments LIKE '$nick %');" 
    DoSQL "INSERT INTO `TodoList` (`ID`, `Command`, `Arguments`) VALUES ('', 'CheckIfAutoEnd', '$nick $player');" 
    set textp [string tolower $text]
    if {[info exists commands_alias($textp)]==1} {
        set textp $commands_alias($textp)
    }
    switch [string tolower $textp] {
        "!map" {
            if {[string equal -nocase "shoot" $command]==0} {
                return;
            }
            set msg [lang_str "this_is_how_your_map_looks"]
            say "game" $nick $nick $msg
            DrawGrid2 $nick
            say "game" $nick $nick [lang_str "enter_coordinates"]
            return
        }
        "!map2" {
            if {[string equal -nocase "shoot" $command]==0} {
                return;
            }
            set msg [lang_str "this_is_how_oponent_map_looks"]
            say "game" $nick $nick $msg
            DrawGrid3 $nick $player
            say "game" $nick $nick [lang_str "enter_coordinates"]
            return
        }
        "!map3" {
            if {[string equal -nocase "shoot" $command]==0} {
                return;
            }
            set msg [lang_str "this_is_how_your_map_looks"]
            say "game" $nick $nick $msg
            DrawGrid2 $nick
            set msg [lang_str "this_is_how_oponent_map_looks"]
            say "game" $nick $nick $msg
            DrawGrid3 $nick $player
            say "game" $nick $nick [lang_str "enter_coordinates"]
            return
        }
        "!end" {
            WaitEvent $nick ""
            WaitEvent $player ""
            DoSQL "DELETE FROM Seabattle WHERE (Nick = '$nick') OR (Nick = '$player');" 
            DoSQL "DELETE FROM TodoList WHERE Command = 'CheckIfAutoEnd' AND (Arguments LIKE '% $nick' OR Arguments LIKE '$nick %');" 
            DoSQL "UPDATE `Users` SET StatNA = StatNA + 1 WHERE `Nick` IN ('$nick', '$player');"
            multiline_translated_say2 "game" $nick $nick "end_iniciated_by_you" [list $player]
            multiline_translated_say2 "game" $player $player "end_iniciated_by_other_player" [list $nick]
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
                    set count [db_count "Seabattle" "nick = '$nick' and value = '1'"]
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
                say "game" $nick $nick [lang_str "bad_coordinates" [list $coll $row]]
                if {$arg!="l"} {
                    say "game" $nick $nick [lang_str "enter_coordinates"]
                }
                return 0;
            }
            if {[lsearch $grid_height $row]==-1} {
                say "game" $nick $nick [lang_str "bad_coordinates" [list $coll $row]]
                if {$arg!="l"} {
                    say "game" $nick $nick [lang_str "enter_coordinates"]
                }
                return 0;
            }
            set count [db_count "Seabattle" "nick = '$nick' and value = '1'"]
            set val [mysql_getcell "Seabattle" "value" "nick ='$nick' and row = '$row' and collumn = '$coll'"]
            if {$val!="0"} {
                say "game" $nick $nick [lang_str "there_is_alread_a_ship" [list $coll $row]]
                if {$arg!="l"} {
                    say "game" $nick $nick [lang_str "enter_coordinates"]
                }
                return 0;
            }     
            set id [mysql_getcell "Seabattle" "id" "nick ='$nick' and row = '$row' and collumn = '$coll'"]
            DoSQL "UPDATE Seabattle SET `Value` = '1' WHERE `ID` = '$id' LIMIT 1;"
            say "game" $nick $nick [lang_str "you_just_places_a_ship" [list [expr $count+1] $coll $row]]
            if {$count<$ship_count} {
                if {$arg!="l"} {
                    say "game" $nick $nick [lang_str "enter_coordinates_for_ship" [list [expr $count+2]]]
                }
            } else {
                set txt [mysql_getcell "Users" "command" "nick = '$player'"]
                set cmd [lindex $txt 0]
                set data [list "+(none)+"]
                foreach x $grid_width {
                    foreach y $grid_height {
                        set val [mysql_getcell "Seabattle" "value" "nick ='$nick' and row = '$y' and collumn = '$x'"]
                        if {$val!="0"} {
                            lappend data $x$y
                        }
                    }
                }
                set msg [lang_str "this_is_how_your_map_looks"]
                say "game" $nick $nick $msg
                DrawGrid $data $nick
                switch $cmd {
                    "waituntilplace" {
                        WaitEvent $player "shoot $nick $game"
                        multiline_translated_say2 "game" $player $player "seabattle_starts_enter_coordinates"
                        WaitEvent $nick "waitshoot $player $game"
                        multiline_translated_say2 "game" $nick $nick "seabattle_soon_you_will_need_to_shhot_something" [list $player]
                    }
                    default {
                        WaitEvent $nick "waituntilplace $nick $game"
                        say "game" $nick $nick [lang_str "wait_for_player_to_places_ships" [list $nick]]
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
                say "game" $nick $nick [lang_str "bad_coordinates" [list $coll $row]]
                if {$arg!="l"} {
                    say "game" $nick $nick [lang_str "enter_coordinates"]
                }
                return 0;
            }
            if {[lsearch $grid_height $row]==-1} {
                say "game" $nick $nick [lang_str "bad_coordinates" [list $coll $row]]
                if {$arg!="l"} {
                    say "game" $nick $nick [lang_str "enter_coordinates"]
                }
                return 0;
            }
            set val [mysql_getcell "Seabattle" "value" "nick ='$player' and row = '$row' and collumn = '$coll'"]        
            switch $val {
                "1" {
                    say "game" $player $player [lang_str "shoot_to" [list $nick $coll $row]]
                    say "game" $player $player [lang_str "ship_sink"]
                    DoSQL "UPDATE `Seabattle` SET `Value` = '2' WHERE nick ='$player' and row = '$row' and collumn = '$coll';"
                    say "game" $nick $nick [lang_str "shoot_good_results"]
                    set count [db_count "Seabattle" "nick = '$player' and value = '1'"]
                    if {$count<1} {
                        WaitEvent $nick ""
                        WaitEvent $player ""
                        set data [list "+(none)+"]
                        foreach x $grid_width {
                            foreach y $grid_height {
                                set val [mysql_getcell "Seabattle" "value" "nick ='$nick' and row = '$y' and collumn = '$x'"]
                                if {$val=="1"} {
                                    lappend data $x$y
                                }
                                if {$val=="2"} {
                                    lappend data $x$y
                                }
                            }
                        }
                        say "game" $player $player [lang_str "that_was_last_ship"]
                        say "game" $player $player [lang_str "i_will_show_your_opnent_map"]
                        DrawGrid $data $player
                        say "game" $player $player [lang_str "has_won" [list $nick]]
                        DoSQL "UPDATE `Users` SET StatWon = StatWon + 1 WHERE `Nick` = '$nick' LIMIT 1;"
                        DoSQL "UPDATE `Users` SET StatLost = StatLost + 1 WHERE `Nick` = '$player' LIMIT 1;"
                        say "game" $nick $nick [lang_str "congratulations"]
                        return 0;
                    } else {
                        set count [db_count "Seabattle" "nick = '$player' and value = '1'"]
                        say "game" $player $player [lang_str "ships_count" [list $count]]
                        say "game" $nick $nick [lang_str "ships_count" [list $count]]
                    }
                    say "game" $nick $nick [lang_str "enter_coordinates"]
                }
                "0" {
                    say "game" $player $player [lang_str "shoot_to" [list $nick $coll $row]]
                    say "game" $player $player [lang_str "there_was_no_ship"]
                    say "game" $nick $nick [lang_str "shoot_bad_results"]
                    DoSQL "UPDATE `Seabattle` SET `Value` = '3' WHERE nick ='$player' and row = '$row' and collumn = '$coll';"
                    WaitEvent $nick "waitshoot $player $game"
                    WaitEvent $player "shoot $nick $game"
                    say "game" $player $player [lang_str "enter_coordinates"]
                }
                "3" {
                    multiline_translated_say2 "game" $player $player "bad_hands_doesnt_listens_to_head" [list $nick]
                    say "game" $nick $nick [lang_str "oponent_likes_that_you_decided_to_skip" [list $player]]
                    WaitEvent $nick "waitshoot $player $game"
                    WaitEvent $player "shoot $nick $game"
                }
                "2" {
                    say "game" $nick $nick [lang_str "already_shooted_here"]
                    say "game" $nick $nick [lang_str "enter_coordinates"]
                }
            }
        } 
    }
}

proc PlayGameInfo_Start { game nick } {
    global grid_width grid_height
    switch [string tolower $game] {
        "seabattle" {
            multiline_translated_say2 "game" $nick $nick "seabattle_start_info"
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
    say "game" $nick $nick $msg
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
            set val [mysql_getcell "Seabattle" "value" "nick ='$nick' and row = '$y' and collumn = '$x'"]
            append msg "\|"
            append msg "\"
            append msg $val
            append msg "\"
        }
        append msg "\n"
    }
    say "game" $nick $nick $msg
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
            set val [mysql_getcell "Seabattle" "value" "nick ='$player' and row = '$y' and collumn = '$x'"]
            append msg "\|"
            append msg "\"
            if {[string equal $val "1"]==1} {
                set val "0";
            }
            append msg $val
            append msg "\"
            append msg "\n"
        }
        say "game" $nick $nick $msg
    }
}

proc PlayBegin { game nick player } {
    global grid_width grid_height
    DoSQL "DELETE FROM `Seabattle` WHERE `Nick` IN ('$nick', '$player');"
    foreach y $grid_height {
        foreach x $grid_width {
            DoSQL "INSERT INTO `Seabattle` (`ID` ,`Nick` ,`Row` ,`Collumn` ,`Value` )  VALUES ('', '$nick', '$y', '$x', '0');" 
            DoSQL "INSERT INTO `Seabattle` (`ID` ,`Nick` ,`Row` ,`Collumn` ,`Value` )  VALUES ('', '$player', '$y', '$x', '0');" 
        }
    }
    PlayGameInfo_Start $game $nick
    say "game" $nick $nick [lang_str "enter_coordinate"]
    WaitEvent $nick "place $player $game"
    PlayGameInfo_Start $game $player
    say "game" $player $player [lang_str "enter_coordinate"]
}

set my_games [string map {"Game_" ""} [info commands "Game_*"]]
###################################################################################
