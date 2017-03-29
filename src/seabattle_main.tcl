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
# This is where the evil TCL code starts, read at your peril!  #
################################################################

set spath [file dirname [info script]]

source [file join $spath "seabattle_config.tcl"]
foreach varname [list "qstat_flag" "botpass" "skystats_max" "skystats_i" "sqluser" "sqlpass" "sqlhost" "sqldb" "language"] {
    if {![info exists $varname]} {
        puts "$varname in seabattle_config.tcl is not defined"
        exit 2
    }
}

source [file join $spath "translations/$language.tcl"]
foreach varname [list "msg_dontunderstand" "commands_alias" "translation"] {
    if {![info exists $varname]} {
        puts "$varname in translations/$language.tcl is not defined"
        exit 3
    }
}

set mpath "$spath/tcllibs/"

if { [file exists "$mpath/libmysqltcl3.02.so"] } {
	package ifneeded mysqltcl \
		[list load [file join $mpath libmysqltcl3.02.so] mysqltcl]
} 
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
	mysqlendquery $result
	set first [string range $row 0 0]
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
	putlog "-> $nick $event "
	set sql "UPDATE `Users` SET `Command` = '$event' WHERE `Nick` = '$nick' LIMIT 1 ;"
	set rez [mysqlexec $db_handle $sql]
}

