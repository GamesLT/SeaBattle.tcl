namespace eval PrivateChatHandling {
   namespace export handle
}

proc ::PrivateChatHandling::handle { nick host handle text } {
    global botnick
    set id [::DB::getcell "Users" "id" "nick = '$nick'"] 
    if {[string trim $id]==""} {
        if {[is_good_command msg $text]==1} {
            return 0;
        }
        ::Language::say "error" $nick $nick "you_should_register_first"
        return 0;
    }
    set txt [::DB::getcell "Users" "command" "nick = '$nick'"]
    set cmd [lindex $txt 0]
    switch [string tolower $cmd] {
        "enterpass" {
            set pass [::DB::getcell "Users" "password" "nick = '$nick'"] 
            if { $pass == $text } {
                set sql "UPDATE `Users` SET `Host` = '$host' WHERE `ID` = '$id' LIMIT 1;"
                set rez [::DB::exec $sql]
                ::Language::privmsg $nick "thanks_fo_reminding"
                WaitEvent $nick ""
                return 1
            } else {
                ::Language::privmsg $nick "do_yoooou_try_to_cheat_me"
                ::Language::privmsg $nick "enter_pass2"
            }
        }
        "agree" {
            set player [lindex $txt 1]
            set game [lindex $txt 2]
            if {[string equal -nocase $text [::Language::str "no"]]==1} {
                ::Say::default "game" $player $player [::Language::str "rejected_invitation" [list $nick $game]]
                WaitEvent $nick ""
                WaitEvent $player ""
                return 1;
            }
            if {[string equal -nocase $text [::Language::str "yes"]]==1}    {
                ::Say::default "game" $player $player [::Language::str "accepted_invitation" [list $nick]]
                ::Say::default "game" $player $player [::Language::str "game_will_start_soon"]
                ::Say::default "game" $nick $nick [::Language::str "game_will_start_soon"]
                WaitEvent $nick ""
                WaitEvent $player ""
                putlog toliau
                PlayBegin $game $nick $player
                putlog toliaua
                return 1;
            }
            ::Say::default "game" $nick $nick [::Language::str "i_cant_understand"]
            ::Say::default "game" $nick $nick [::Language::str "write_yes_or_no"]
        }
        default {
            set command [lindex $txt 0]
            set game [lindex $txt 2]
            set player [lindex $txt 1]
            PlayGame $command $game $nick $player $text
        }
    }
}