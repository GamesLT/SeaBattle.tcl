namespace eval Say {
    namespace export default unknown
}

proc ::Say::default { md ns chan text } {
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

proc ::Say::unknown { ni } {
    global nick
    set id [::DB::getcell "Users" "id" "nick = '$ni'"]
    if {[string trim $id]==""} {
        global botnick
        ::Language::privmsg $ni "please_register" [list $botnick]
    } else {
        ::Language::privmsg $ni "enter_pass"
        WaitEvent $ni "enterpass"
    }
}