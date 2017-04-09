namespace eval UserCommands {
   namespace export handle
}

proc ::UserCommands::handle { nick host handle text  } {
    global tdata
    set command [lindex $text 0]
    set params [lrange $text 1 end]
    set chan $nick
    switch [string tolower $command] {
        "logout" {
            set id [::DB::getcell "Users" "id" "nick = '$nick'"] 
            if {[string trim $id]==""} {
                ::Language::say "error" $nick $nick "you_should_register_first"
                return 0;
            }
            set host [::DB::getcell "Users" "host" "id = '$id'"] 
            if {[string trim $host]==""} {
                say "error" $nick $chan [::Language::str "please_login"]
                return 0;
            }
            set sql "UPDATE `Users` SET `Host` = '' WHERE `ID` = '$id' LIMIT 1 ;"
            set rez [::DB::exec $sql]
            say "error" $nick $chan [::Language::str "logged_out"]
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
                    set id [::DB::getcell "Users" "id" "nick = '$nick'"] 
                    set oldpass [::DB::getcell "Users" "password" "id = '$id'"] 
                    set sql "UPDATE `Users` SET `Password` = '$value' WHERE `ID` = '$id' LIMIT 1 ;"
                    set rez [::DB::exec $sql]
                    say "error" $nick $chan [::Language::str "changed_password" [list $oldpass $value]]
                }
                "email" {
                    set id [::DB::getcell "Users" "id" "nick = '$nick'"] 
                    set email [::DB::getcell "Users" "`E-Mail`" "id = '$id'"] 
                    set sql "UPDATE `Users` SET `E-Mail` = '$value' WHERE `ID` = '$id' LIMIT 1 ;"
                    set rez [::DB::exec $sql]
                    say "error" $nick $chan [::Language::str "changed_email" [list $email $value]]
                }
                default {
                    say "error" $nick $chan [::Language::str "this_setting_cant_be_changed"]
                }
            }
        }
        "register" {
            global nickserv_host nickserv_auth_needed
            if {[isignore "*!*@$nickserv_host"]==1} {
                killignore "*!*@$nickserv_host";
            }
            set tdata(nick) $nick
            set tdata(pass) [lindex $params 0]
            set tdata(email) [lindex $params 1]
            set tdata(host) $host
            set tnick $nick
            bind NOTC -|- "$nick*" ndata
            if {$nickserv_auth_needed} {
                utimer 5 regerror
                putserv "PRIVMSG nickserv@$nickserv_host :info $nick"
            } else {
                ndata $nick $host $handle $text ""
            }
        }
    }
}