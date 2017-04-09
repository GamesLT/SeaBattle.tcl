namespace eval AdminCommands {
   namespace export handle
}

proc ::AdminCommands::handle { nick host handle chan text } {
    if {[is_identified $nick $host]==0} {
        say_unknown $nick
        return 0
    }
    if {[isadmin $nick]<1} {
        say "error" $nick $chan [::Language::str "you_are_not_my_admin"];
        return 0;
    }
    set command [lindex $text 0]
    set params [lrange $text 1 end]    
    switch [string tolower $command] {
        "rehash" {
            ::AdminCommands::doRehash $nick $chan
        }
        "restart" {
            ::AdminCommands::doRestart $nick $chan
        }
        "die" {
            ::AdminCommands::doDie $nick $chan $params
        }
        "channels" {
            ::AdminCommands::doChannelsCommand $nick $chan $text
        }
        "admins" {
            ::AdminCommands::doAdmins $nick $chan $text
        }
        "sethelp" {
            ::AdminCommands::doSetHelp $nick $chan $text
        }
        "delhelp" {
            ::AdminCommands::doDetHelp $nick $chan $text
        }
        "set" {
            ::AdminCommands::doSet $nick $chan $text
        }
        "nick" {
            ::AdminCommands::doChangeNick $text
        }
        "say" {
            ::AdminCommands::doSay $text
        }
    }
}

proc ::AdminCommands::doSetHelp {nick chan text} {
    set item [lindex $text 1]
    set syntax [lindex $text 2]
    set description [lrange $text 3 end]
    set id [::DB::getcell "Help" "id" "item = '$item'"] 
    if { [string trim $id] == "" } {
        set sql "INSERT INTO `Help` ( `Item`, `Description`, `Syntax`) VALUES ('$item', '$description','$syntax');"
        set rez [::DB::exec $sql]
    } else {
        set sql "UPDATE `Help` SET `Description` = '$description' WHERE `ID` = '$id' LIMIT 1 ;"
        set rez [::DB::exec $sql]
        set sql "UPDATE `Help` SET `Syntax` = '$syntax' WHERE `ID` = '$id' LIMIT 1 ;"
        set rez [::DB::exec $sql]
    }
    say "error" $nick $chan [::Language::str "help_updated"]
}

proc ::AdminCommands::doDetHelp {nick chan text} {
    set item [lindex $text 1 end]
    set id [::DB::getcell "Help" "id" "item = '$item'"] 
    if { [string trim $id] == "" } {
        say "error" $nick $chan [::Language::str "help_cant_remove"]
    } else {
        set sql "DELETE FROM `Help` WHERE `ID` = '$id';"
        set rez [::DB::exec $sql]
        say "error" $nick $chan [::Language::str "help_updated"]
    }
}

proc ::AdminCommands::doSet {nick chan text} {
    set item [lindex $text 1]
    set value [lrange $text 2 end]
    set id [::DB::getcell "settings" "id" "setting = '$item'"] 
    if { [string trim $id] == "" } {
        set sql "INSERT INTO `settings` (`Setting` ,`Value`) VALUES ('$item', '$value');"
        set rez [::DB::exec $sql]
    } else {
        set sql "UPDATE `settings` SET `Value` = '$value' WHERE `ID` = '$id' LIMIT 1 ;"
        set rez [::DB::exec $sql]
    }
    say "error" $nick $chan [::Language::str "bot_settings_updated"]
}

proc ::AdminCommands::doChangeNick {text} {
    global nick
    set new_nick [lindex $text 1]
    set nick $new_nick
}

proc ::AdminCommands::doSay {text} {
    set nk [lindex $text 1]
    set msg [lrange $text 2 end]
    putquick "PRIVMSG $nk : $msg"
}

proc ::AdminCommands::doRehash {nick chan} {
    say "error" $nick $chan [::Language::str "rehashing"]
    rehash
}

proc ::AdminCommands::doRestart {nick chan} {
    say "error" $nick $chan [::Language::str "restarting"]
    restart
}

proc ::AdminCommands::doDie {nick chan params} {
    say "error" $nick $chan [::Language::str "shutdowning"]
    die $params
}

proc ::AdminCommands::doChannelsCommand {nick chan text} {
    set command [lindex $text 1]
    set chan2 [lindex $text 2]
    switch [string tolower $command] {
        "add" {
        say "error" $nick $chan [::Language::str "shutdowning" [list $chan2]]
            channel add $chan2
        }
        "remove" {
            say "error" $nick $chan [::Language::str "channel_removed_from" [list $chan2]]
            channel remove $chan2
        }
        "info" {
            set rez [channel info $chan2]
            say "error" $nick $chan [::Language::str "channel_info" [list $chan2 $rez]]
        }
    }
}

proc ::AdminCommands::doAdmins {nick chan text} {
    set command [lindex $text 1]
    set user [lindex $text 2]
    switch [string tolower $command] {
        "add" {
            set id [::DB::getcell "Users" "id" "nick = '$user'"] 
            if { [string trim $id] == "" } {
                set sql "INSERT INTO `Users` (`Nick` ,`Admin`) VALUES ('$user', 'true');"
                set rez [::DB::exec $sql]
            } else {
                set sql "UPDATE `Users` SET `Admin` = 'true' WHERE `ID` = '$id' LIMIT 1;"
                set rez [::DB::exec $sql]
            }
            say "error" $nick $chan [::Language::str "user_got_promoted_to_admin" [list $user]]
        }
        "is" {
            if {[isadmin $user]} {
                say "error" $nick $chan [::Language::str "is_admin" [list $user]]
            } else {
                say "error" $nick $chan [::Language::str "is_not_admin" [list $user]]
            }
        }
        "remove" {
            set id [::DB::getcell "Users" "id" "nick = '$user'"] 
            if { [string trim $id] == "" } {
                say "error" $nick $chan [::Language::str "user_not_found"]
            } else {
                set sql "UPDATE `Users` SET `Admin` = 'false' WHERE `ID` = '$id' LIMIT 1 ;"
                set rez [::DB::exec $sql]
                say "error" $nick $chan [::Language::str "admin_revoked" [list $user]]
            }
        }
        "list" {
            say "error" $nick $chan [::Language::str "admins_list_start"]
            set sql "SELECT nick FROM `Users` WHERE admin ='true';"
            set query1 [::DB::query $sql]
            set i [expr int(0)]
            set is 0
            while {[set row [::DB:next $query1]]!=""} {
               set i [expr $i+1]
               set is 1
               say "error" $nick $chan "$i\.\ $row"
            }
            if {$is==0}    {
                say "error" $nick $chan [::Language::str "admins_list_empty"]
            }
            mysqlendquery $query1
         }
    }
}