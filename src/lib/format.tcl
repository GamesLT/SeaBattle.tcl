namespace eval Format {
   namespace export bold italic underline color
}

proc ::Format::bold { text } {
    return "\$text\"
}

proc Format::italic { text } {
    return "\$text\"
}

proc Format::underline { text } {
    return "\$text\"
}

proc Format::color { text color } {
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
