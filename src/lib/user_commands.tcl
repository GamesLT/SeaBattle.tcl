namespace eval UserCommands {
    namespace export handle
}

proc ::UserCommands::handle { nick host handle text  } {
    set command [lindex $text 0]
    set params [lrange $text 1 end]
    switch [string tolower $command] {
        "logout" {
            return [::UserCommands::logout $nick $nick]
        }
        "set" {
            return [::UserCommands::setData $nick $params $nick]
        }
        "register" {
            return [::UserCommands::register $nick $params $host $handle $text]
        }
    }
}

proc ::UserCommands::logout { nick chan } {
    set id [::DB::getcell "Users" "id" "nick = '$nick'"] 
    if {[string trim $id]==""} {
        ::Language::say "error" $nick $nick "you_should_register_first"
        return 0;
    }
    set host [::DB::getcell "Users" "host" "id = '$id'"] 
    if {[string trim $host]==""} {
        ::Say::default "error" $nick $chan [::Language::str "please_login"]
        return 0;
    }
    set sql "UPDATE `Users` SET `Host` = '' WHERE `ID` = '$id' LIMIT 1 ;"
    set rez [::DB::exec $sql]
    ::Say::default "error" $nick $chan [::Language::str "logged_out"]
    return 1;
}

proc ::UserCommands::setData { nick params chan } {
    set item [lindex $params 0]
    set value [lindex $params 1]
    if {[is_identified $nick $host]==0} {
        ::Say::unknown $nick
        return 0;
    }
    switch [string tolower $item] {
        "password" {
            set id [::DB::getcell "Users" "id" "nick = '$nick'"] 
            set oldpass [::DB::getcell "Users" "password" "id = '$id'"] 
            set sql "UPDATE `Users` SET `Password` = '$value' WHERE `ID` = '$id' LIMIT 1 ;"
            set rez [::DB::exec $sql]
            ::Say::default "error" $nick $chan [::Language::str "changed_password" [list $oldpass $value]]
        }
        "email" {
            set id [::DB::getcell "Users" "id" "nick = '$nick'"] 
            set email [::DB::getcell "Users" "`E-Mail`" "id = '$id'"]
            set sql "UPDATE `Users` SET `E-Mail` = '$value' WHERE `ID` = '$id' LIMIT 1 ;"
            set rez [::DB::exec $sql]
            ::Say::default "error" $nick $chan [::Language::str "changed_email" [list $email $value]]
        }
        default {
            ::Say::default "error" $nick $chan [::Language::str "this_setting_cant_be_changed"]
        }
    }
}

proc ::UserCommands::register { nick params host handle text } {
    global nickserv_host nickserv_auth_needed tdata nickserv_timeout
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
        set tdata(timer_id) [utimer $nickserv_timeout ::UserCommands::regerror]
        putserv "PRIVMSG nickserv@$nickserv_host :info $nick"
    } else {
        ndata "NickServ" $host $handle "$nick is registered" ""
    }
}

proc ::UserCommands::regerror {} {
    global tdata
    if {[info exists tdata(timer_id)]} {
        killutimer $tdata(timer_id)
        unset tdata(timer_id)
    }
    if {$tdata(nick)==""} {
        return;
    }
    set nick $tdata(nick)
    ::Language::say "error" $nick $nick "nickserv_registration_is_must"
    unbind NOTC -|- "$nick*" ndata
}