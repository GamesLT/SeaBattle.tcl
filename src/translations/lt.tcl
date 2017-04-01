set msg_dontunderstand {
    "?"
    "Aš tavęs nesuprantu... :("
    "Ką tai galėtų reikšti?"
    "What?"
    "Baik mane floodinti!"
    "Nemanau, kad supranti pats ką rašai..."
}

array set commands_alias {
    "rodyti zemelapi" "!map"
    "rodyti zemelapius" "!map3"
    "rodyti priesininko zemelapi" "!map2"
    "zemelapis" "!map"
    "mano zemelapis" "!map"
    "musu zemelapiai" "!map3"
    "zemelapiai" "!map3"
    "priesininko zemelapis" "!map2"
    "pabaigti" "!end"
    "uzbaigti" "!end"
    "pabaiga" "!end"
    "baigti" "!end"
    "baik" "!end"
    "uzbaik" "!end"
}

array set translation {
    "please_register" {
        "Labas!"
        "Deja, aš tavęs nesu matęs... :("
        "Gal norėtum užsiregistruoti?"
        "Tuomet rašyk: <b>/MSG $nick USER REGISTER <i>slaptažodis</i> <i>tavo@e-pastas.lt</i></b>"
    }
    "enter_pass" {
        "Labas!"
        "Man atrodo, kad tu bandai prisidengti man žinomo savininko vardu"
        "Įrodyk, kad ne - įvesk savo slaptažodį:"
    }
    "you_are_not_my_admin" "Tu nesi mano administratorius!"
    "rehashing" "Rehašinama..."
    "restarting" "Restartuojama..."
    "shutdowning" "Išjungiamas botas..."
    "channel_added" "Pridėtas kanalas %s"
    "channel_removed_from" "Pašalintas iš kanalo %s"
    "channel_info" "Informacija apie kanalą %s: %s"
    "user_got_promoted_to_admin" "Vartotojas %s gavo administratoriaus teises!"
    "is_admin" "%s turi administratoriaus teises"
    "is_not_admin" "%s neturi administratoriaus teisių"
    "user_not_found" "Nėra tokio vartotojo!"
    "admin_revoked" "%s jau nebe administratorius! :)"
    "admins_list_start" "<b>Administratorių sąrašas:</b>"
    "admins_list_empty" "Sąrašas tusčias"
    "help_updated" "Atnaujinta pagalba"
    "help_cant_remove" "Negalima buvo pašalinti iš komandų sarašo šio įrašo."
    "help_updated" "Atnaujinta pagalba"
    "bot_settings_updated" "Atnaujinti boto nustatymai"
    "help_syntax" "Sintaksė: <b>%s %s</b>"
    "help_nothing" "Deja šiuo metu dar nėra pagalbos apie šią galimybę :("
    "you_should_register_first" {
        "Siūlyčiau tau pirma užsiregistruoti...:)"
        "Norėdamas užsiregistruoti rašyk: <b>/MSG $botnick USER REGISTER <i>slaptažodis</i> <i>tavo@e-pastas.lt</i></b>"
    }
    "thanks_fo_reminding" "Ačiū, kad priminei man, kas tu. :)"
    "do_yoooou_try_to_cheat_me" "Jaučiu, kad tu	mane bandai išdurti... :("
    "enter_pass2" "Įveskite slaptažodį:"
    "rejected_invitation" "%s nepanoro žaisti su jumis %s"
    "accepted_invitation" "%s sutiko žaisti su tavimi"
    "game_will_start_soon" "Tuoj pradėsime žaidimą..."
    "i_cant_understand" "Aš tavęs nesuprantu, tam aš per galbūt per kvailas... :("
    "write_yes_or_no" "Rašyk Taip arba Ne"
    "please_login" "Siūlyčiau Jums pirmiausia prisijungti... :)"
    "logged_out" "Ką tik jūs atsijungėte"
    "changed_password" "Pakeistas Jūsų slaptažodis: %s į %s."
    "changed_email" "Pakeistas Jūsų elektroninės pašto dežutės adresas: %s į %s."
    "this_setting_cant_be_changed" "Nėra galimybės keisti šį nustatymą"
    "nickserv_registration_is_must" {
        "Tu nesi užsiregistravęs(-iusi) savo nick'o IRC serveryje"
        "Todėl aš tikrai nenoriu tavęs užregistruoti savo duomenų bazėje tol, kol tu neužsiregistruosi IRC serveryje."
        "Tai tu gali padaryti parašęs(-iusi) komandą: <b>/MSG NICKSERV REGISTER <i>slaptazodis</i> <i>tavo@email'as.lt</i></b>"
    }
    "such_user_exists" "Toks vartotojas jau egzistuoja!"
    "registration_msg" {
        "Jūs ką tik užsiregistravote!"
        ""
        "<b>Jūsų slaptažodis:</b>"
        "%s"
        "<b>Jūsų elektroninio pašto adresas:</b>"
        "%s"
        ""
        " Prisiminkite savo slaptažodį arba bent jau elektroninio pašto adresą, kad galėtųmėte užmiršus paklausti slaptažodžio."
    }
    "other_player_quited" "Kadangi žaidėjas %s išėjo iš mano sėdimų kanalų, nutraukiu žaidimą"
    "you_quited" {
        "Kadangi jūs išėjote iš mano sėdimų kanalų, žaidimas yra nutraukiamas"
        "Žaidėjas %s labai liūdi dėl to, tačiau tikisi, kad kitą kartą pabaigsite žaidimą :)"
    }
    "other_player_left_channel" "Kadangi žaidėjas %s išėjo iš mano sėdimų kanalų, nutraukiu žaidimą"
    "you_left_channel" {
        "Kadangi jūs išėjote iš mano sėdimų kanalų, žaidimas yra nutraukiamas"
        "Žaidėjas %s labai liūdi dėl to, tačiau tikisi, kad kitą kartą pabaigsite žaidimą :)"
    }
    "game_canceled_because_you_idled" "Žaidimas buvo automatiškai nutrauktas, nes jūs nedarėte jokių veiksmų pastarasias 5 minutes"
    "game_canceled_because_other_player_not_moved" "Žaidimas buvo automatiškai nutrauktas, nes jūsų priešininkas neatliko jokių veiksmų per pastarasias 5 minutes."
    "cant_show_stats" {
        "Tu nesi užsiregistravęs duomenų bazėje"
        "Todėl aš negaliu rodyti tavo statistikos... :("
    }
    "your_stats" "Tavo statistika"
    "cant_show_stats_for" {
        "%s vartotojas nėra užsiregistravęs mano duomenų bazėje"
        "Todėl aš negaliu rodyti jo statistikos... :("
    }
    "user_stats" "%s statistika"
    "stats_data" {
        "----------------------------------"
        "Laimėti žaidimai: %d"
        "Pralaimėti žaidimai: %d"
        "Nepabaigti žaisti žaidimai: %d"
        "Iš viso žaista: %d"
        "----------------------------------"
    }
    "enter_coordinate" "Nurodykite kordinates (pvz.: <i>a 1</i>):"
}