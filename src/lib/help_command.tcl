namespace eval HelpCommand {
   namespace export handle
}

proc ::HelpCommand::handle { nick host handle chan text } {
    if { [string trim $text] == ""} {
        set sql "SELECT id FROM `Help`;"
        ::Say::default "error" $nick $chan [getini "about"]
    }
    set text [string tolower $text]
    set description [::DB::getcell "Help" "description" "item = '$text'"]
    set syntax [::DB::getcell "Help" "syntax" "item = '$text'"]
    if { [string trim $description] == "" } {
        # to tikriausiai nebus :)
    } else {
        set text [string toupper $text]
        ::Say::default "error" $nick $chan [::Language::str "help_syntax" [list $text $syntax]]
        ::Say::default "error" $nick $chan [emptyline]
        ::Say::default "error" $nick $chan "$description"
        set sql "SELECT id FROM `Help` WHERE item LIKE '$text %';"
    }
    if {![info exists sql]} {
        ::Say::default "error" $nick $chan [::Language::str "help_nothing"]
        return 0;
    }
    set query1 [::DB::query $sql]
    set i 0
    while {[set row [::DB:next $query1]]!=""} {
        set id $row
        if {$i==0} {
           ::Say::default "error" $nick $chan [emptyline]
        }
        set i 1
        set item [::DB::getcell "Help" "item" "id = '$id'"]
        set le [expr {[string length $text]+1}]
        if { $le == 1 } {
            set le 0
        }
        set item [string toupper [string range $item $le end]]
        set syntax [::DB::getcell "Help" "syntax" "id = '$id'"]
        set description [::DB::getcell "Help" "description" "id = '$id'"]
        set txt "$item $syntax - $description"
        set cg [string first " " $item]
        if {$cg==-1} {
            ::Say::default "error" $nick $chan $txt
        }
    }
    mysqlendquery $query1
}