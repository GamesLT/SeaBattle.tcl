namespace eval Language {
   variable translation
   variable commands_alias
   variable msg_dontunderstand

   namespace export load str privmsg say
}

proc ::Language::load { spath language } {
    set filename [file join $spath "translations" "$language.ini"]
    set handle [open $filename r]
    set ::Language::data [dict create]
    set cat ""
    set ::Language::translation [dict create]
    set ::Language::commands_alias [dict create]
    set ::Language::msg_dontunderstand [dict create]
    set cdict [dict create]
    while {![eof $handle]} {
        set line [gets $handle]
        if {[::Language::isCategory $line]} {
            set sl [string length $line]
            set sl [expr {$sl-2}]
            set cat [string range $line 1 $sl]
            continue
        } 
        if {[string match "#*" $line] || [string match ";*" $line]} {
            continue
        }
        set index [string first "=" $line]
        set key [string range $line 0 [expr {$index - 1}]]
        set value [string range $line [expr {$index + 1}] end]
        set value [string map {"\\r" "\r" "\\t" "\t" "\\b" "\b" "\\a" "\a" "\\n" "\n" "\\0" "\0" "\\" ""} $value]
        set value [::Language::make_codes_live $value]
        dict append cdict $key $value
    }
    dict append ::Language::data $cat $cdict
}

proc ::Language::isCategory { line } {
    set first [string range $line 0 0]
    set lindex [expr {[string length $line] - 1}]
    set last [string range $line $lindex end]
    if { $first != "\[" } {
        return 0
    }
    if { $last  != "]" } { 
       return 0
    }
    return 1
}

proc ::Language::make_codes_live { text } {
    set ret [regsub -all "<b>(.*?)<\/b>" $text [::Format::bold "\\1"]]
    set ret [regsub -all "<i>(.*?)<\/i>" $ret [::Format::italic "\\1"]]
    set ret [regsub -all "<u>(.*?)<\/u>" $ret [::Format::underline "\\1"]]
    return [regsub -all "<color\[\ ]+(\[^>]+)>(.*?)<\/color>" $ret [::Format::color "\\2" "\\1"]]
}
 
proc ::Language::str { kind {params {}} {return_as_list false} } {
    set ret [dict get [dict get $::Language::data "translation"] "$kind"]
    if { $ret == "" } {
        return [emptyline]
    }
    if {[llength $params] > 0} {
        set ret [format $ret {*}$params]
    }
    if { $return_as_list == true } {
        return [split $ret "\n"]
    } else {
        return $ret
    }
}

proc ::Language::privmsg { ni lang_string {params {}}} {
    foreach line [::Language::str $lang_string $params true] {
        putquick "PRIVMSG $ni :$line"
    }
}

proc ::Language::say { type nick1 nick2 lang_string {params {}}} {
    foreach line [::Language::str $lang_string $params true] {
        say $type $nick1 $nick2 $line
    }
}