proc multiline_translated_say { ni lang_string } {
    global translation
    foreach line $translation($lang_string) { 
        putquick "PRIVMSG $ni :$line"
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

proc lang_str { kind } {
    global translation
    return $translation($kind)
}

proc pub:admin_commands { nick host handle chan text } {
	global db_handle
	if {[is_identified $nick $host]==0} {
		say_unknown $nick
		return 0;
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
			say "error" $nick $chan "Išjungiamas botas..."
            die $params
		}
		"channels" {
			set command [lindex $text 1]
			set chan2 [lindex $text 2]
			switch [string tolower $command] {
                "add" {
                    say "error" $nick $chan "Pridėtas kanalas $chan2"
                    channel add $chan2
                }
                "remove" {
                    say "error" $nick $chan "Pašalintas iš kanalo $chan2"
                    channel remove $chan2
                }		
                "info" {
                	set rez [channel info $chan2]
                	say "error" $nick $chan "Informacija apie kanalą $chan2: $rez"
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
                        set sql "INSERT INTO `Users` ( `Nick` , `Admin` ) VALUES ('$user', 'true');"
                        set rez [mysqlexec $db_handle $sql]
                    } else {
                        set sql "UPDATE `Users` SET `Admin` = 'true' WHERE `ID` = '$id' LIMIT 1 ;"
						set rez [mysqlexec $db_handle $sql]
                    }
					say "error" $nick $chan "Vartotojas $user gavo administratoriaus teises!"
                }
                "is" {
                    if {[isadmin $user]} {
                        say "error" $nick $chan "$user turi administratoriaus teises"
                    } else {
                        say "error" $nick $chan "$user neturi administratoriaus teisiu"
                    }
                }
                "remove" {
                    set id [mysql_getcell "Users" "id" "nick = '$user'"] 
                    if { [string trim $id] == "" } {
                    	say "error" $nick $chan "Nėra tokio vartotojo!"
                    } else {
                        set sql "UPDATE `Users` SET `Admin` = 'false' WHERE `ID` = '$id' LIMIT 1 ;"
                        set rez [mysqlexec $db_handle $sql]
                        say "error" $nick $chan "$user jau nebe administratorius! :)"
                    }
                }
                "list" {
					say "error" $nick $chan "\Administratorių sąrašas:"
                    set sql "SELECT nick FROM `Users` WHERE admin ='true';"
                    set query1 [mysqlquery $db_handle $sql]
                    set i [expr int(0)]
					set is 0
					while {[set row [mysqlnext $query1]]!=""} {
                        set i [expr $i+1]
                        set is 1
                        say "error" $nick $chan "$i\.\ $row"
                    }
                    if {$is==0} {
                    	say "error" $nick $chan "(nėra RSS'ų)"
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
                set sql "INSERT INTO `Help` ( `Item` , `Description`, `Syntax` ) VALUES ('$item', '$description','$syntax');"
				set rez [mysqlexec $db_handle $sql]
			} else {
                set sql "UPDATE `Help` SET `Description` = '$description' WHERE `ID` = '$id' LIMIT 1 ;"
				set rez [mysqlexec $db_handle $sql]
                set sql "UPDATE `Help` SET `Syntax` = '$syntax' WHERE `ID` = '$id' LIMIT 1 ;"
				set rez [mysqlexec $db_handle $sql]
			}
			say "error" $nick $chan "Atnaujinta pagalba"
		}
		"delhelp" {
			set item [lindex $text 1 end]
			set id [mysql_getcell "Help" "id" "item = '$item'"] 
			if { [string trim $id] == "" } {
                say "error" $nick $chan "Negalima buvo pasalinti ish komandu sarasho shio irasho."
			} else {
				set sql "DELETE FROM `Help` WHERE `ID` = '$id';"
				set rez [mysqlexec $db_handle $sql]
				say "error" $nick $chan "Atnaujinta pagalba"
			}
		}
		"set" {
			set item [lindex $text 1]
			set value [lrange $text 2 end]
			set id [mysql_getcell "settings" "id" "setting = '$item'"] 
			if { [string trim $id] == "" } {
                set sql "INSERT INTO `settings` ( `Setting` , `Value` ) VALUES ('$item', '$value');"
				set rez [mysqlexec $db_handle $sql]
			} else {
                set sql "UPDATE `settings` SET `Value` = '$value' WHERE `ID` = '$id' LIMIT 1 ;"
				set rez [mysqlexec $db_handle $sql]
			}
			say "error" $nick $chan "Atnaujinti boto nustatymai"
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
		say "error" $nick $chan "Sintaksė: \$text $syntax"
		say "error" $nick $chan [emptyline]
		say "error" $nick $chan "$description"
		set sql "SELECT id FROM `Help` WHERE item LIKE '$text %';"
	}
	if {![info exists sql]} {
		say "error" $nick $chan "Deja šiuo metu dar nėra pagalbos apie šią galimybę :("
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
            set le 0;
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

proc pub:private_chat { nick host handle text } {
	global db_handle msg_dontunderstand botnick
	set id [mysql_getcell "Users" "id" "nick = '$nick'"] 
	if {[string trim $id]==""} {
		if {[is_good_command msg $text]==1} {
            return 0;
		}
		say "error" $nick $nick "Siūlyčiau tau pirma užsiregistruoti... :)"
		say "error" $nick $nick "Norėdamas užsiregistruoti rašyk: /MSG $botnick USER REGISTER slaptažodis tavo@e-pastas.lt"
		return 0;
	}
	set txt [mysql_getcell "Users" "command" "nick = '$nick'"]
	set cmd [lindex $txt 0]
	switch [string tolower $cmd] {
        "enterpass" {
            set pass [mysql_getcell "Users" "password" "nick = '$nick'"] 
            if { $pass == $text } {
                set sql "UPDATE `Users` SET `Host` = '$host' WHERE `ID` = '$id' LIMIT 1 ;"
                set rez [mysqlexec $db_handle $sql]
                putquick "PRIVMSG $nick :Ačiū, kad priminei man, kas tu. :)"
                WaitEvent $nick ""
                return 1;
            } else {
                putquick "PRIVMSG $nick :Jaučiu, kad tu mane bandai išdurti... :("
                putquick "PRIVMSG $nick :Įveskite slaptažodį:"
            }
		}
		"agree" {
            set player [lindex $txt 1]
            set game [lindex $txt 2]
            if {[string equal -nocase $text "ne"]==1} {	    
                say "game" $player $player "$nick nepanoro žaisti su jumis $game"
                WaitEvent $nick ""
                WaitEvent $player ""
                return 1;
            }
            if {[string equal -nocase $text "taip"]==1} {
                say "game" $player $player "$nick sutiko žaisti su tavimi"
                say "game" $player $player "Tuoj pradėsime žaidimą..."
				say "game" $nick $nick "Tuoj pradėsime žaidimą..."
                WaitEvent $nick ""
				WaitEvent $player ""
                putlog toliau
                PlayBegin $game $nick $player
                putlog toliaua
                return 1;
            }
			say "game" $nick $nick "Aš tavęs nesuprantu, tam aš per galbūt per kvailas... :("
			say "game" $nick $nick "Rašyk Taip arba Ne"
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
			say "error" $nick $chan "Siūlyčiau tau pirma užsiregistruoti... :)"
				say "error" $nick $nick "Norėdamas užsiregistruoti rašyk: /MSG $nick USER REGISTER slaptažodis tavo@e-pastas.lt"
				return 0;
			}
			set host [mysql_getcell "Users" "host" "id = '$id'"] 
			if {[string trim $host]==""} {
				say "error" $nick $chan "Siūlyčiau Jums pirmiausia prisijungti... :)"
				return 0;
			}
			set sql "UPDATE `Users` SET `Host` = '' WHERE `ID` = '$id' LIMIT 1 ;"
			set rez [mysqlexec $db_handle $sql]
			say "error" $nick $chan "Ką tik jūs atsijungėte"
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
					say "error" $nick $chan "Pakeistas Jūsų slaptažodis: $oldpass į $value."
				}
				"email" {
					set id [mysql_getcell "Users" "id" "nick = '$nick'"] 
					set email [mysql_getcell "Users" "`E-Mail`" "id = '$id'"] 
					set sql "UPDATE `Users` SET `E-Mail` = '$value' WHERE `ID` = '$id' LIMIT 1 ;"
                    set rez [mysqlexec $db_handle $sql]
					say "error" $nick $chan "Pakeistas Jūsų elektroninės pašto dežutės adresas: $email į $value."
				}
				default {
					say "error" $nick $chan "Nėra galimybės keisti šį nustatymą"
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
	if {$tdata(nick)==""} {return;}
	set nick $tdata(nick)
    say "error" $nick $nick "Tu nesi užsiregistravęs(-iusi) savo nick'o IRC serveryje"
	say "error" $nick $nick "Todėl aš tikrai nenoriu tavęs užregistruoti savo duomenų bazėje tol, kol tu neužsiregistruosi IRC serveryje."
	say "error" $nick $nick "Tai tu gali padaryti parašęs(-iusi) komandą: /MSG NICKSERV REGISTER slaptazodis tavo@email'as.lt"
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
            say "error" $nick $chan "Toks vartotojas jau egzistuoja!"
            return 0;
		}
		set sql "INSERT INTO `Users` ( `ID` , `Nick` , `Admin` , `Host` , `Password` , `E-Mail` , `LastLogged` ) "
		append sql "VALUES ("
		append sql "'', '$nick', 'false', '$host', '$pass', '$email', ''"
		append sql ");"
		set rez [mysqlexec $db_handle $sql]
		set txt "Jūs ką tik užsiregistravote!\n"
		append txt [emptyline]
		append txt "\n"
		append txt "Jūsų slaptažodis: "
		append txt [boldtext $pass]
		append txt "\n"
		append txt "Jūsų elektroninio pašto adresas: "
		append txt [boldtext $email]
		append txt "\n"
		append txt [emptyline]
		append txt "\n"
		append txt " Prisiminkite savo slaptažodį arba bent jau elektrinio pašto adresą, \nkad galėtūmėte užmiršus paklausti slaptažodžio."
		say "error" $nick $chan $txt
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

proc autoend {} {
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
		say "error" $player2 $player2  "Kadangi žaidėjas $nick išėjo iš mano sėdimų kanalų, nutraukiu žaidimą"
		say "error" $nick $nick "Kadangi jūs išėjote iš mano sėdimų kanalų, žaidimas yra nutraukiamas"
		say "error" $nick $nick "Žaidėjas $player2 labai liūdi dėl to, tačiau tikisi, kad kitą kartą pabaigsite žaidimą :)"     
		DoSQL "DELETE FROM TodoList WHERE Arguments = '$dothiscommand' AND Command = 'CheckIfAutoEnd' LIMIT 1;"
		DoSQL "UPDATE `Users` SET StatNA = StatNA + 1 WHERE `Nick` = '$nick' LIMIT 1 ;"
		DoSQL "UPDATE `Users` SET StatNA = StatNA + 1 WHERE `Nick` = '$player' LIMIT 1 ;"
		WaitEvent $nick ""
		WaitEvent $player2 ""
		return;
	}
	if {[onchan $player2]==0} {
		say "error" $nick $nick "Kadangi žaidėjas $player2 išėjo iš mano sėdimų kanalų, nutraukiu žaidimą"
		say "error" $player2 $player2"Kadangi jūs išėjote iš mano sėdimų kanalų, žaidimas yra nutraukiamas"
		say "error" $player2 $player2 "Žaidėjas $nick labai liūdi dėl to, tačiau tikisi, kad kitą kartą pabaigsite žaidimą :)"     
		DoSQL "DELETE FROM TodoList WHERE Arguments = '$dothiscommand' AND Command = 'CheckIfAutoEnd' LIMIT 1;"
		DoSQL "UPDATE `Users` SET StatNA = StatNA + 1 WHERE `Nick` = '$nick' LIMIT 1 ;"
		DoSQL "UPDATE `Users` SET StatNA = StatNA + 1 WHERE `Nick` = '$player' LIMIT 1 ;"
		WaitEvent $nick ""
		WaitEvent $player2 ""
		return;
	}
	set lastaction1 [mysql_getcell "Users" "LastAction" "Nick = '$nick'"] 
	set lastaction2 [mysql_getcell "Users" "LastAction" "Nick = '$player2'"] 
	set ct(hrs) [clock format [clock seconds] -format %H]
	set ct(min) [clock format [clock seconds] -format %M]
	set ct(sec) [clock format [clock seconds] -format %S]
	set laikas [expr $ct(hrs)*3600+$ct(min)*60+$ct(sec)]
	DoSQL "DELETE FROM TodoList WHERE Arguments = '$dothiscommand' AND Command = 'CheckIfAutoEnd' LIMIT 1;"
	if {$laikas>[expr $lastaction1+960]} {
		say "error" $nick $nick "Žaidimas buvo automatiškai nutrauktas, nes jūs nedarėte jokių veiksmų pastarasias 5 minutes"
		say "error" $player2 $player2 "Žaidimas buvo automatiškai nutrauktas, nes jūsų priešininkas neatliko jokių veiksmų per pastarasias 5 minutes."
		DoSQL "UPDATE `Users` SET StatNA = StatNA + 1 WHERE `Nick` = '$nick' LIMIT 1 ;"
		DoSQL "UPDATE `Users` SET StatNA = StatNA + 1 WHERE `Nick` = '$player' LIMIT 1 ;"
		WaitEvent $nick ""
		WaitEvent $player2 ""
		return;
	}
	if {$laikas>[expr $lastaction2+960]} {
		say "error" $player2 $player2  "Žaidimas buvo automatiškai nutrauktas, nes jūs nedarėte jokių veiksmų pastarasias 5 minutes"
		say "error" $nick $nick "Žaidimas buvo automatiškai nutrauktas, nes jūsų priešininkas neatliko jokių veiksmų per pastarasias 5 minutes."
		DoSQL "UPDATE `Users` SET StatNA = StatNA + 1 WHERE `Nick` = '$nick' LIMIT 1 ;"
		DoSQL "UPDATE `Users` SET StatNA = StatNA + 1 WHERE `Nick` = '$player' LIMIT 1 ;"
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
			say "error" $nick $chan "Tu nesi užsiregistravęs duomenų bazėje"
            say "error" $nick $chan "Todėl aš negaliu rodyti tavo statistikos... :("
            return
		} 
		say "error" $nick $chan "Tavo statistika"
		set user $nick
	} else {
		set user [lindex $text 0]
		if {[db_count "Users" "Nick = '$user'"]<1} {
            say "error" $nick $chan "$user vartotojas nėra užsiregistravęs mano duomenų bazėje"
            say "error" $nick $chan "Todėl aš negaliu rodyti jo statistikos... :("
            return
        } 
		say "error" $nick $chan "$user statistika"
	}
	set won [mysql_getcell "Users" "StatWon" "Nick = '$user'"] 
	set lost [mysql_getcell "Users" "StatLost" "Nick = '$user'"] 
	set na [mysql_getcell "Users" "StatNA" "Nick = '$user'"] 
	say "error" $nick $chan "----------------------------------"
	say "error" $nick $chan "Laimėti žaidimai: $won"
	say "error" $nick $chan "Pralaimėti žaidimai: $lost"
	say "error" $nick $chan "Nepabaigti žaisti žaidimai: $na"
	say "error" $nick $chan "Iš viso žaista: [expr $na+$won+$lost]"
	say "error" $nick $chan "----------------------------------"
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
		say "error" $nick $chan "Prašome pasirinkti vieną iš šių žaidimų:$games"
		return 0;
	}

	if {$player2==""} {
		say "error" $nick $chan "Galėtum dar nurodyti su kuo nori žaisti $game (pvz. !play $game $botnick)"
		return 0;
	}

	if {[string equal -nocase $player2 $botnick]==1} {
		say "error" $nick $chan "Ačiū už pasiūlymą, bet aš esu tik durnas botas... ;)"
		return 0;
	}

	if {[string equal -nocase $player2 $nick]==1} {
		say "error" $nick $chan "Atleisk, bet tu negali žaisti prieš save... ;)"
		return 0;
	}

	if {[onchan $nick]==0} {
		say "error" $nick $chan "Tu nesėdi nei viename iš mano sėdimų kanalų"
		say "error" $nick $chan "Todėl aš nenoriu, kad jis dalyvautu šiame žaidime"
		return
	}

	if {[onchan $player2]==0} {
		say "error" $nick $chan "Žaidėjas(-a) $player2 nėra nei viename iš mano sėdimų kanalų"
		say "error" $nick $chan "Todėl aš nenoriu, kad jis dalyvautu šiame žaidime"
		return
	}

	if {[string equal -nocase [mysql_getcell "Users" "Command" "nick = '$player2'"] ""]==0} {
		say "error" $nick $chan "Žaidėjas(-a) $player2 dabar yra užimtas (žaidžiama kita partija)"
		return;
	}

	if {[string equal -nocase [mysql_getcell "Users" "Command" "nick = '$nick'"] ""]==0} {
		say "error" $nick $chan "Jūs pats dabar žaidžiate kitą partiją!"
		say "error" $nick $chan "Žaisti kelias partijas iškarto tikrai aš neleisiu!"
		return;
	}

	set count [db_count "Users" "nick = '$player2'"]
	if {$count<1} {
		set msg "$nick siūlo tau sužaisti $game\n"
		append msg "Tačiau tu neregistruotas mano duomenų bazėje... :(\n"
		append msg "Gal norėtum užsiregistruoti?\n"
		append msg "Tuomet rašyk: /MSG $botnick USER REGISTER slaptažodis tavo@e-pastas.lt"
		say "game" $player2 $chan $msg
		set msg "$player2 nėra registruotas žaidėjas mano duomenų bazėje\n"
		append msg "Kad galėtum su juo žaisti, jis turi užsiregistruoti"
		say "game" $nick $chan $msg
		return 0;
	}

	say "game" $nick $chan "Pasirinktas žaidimas: $game"
	say "game" $nick $chan "Norima žaisti su $player2"
	say "game" $nick $chan "Laukiama atsakymo..."
	WaitEvent $player2 "wagree $player2 $game"

	say "game" $player2 $chan "$nick siūlo tau sužaisti $game"
	say "game" $player2 $chan "Ar sutinki (Taip arba Ne)?"
	WaitEvent $player2 "agree $nick $game"
}

set grid_width [list g a m e s]
set grid_height [list 1 2 3 4 5]
set ship_count 5

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
	set ct(hrs) [clock format [clock seconds] -format %H]
	set ct(min) [clock format [clock seconds] -format %M]
	set ct(sec) [clock format [clock seconds] -format %S]
	set laikas [expr $ct(hrs)*3600+$ct(min)*60+$ct(sec)]
	DoSQL "UPDATE `Users` SET LastAction = '$laikas' WHERE `Nick` = '$nick' LIMIT 1 ;"
	DoSQL "DELETE FROM TodoList WHERE Command = 'CheckIfAutoEnd' AND Arguments LIKE '% $nick';" 
	DoSQL "DELETE FROM TodoList WHERE Command = 'CheckIfAutoEnd' AND Arguments LIKE '$nick %';" 
	DoSQL "INSERT INTO `TodoList` ( `ID` , `Command` , `Arguments`)  VALUES ( '', 'CheckIfAutoEnd', '$nick $player');" 
	set textp [string tolower $text]
	if {[info exists commands_alias($textp)]==1} {set textp $commands_alias($textp);}
	switch [string tolower $textp] {
		"!map" {
			if {[string equal -nocase "shoot" $command]==0} {
                return;
            }
			set msg "Štai taip dabar atrodo jūsų žemėlapis:"
			say "game" $nick $nick $msg
			DrawGrid2 $nick	    
			say "game" $nick $nick "Nurodykite koordinates:"
			return
		}
		"!map2" {
			if {[string equal -nocase "shoot" $command]==0} {
                return;
            }
			set msg "Štai taip dabar atrodo priešininko žemėlapis:"
			say "game" $nick $nick $msg
			DrawGrid3 $nick $player
			say "game" $nick $nick "Nurodykite kordinates:"
			return
		}
		"!map3" {
			if {[string equal -nocase "shoot" $command]==0} {
                return;
            }
			set msg "Štai taip dabar atrodo jūsų žemėlapis:"
			say "game" $nick $nick $msg
			DrawGrid2 $nick
			set msg "Štai taip dabar atrodo priešininko žemėlapis:"
			say "game" $nick $nick $msg
			DrawGrid3 $nick $player
			say "game" $nick $nick "Nurodykite kordinates:"
			return
		}
		"!end" {
			WaitEvent $nick ""
			WaitEvent $player ""
			DoSQL "DELETE FROM Seabattle WHERE (Nick = '$nick') OR (Nick = '$player');" 
			DoSQL "DELETE FROM TodoList WHERE Command = 'CheckIfAutoEnd' AND Arguments LIKE '% $nick';" 
			DoSQL "DELETE FROM TodoList WHERE Command = 'CheckIfAutoEnd' AND Arguments LIKE '$nick %';" 
			DoSQL "UPDATE `Users` SET StatNA = StatNA + 1 WHERE `Nick` = '$nick' LIMIT 1 ;"
			DoSQL "UPDATE `Users` SET StatNA = StatNA + 1 WHERE `Nick` = '$player' LIMIT 1 ;"
			say "game" $nick $nick "$player labai nesinori užbaigti partijos, bet ka jau darysi...\nIki kito karto!"
			say "game" $player $player "$nick nebenori toliau žaisti\nNutrauktas žaidimas"
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
				say "game" $nick $nick "Klaida: blogai nurodytos kordinatės ($coll$row)"
                if {$arg!="l"} {
                    say "game" $nick $nick "Nurodykite kordinates:"
                }
                return 0;
			}
			if {[lsearch $grid_height $row]==-1} {
				say "game" $nick $nick "Klaida: blogai nurodytos kordinatės ($coll$row)"
                if {$arg!="l"} {
                    say "game" $nick $nick "Nurodykite kordinates:"
                }
                return 0;
			}
			set count [db_count "Seabattle" "nick = '$nick' and value = '1'"]
			set val [mysql_getcell "Seabattle" "value" "nick ='$nick' and row = '$row' and collumn = '$coll'"]
			if {$val!="0"} {
                say "game" $nick $nick "Jau kažkoks laivas yra pastatytas tame langelyje ($coll$row)"
                if {$arg!="l"} {
                    say "game" $nick $nick "Nurodykite kordinates:"
                }
                return 0;
			}   	 
			set id [mysql_getcell "Seabattle" "id" "nick ='$nick' and row = '$row' and collumn = '$coll'"]
			DoSQL "UPDATE Seabattle SET `Value` = '1' WHERE `ID` = '$id' LIMIT 1 ;"
			say "game" $nick $nick "Ką tik jūs pastatėte [expr $count+1]-ąjį savo laivelį ($coll$row)"
			if {$count<$ship_count} {
                if {$arg!="l"} {
                    say "game" $nick $nick "Nurodykite [expr $count+2]-ojo laivo kordinates:"
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
                set msg "Štai taip dabar atrodo jūsų žemėlapis:"
                say "game" $nick $nick $msg
                DrawGrid $data $nick
                switch $cmd {
                    "waituntilplace" {
                        WaitEvent $player "shoot $nick $game"
                        set msg "Dabar galite pradėti šaudyti laivus!\n"
                        append msg "Nurodykite kordinates, kur reikės šauti (pvz. [boldtext {a 2}]):"
                        say "game" $player $player $msg
                        WaitEvent $nick "waitshoot $player $game"
                        set msg "Greitai galėsite pradėti šaudyti laivelius!\n"
                        append msg "Tačiau dabar turite palaukti kol šaus $player"
                        say "game" $nick $nick $msg
                    }
                    default {
                        WaitEvent $nick "waituntilplace $nick $game"
                        say "game" $nick $nick "Palaukite kol $player susistatys laivus..."
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
				say "game" $nick $nick "Klaida: blogai nurodytos kordinatės ($coll$row)"
                if {$arg!="l"} {
                    say "game" $nick $nick "Nurodykite kordinates:"
                }
                return 0;
			}
			if {[lsearch $grid_height $row]==-1} {
                say "game" $nick $nick "Klaida: blogai nurodytos kordinatės ($coll$row)"
                if {$arg!="l"} {
                    say "game" $nick $nick "Nurodykite kordinates:"
                }
                return 0;
			}
			set val [mysql_getcell "Seabattle" "value" "nick ='$player' and row = '$row' and collumn = '$coll'"]	    
			switch $val {
				"1" {
                    say "game" $player $player "$nick šovė į $coll$row"
                    say "game" $player $player "Pataikė į ten stovintį laivelį :("
                    DoSQL "UPDATE `Seabattle` SET `Value` = '2' WHERE nick ='$player' and row = '$row' and collumn = '$coll' LIMIT 1 ;"
                    say "game" $nick $nick "Jūs pataikėtėte ir nuskandinote vieną laivelį!"
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
                        say "game" $player $player "Deja, ten buvo paskutinis jūsų laivelis :("
                        say "game" $player $player "Kad jums būtų ramiau gyventi, parodysiu $nick žemėlapį:"
                        DrawGrid $data $player
                        say "game" $player $player "$nick laimėjo mūšį"
                        DoSQL "UPDATE `Users` SET StatWon = StatWon + 1 WHERE `Nick` = '$nick' LIMIT 1 ;"
                        DoSQL "UPDATE `Users` SET StatLost = StatLost + 1 WHERE `Nick` = '$player' LIMIT 1 ;"
                        say "game" $nick $nick "Sveikiname su pergale!"
                        return 0;
                    } else {
                        set count [db_count "Seabattle" "nick = '$player' and value = '1'"]
                        say "game" $player $player "$count laiveliai liko"
                        say "game" $nick $nick "$count laiveliai liko"
                    }
                    say "game" $nick $nick "Nurodykite kordinates:"
                }
                "0" {
                    say "game" $player $player "$nick šovė į $coll$row"
                    say "game" $player $player "Bet ten nebuvo jokio laivelio... :)"
					say "game" $nick $nick "Jūs prašovėte... :("
                    DoSQL "UPDATE `Seabattle` SET `Value` = '3' WHERE nick ='$player' and row = '$row' and collumn = '$coll' LIMIT 1 ;"
                    WaitEvent $nick "waitshoot $player $game"
                    WaitEvent $player "shoot $nick $game"
                    say "game" $player $player "Nurodykite kordinates:"
                }
                "3" {
                    say "game" $player $player "Kreivos rankos neklauso $nick galvos... :)\nDabar galite nurodyti kordinates, kur šauti:"
                    say "game" $nick $nick "$player dėkoja už perleistą ėjimą..."
                    WaitEvent $nick "waitshoot $player $game"
                    WaitEvent $player "shoot $nick $game"
                }
                "2" {
                    say "game" $nick $nick "Jau kartą esatę čia pataikęs(-iusi)..."
                    say "game" $nick $nick "Nurodykite kordinates:"
                }
			}
		} 
	}
}

proc PlayGameInfo_Start { game nick } {
	global grid_width grid_height
	switch [string tolower $game] {
		"seabattle" {
			set msg "seabattle - tai seno gero žaidimo Jūrų Mūšis irc versija\n"
			append msg "Jei nesuprantate kaip žaisti šį žaidimą, pasinaudokite pagalbos sistema\n"
			append msg [emptyline]
			append msg "\Norėdami nutraukti žaidimą bet kada parašykite \!end\ lange, kur vyksta žaidimas, arba kurį laiką tiersiog jo nežaiskite - žaidimas bus nutrauktas automatiškai."
			append msg [emptyline]
			append msg "Dabar Jūs turite išstatyti savo jūrų kariauną\n"
			append msg "Tai jūs galite padaryti, rašydami kordinates, kuriame langelyje jūs norite pastatyti laivelį\n"
			append msg "Štai jums žemėlapis, kad būtų lengviau:"
			say "game" $nick $nick $msg
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
	DoSQL "DELETE FROM `Seabattle` WHERE `Nick` = '$nick';"
	DoSQL "DELETE FROM `Seabattle` WHERE `Nick` = '$player';"
	foreach y $grid_height {
		foreach x $grid_width {
            DoSQL "INSERT INTO `Seabattle` ( `ID` , `Nick` , `Row` , `Collumn` , `Value` )  VALUES ( '', '$nick', '$y', '$x', '0');" 
            DoSQL "INSERT INTO `Seabattle` ( `ID` , `Nick` , `Row` , `Collumn` , `Value` )  VALUES ( '', '$player', '$y', '$x', '0');" 
		}
	}
	PlayGameInfo_Start $game $nick
	say "game" $nick $nick "Nurodykite kordinates (pvz. \a 1\):"
	WaitEvent $nick "place $player $game"
	PlayGameInfo_Start $game $player
	say "game" $player $player "Nurodykite kordinates (pvz. \a 1\):"
	WaitEvent $player "place $nick $game"  
}

set my_games [string map {"Game_" ""} [info commands "Game_*"]]
###################################################################################
