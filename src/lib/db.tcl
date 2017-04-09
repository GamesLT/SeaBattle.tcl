namespace eval DB {
   variable connection

   namespace export count connect getcell try_load exec query next
}

proc ::DB::try_load { mpath } {
    set lib_m_path [file join $mpath "libmysqltcl3.02.so"]
    if { [file exists $lib_m_path] } {
        package ifneeded mysqltcl [list load $lib_m_path mysqltcl]
    }
    package require mysqltcl
}

proc ::DB::log {sql} {
    global log_queries
    if {$log_queries} { 
        putlog "SQL: $sql"
    }
}

proc ::DB::count { table query } {
    set sql "select count(*) as count from $table where $query";
    ::DB::log $sql
    set result [mysqlquery $::DB::connection $sql]
    set row [mysqlnext $result]

    mysqlendquery $result

    return $row
}

proc ::DB::connect { sqlhost sqluser sqlpass sqldb } {
    set ::DB::connection [mysqlconnect -host $sqlhost -user $sqluser -password $sqlpass -db $sqldb]
}

proc ::DB::getcell { table cell where } {
    set sql "select $cell from $table where $where";
    ::DB::log $sql
    set result [mysqlquery $::DB::connection $sql]
    set row [mysqlnext $result]
    set first [string range $row 0 0]

    mysqlendquery $result

    if { $first == "\{" } {
        set row [string range $row 1 end-1]
    }
    return $row
}

proc ::DB::exec { sql } {
    ::DB::log $sql
    return [mysqlexec $::DB::connection $sql]
}

proc ::DB::query { sql } {
    ::DB::log $sql
    return [mysqlquery $::DB::connection $sql]
}

proc ::DB:next { resource } {
    return [mysqlnext $resource]
}