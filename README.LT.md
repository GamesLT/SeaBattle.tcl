# Seabattle

![Screenshot](https://raw.githubusercontent.com/GamesLT/SeaBattle.tcl/master/.screenshot.jpg)

### Kas tai yra?

Tai yra skriptas, kuris prideda galimybę žaisti klasikinį [Jūros mūšio](https://en.wikipedia.org/wiki/Battleship_(game)) bet kuriame IRC kanale [Eggdrop](http://www.eggheads.org)/[Windrop](http://windrop.sourceforge.net) botams

Šio skripto galimybės/savybės:
 * Veikia tik tekstiniu režimu
 * Tinklo režimas, kuris gali būti žaidžiamas dviejų žaidėjų
 * Naudoja [MySQL](http://mysql.org) kaip duomenų bazę
 * Integruotos vartotojų registracijos
 * Nickserver palaikymas
 * Daugiakalbystės palaikymas
 
### Kaip įdiegti?

Tam yra keli variantai:

#### 1. Naudokite Docker containerį (rekomenduojama)

[Docker](https://docker.com) yra vienas iš patogiausių įrankių atskiriant procesus bei juos diegiant. Jis sumažina labai galvos skausmą paleidžiant projektus, tačiau norint juo pradėti naudotis reikia pirmiausia pasirūpinti, kad jis būtų įdiegtas.

Norint pasileisti Seabattle žaidimą per Docker'į užtenka įvykdyti šią komandą:
```
docker run -d \
           -e SEABATTLE_DB_USER=seabattle \
           -e SEABATTLE_DB_PASS=seabattle \
           -e SEABATTLE_DB_HOST=hostname \
           -e SEABATTLE_DB_NAME=seabattle \
           gameslt/seabattle.tcl
```

`SEABATTLE_DB_USER`, `SEABATTLE_DB_PASS`, `SEABATTLE_DB_HOST`, `SEABATTLE_DB_NAME` reikia pasikeisti pagal save.

Taip pat galima naudoti ir kitus šio paketo konfiguravimo parametrus. Štai pilnas jų sąrašas:

| Parametras | Reikšmė pagal nutylėjimą | Kam naudojamas? |
| ---------- | ------------------------ | --------------- |
| SEABATTLE_QSTAT_FLAG | . | Buvo naudota ankstesnėse versijose, dabar tik deklaruojamas parametras išlaikyti suderinamumą |
| SEABATTLE_BOT_PASS | botsky | Bot'o slaptažodis |
| **_SEABATTLE_DB_USER_** | | MySQL duomenų bazės vartotojo vardas |
| **_SEABATTLE_DB_PASS_** | | MySQL duomenų bazės vartotojo slaptažodis |
| **_SEABATTLE_DB_HOST_** | | MySQL duomenų bazės serverio adresas |
| **_SEABATTLE_DB_NAME_** | | MySQL duomenų bazės pavadinimas |
| SEABATTLE_LANGUAGE | en | Žaidimo kalba. Gali būti `en` arba `lt` |
| SEABATTLE_GRID_HORIZONTAL_WORD | games | Horizontalus žodis, kuris bus naudojamas langeliams (ženklai turi nesikartoto arba žaidimas gali veikti blogai) |
| SEABATTLE_GRID_VERTICAL_WORD | 12345 | Horizontalus žodis, kuris bus naudojamas langeliams (ženklai turi nesikartoto arba žaidimas gali veikti blogai) |
| SEABATTLE_SHIPS_COUNT | 5 | Po kiek laivų gaus abi pusės? |
| SEABATTLE_NICKSERV_AUTH_NEEDED | false | Ar reikalinga NickServ autentificija pačiam bot'ui? |
| SEABATTLE_NICKSERV_HOST | irc.data.lt | NickServ autentifikacijos hostas |
| SEABATTLE_NICKSERV_TIMEOUT | 5 | Kiek sekundžių laukti NickServ atsakymo dėl autentifikacijos prieš nusprendžiant, kad kažkas nepavyko |
| SEABATTLE_LOG_QUERIES | no | Ar rašyti SQL užklausas? |
| EGGDROP_BOTNET_NICK | SeaBattle | EggDrop'o/WinDrop'o nustatymų *botnet-nick* parametras. Daugiau apie jį galima sužinoti [oficialioje EggDrop dokumentacijoje](http://docs.eggheads.org/coreDocs/core.html). |
| EGGDROP_PROTECT_TELNET | 0 | EggDrop'o/WinDrop'o nustatymų *protect-telnet* parametras. Daugiau apie jį galima sužinoti [oficialioje EggDrop dokumentacijoje](http://docs.eggheads.org/coreDocs/core.html). |
| EGGDROP_DCC_SANITY_CHECK | 0 | EggDrop'o/WinDrop'o nustatymų *dcc-sanitycheck* parametras. Daugiau apie jį galima sužinoti [oficialioje EggDrop dokumentacijoje](http://docs.eggheads.org/coreDocs/core.html). |
| EGGDROP_IDENT_TIMEOUT | 5 | EggDrop'o/WinDrop'o nustatymų *ident-timeout* parametras. Daugiau apie jį galima sužinoti [oficialioje EggDrop dokumentacijoje](http://docs.eggheads.org/coreDocs/core.html). |
| EGGDROP_REQUIRE_PARTY | 0 | EggDrop'o/WinDrop'o nustatymų *require-p* parametras. Daugiau apie jį galima sužinoti [oficialioje EggDrop dokumentacijoje](http://docs.eggheads.org/coreDocs/core.html). |
| EGGDROP_OPEN_TELNETS | 0 | EggDrop'o/WinDrop'o nustatymų *open-telnets* parametras. Daugiau apie jį galima sužinoti [oficialioje EggDrop dokumentacijoje](http://docs.eggheads.org/coreDocs/core.html). |
| EGGDROP_STEALTH_TELNETS | 0 | EggDrop'o/WinDrop'o nustatymų *stealth-telnets* parametras. Daugiau apie jį galima sužinoti [oficialioje EggDrop dokumentacijoje](http://docs.eggheads.org/coreDocs/core.html). |
| EGGDROP_USE_TELNET_BANNER | 0 | EggDrop'o/WinDrop'o nustatymų *use-telnet-banner* parametras. Daugiau apie jį galima sužinoti [oficialioje EggDrop dokumentacijoje](http://docs.eggheads.org/coreDocs/core.html). |
| EGGDROP_CONNECTION_TIMEOUT | 90 | EggDrop'o/WinDrop'o nustatymų *connect-timeout* parametras. Daugiau apie jį galima sužinoti [oficialioje EggDrop dokumentacijoje](http://docs.eggheads.org/coreDocs/core.html). |
| EGGDROP_DCC_FLOOD_THR | 3 | EggDrop'o/WinDrop'o nustatymų *dcc-flood-thr* parametras. Daugiau apie jį galima sužinoti [oficialioje EggDrop dokumentacijoje](http://docs.eggheads.org/coreDocs/core.html). |
| EGGDROP_TELNET_FLOOD | 5:60 | EggDrop'o/WinDrop'o nustatymų *telnet-flood* parametras. Daugiau apie jį galima sužinoti [oficialioje EggDrop dokumentacijoje](http://docs.eggheads.org/coreDocs/core.html). |
| EGGDROP_PARANOID_TELNET_FLOOD | 1 | EggDrop'o/WinDrop'o nustatymų *paranoid-telnet-flood* parametras. Daugiau apie jį galima sužinoti [oficialioje EggDrop dokumentacijoje](http://docs.eggheads.org/coreDocs/core.html). |
| EGGDROP_RESOLVE_TIMEOUT | 15 | EggDrop'o/WinDrop'o nustatymų *resolve-timeout* parametras. Daugiau apie jį galima sužinoti [oficialioje EggDrop dokumentacijoje](http://docs.eggheads.org/coreDocs/core.html). |
| EGGDROP_MAX_DCC | 50 | EggDrop'o/WinDrop'o nustatymų *max-dcc* parametras. Daugiau apie jį galima sužinoti [oficialioje EggDrop dokumentacijoje](http://docs.eggheads.org/coreDocs/core.html). |
| EGGDROP_ALLOW_DK_CMDS | 1 | EggDrop'o/WinDrop'o nustatymų *allow-dk-cmds* parametras. Daugiau apie jį galima sužinoti [oficialioje EggDrop dokumentacijoje](http://docs.eggheads.org/coreDocs/core.html). |
| EGGDROP_MODULES | dns channels server ctcp irc notes console transfer share | Kokius EggDrop'o/WinDrop'o modulius užkrauti? |
| EGGDROP_CHECK_MODULES | blowfish | Moduliai, kurie skirti duomenų patikrinimui |
| EGGDROP_NICK | SeaBattle | EggDrop'o/WinDrop'o nustatymų *nick* parametras. Daugiau apie jį galima sužinoti [oficialioje EggDrop dokumentacijoje](http://docs.eggheads.org/coreDocs/server.html). |
| EGGDROP_ALTNICK | SeaBattleBot | EggDrop'o/WinDrop'o nustatymų *altnick* parametras. Daugiau apie jį galima sužinoti [oficialioje EggDrop dokumentacijoje](http://docs.eggheads.org/coreDocs/server.html). |
| EGGDROP_ADMIN | owner | EggDrop'o/WinDrop'o nustatymų *admin* parametras. Daugiau apie jį galima sužinoti [oficialioje EggDrop dokumentacijoje](http://docs.eggheads.org/coreDocs/core.html). |
| EGGDROP_REAL | Bot for Games.lt | EggDrop'o/WinDrop'o nustatymų *realname* parametras. Daugiau apie jį galima sužinoti [oficialioje EggDrop dokumentacijoje](http://docs.eggheads.org/coreDocs/server.html). |
| EGGDROP_SERVERS | irc.data.lt | Serveriai, prie kurių jungtis automatiškai |
| EGGDROP_CHANNELS | #seabattle | Kanalai, prie kurių jungtis automatiškai |
| EGGDROP_NET_TYPE | 5 | EggDrop'o/WinDrop'o nustatymų *net-type* parametras. Daugiau apie jį galima sužinoti [oficialioje EggDrop dokumentacijoje](http://docs.eggheads.org/coreDocs/server.html). |
| EGGDROP_LISTEN_USERS_PORT | 3333 | Kurio porto turėtų klausyti bot'as, jei norėtų bendrauti su vartotojais? |
| EGGDROP_LISTEN_BOTS_PORT | 3333 | Kurio porto turėtų klausyti bot'as, jei norėtų bendrauti su kitais botais? |
| EGGDROP_OWNERS | | EggDrop'o/WinDrop'o nustatymų *owner* parametras. Daugiau apie jį galima sužinoti [oficialioje EggDrop dokumentacijoje](http://docs.eggheads.org/coreDocs/core.html). |
| EGGDROP_SYSTEM_SCRIPTS | alltools action.fix compat userinfo | Kokius sisteminius skriptus įkelti? |
| EGGDROP_SYSTEM_HELPS | userinfo | Kokius sisteminius pagalbos failus įkelti? |

#### 2. Rankomis sukonfiguruokite projektą

Pirmiausia įsitikinkite, kad turite jau darbui paruoštą [Eggdrop](http://www.eggheads.org)/[Windrop](http://windrop.sourceforge.net) bot'ą. Kaip tai padaryti, galima sužinoti, aplankius pasirinkto bot'o tinklalapį arba pasigooglinus. Na, o tuomet reikės atlikti šiuos veiksmus:
 * Atsisiųsti [naujausios versijos archyvą](https://github.com/GamesLT/SeaBattle.tcl/releases/latest)
 * Jį išpakuoti 
 * Nukopijuoti `src/` failus, kur botas laiko savo skriptus
 * Pridėti `source seabattle_main.tcl` eilutę `eggdrop.conf` faile (čia gali tekti prirašyti pilną kelią prie `seabattle_main.tcl` pavadinimo)
 * Įdiegti [mysqltcl](http://www.xdobry.de/mysqltcl/) biblioteką (jei naudojatės Windows arba negalite visiškai kontroliuoti serverio, tuomet teks atsisiųsti jau sukompiliuotą *3.02* versiją iš šios bibliotekos tinklalapio ir patalpinti `tcllibs` kataloge, kuris turėtų būti šalia nukopijuoto `seabattle.tcl` failo (jei tokio katalogo nėra, tuomet sukurkite).
 * Sukurti naują MySQL duomenų bazę bei importuoti `seabattle.sql` duomenis
 * Paredaguoti nustatymus `seabattle_config.tcl` skripte
 * Paleisti bot'ą. 
 
### Kaip galima prisidėti prie kūrimo?

Visi norintys yra kviečiami prisidėti prie kūrimo. Galima taisyti klaidas ar pridėti kokių nors naujų savybių. Tai galima padaryti sukuriant šios repozitorijos šaką (angl. fork), ją paredaguojant bei sukuriant naują *Pull request*. Jei nežinote, kaip tai padaryti, pabandykite pasinaudoti [interaktyviomis GitHub pamokomis](https://try.github.io/).

Kad būtų paprasčiau bandyti kurti, galima pasinaudoti šioje repozitorijoje esančia [Vagrant](http://vagrantup.com) konfiguracija, kad pasileisti jau paruoštą virtualią mašiną su veikiančiu bot'u. Tuomet tereikia nuklonavus šią repozitoriją tam pačiame kataloge įvykdyti `vagrant up` komandą. Tuomet bus įmanoma prisijungti prie naujo IRC serverio, kurio adresas - `seabattle.dev`, bei apsilankyti  #seabattle kanale. Būtent ten ir sedės botas.
