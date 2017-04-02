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
    "please_select_game" "Prašome pasirinkti vieną iš šių žaidimų: %s"
    "please_select_oponent" "Galėtum dar nurodyti su kuo nori žaisti %s (pvz. !play %s %s)"
    "bot_rejects_game" "Ačiū už pasiūlymą, bet aš esu tik durnas botas... ;)"
    "bot_cant_invite_you" "Atleisk, bet tu negali žaisti prieš save... ;)"
    "you_not_in_my_channels" {
        "Tu nesėdi nei viename iš mano sėdimų kanalų"
        "Todėl aš nenoriu, kad jis dalyvautu šiame žaidime"
    }
    "another_player_not_in_my_channels" {
        "Žaidėjas(-a) %s nėra nei viename iš mano sėdimų kanalų"
        "Todėl aš nenoriu, kad jis dalyvautu šiame žaidime"
    }
    "another_player_now_playing" "Žaidėjas(-a) %s dabar yra užimtas (žaidžiama kita partija)"
    "you_are_playing_other_game" {
        "Jūs pats dabar žaidžiate kitą partiją!"
        "Žaisti kelias partijas iškarto tikrai aš neleisiu!"
    }
    "selected_game_info" {
        "Pasirinktas žaidimas: %s"
        "Norima žaisti su %s"
        "Laukiama atsakymo..."
    }
    "invited_to_game" {
        "%s siūlo tau sužaisti %s"
        "Ar sutinki (Taip arba Ne)?"
    }
    "got_invitation_but_not_registered" {
        "%s siūlo tau sužaisti %s"
        "Tačiau tu neregistruotas mano duomenų bazėje... :("
        "Gal norėtum užsiregistruoti?"
        "Tuomet rašyk: <b>/MSG %s USER REGISTER <i>slaptažodis</i> <i>tavo@e-pastas.lt</i></b>"
    }
    "invited_but_another_player_must_register_first" {
       "%s nėra registruotas žaidėjas mano duomenų bazėje"
       "Kad galėtum su juo žaisti, jis turi užsiregistruoti"
    }
    "seabattle_start_info" {
        "seabattle - tai seno gero žaidimo Jūrų Mūšis irc versija"
        "Jei nesuprantate kaip žaisti šį žaidimą, pasinaudokite pagalbos sistema"
        ""
        "Norėdami nutraukti žaidimą bet kada parašykite <b>!end</b> lange, kur vyksta žaidimas, arba kurį laiką tiersiog jo nežaiskite - žaidimas bus nutrauktas automatiškai."
        ""
        "Dabar Jūs turite išstatyti savo jūrų kariauną"
        "Tai jūs galite padaryti, rašydami kordinates, kuriame langelyje jūs norite pastatyti laivelį"
        "Štai jums žemėlapis, kad būtų lengviau:"
    }
    "yes" "taip"
    "no" "ne"
    "this_is_how_your_map_looks" "Štai taip dabar atrodo jūsų žemėlapis:"
    "this_is_how_oponent_map_looks" "Štai taip dabar atrodo priešininko žemėlapis:"
    "enter_coordinates" "Nurodykite kordinates:"
    "end_iniciated_by_you" {
        "%s labai nesinori užbaigti partijos, bet ka jau darysi..."
        "Iki kito karto!"
    }
    "end_iniciated_by_other_player" {
         "%s nebenori toliau žaisti"
         "Nutrauktas žaidimas"
    }
    "bad_coordinates" "Klaida: blogai nurodytos kordinatės (%s%s)"
    "there_is_alread_a_ship" "Jau kažkoks laivas yra pastatytas tame langelyje (%s%s)"
    "shoot_to" "%s šovė į %s%s"
    "ship_sink" "Pataikė į ten stovintį laivelį :("
    "shoot_good_results" "Jūs pataikėtėte ir nuskandinote vieną laivelį!"
    "that_was_last_ship" "Deja, ten buvo paskutinis jūsų laivelis :("
    "i_will_show_your_opnent_map" "Kad jums būtų ramiau gyventi, parodysiu $nick žemėlapį:"
    "has_won" "%s laimėjo mūšį"
    "congratulations" "Sveikiname su pergale!"
    "ships_count" "%d laiveliai liko"
    "there_was_no_ship" "Bet ten nebuvo jokio laivelio... :)"
    "shoot_bad_results" "Jūs prašovėte... :("
    "already_shooted_here" "Jau kartą esatę čia pataikęs(-iusi)..."
    "oponent_likes_that_you_decided_to_skip" "%s dėkoja už perleistą ėjimą..."
    "bad_hands_doesnt_listens_to_head" {
        "Kreivos rankos neklauso %s galvos...:)"
        "Dabar galite nurodyti kordinates, kur šauti:"
    }
    "wait_for_player_to_places_ships" "Palaukite kol %s susistatys laivus..."
    "you_just_places_a_ship" "Ką tik jūs pastatėte %d-ąjį savo laivelį (%s%s)"
    "enter_coordinates_for_ship" "Nurodykite %d-ojo laivo kordinates:"
    "seabattle_starts_enter_coordinates" {
        "Dabar galite pradėti šaudyti laivus!"
        "Nurodykite kordinates, kur reikės šauti (pvz. <b>a 2</b>):"
    }
    "seabattle_soon_you_will_need_to_shhot_something" {
        "Greitai galėsite pradėti šaudyti laivelius!"
        "Tačiau dabar turite palaukti kol šaus %s"
    }
}