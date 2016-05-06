[![License](https://img.shields.io/github/license/MekDrop/eggdrop-scripts-seabattle-game.svg?maxAge=2592000)](License.txt) ![GitHub release](https://img.shields.io/github/release/MekDrop/eggdrop-scripts-seabattle-game.svg?maxAge=2592000)
# Seabattle

## Aprašymas lietuvių kalba

### Kas tai yra?

Tai yra skriptas, kuris prideda galimybę žaisti klasikinį [Jūros mūšio](https://en.wikipedia.org/wiki/Battleship_(game)) bet kuriame IRC kanale [Eggdrop](http://www.eggheads.org)/[Windrop](http://windrop.sourceforge.net) botams

Šio skripto galimybės/savybės:
 * Veikia tik tekstiniu režimu
 * Tinklo režimas, kuris gali būti žaidžiamas dviejų žaidėjų
 * Naudoja [MySQL](http://mysql.org) kaip duomenų bazę
 * Integruotos vartotojū registracijos
 * Nickserver palaikymas
 * Daugiakalbystės palaikymas
 
### Kaip įdiegti?

Pirmiausia įsitikinkite, kad turite jau darbui paruoštą [Eggdrop](http://www.eggheads.org)/[Windrop](http://windrop.sourceforge.net) bot'ą. Kaip tai padaryti, galima sužinoti, aplankius pasirinkto bot'o tinklalapį arba pasigooglinus. Na, o tuomet reikės atlikti šiuos veiksmus:
 * Atsisiųsti [naujausios versijos archyvą](https://github.com/MekDrop/eggdrop-scripts-seabattle-game/releases/latest)
 * Jį išpakuoti 
 * Nukopijuoti `seabattle.tcl` failą, kur botas laiko savo skriptus
 * Pridėti `source seabattle.tcl` eilutę `eggdrop.conf` faile (čia gali tekti prirašyti pilną kelią prie `seabattle.tcl` pavadinimo)
 * Įdiegti [mysqltcl](http://www.xdobry.de/mysqltcl/) biblioteką (jei naudojatės Windows arba negalite visiškai kontroliuoti serverio, tuomet teks atsisiųsti jau sukimpiliuotą *3.02* versiją iš šios bibliotekos tinklalapio ir patalpinti `tcllibs` kataloge, kuris turėtų būti šalia nukopijuoto `seabattle.tcl` failo (jei tokio katalogo nėra, tuomet sukurkite).
 * Sukurti naują MySQL duomenų bazę bei importuoti `seabattle.sql` duomenis
 * Paredaguoti nustatymus `seabattle.tcl` skripte
 * Paleisti bot'ą. 
 
### Kaip galima prisidėti prie kūrimo?

Visi norintys yra kviečiami prisidėti prie kūrimo. Galima taisyti klaidas ar pridėti kokių nors naujų savybių. Tai galima padaryti sukuriant šios repozitorijos šaką (angl. fork), ją paredaguojant bei sukuriant naują *Pull request*. Jei nežinote, kaip tai padaryti, pabandykite pasinaudoti [interaktyviomis GitHub pamokomis](https://try.github.io/).

Kad būtų paprasčiau bandyti kurti, galima pasinaudoti šioje repozitorijoje esančia [Vagrant](http://vagrantup.com) konfiguracija, kad pasileisti jau paruoštą virtualią mašiną su veikiančiu bot'u. Tuomet tereikia nuklonavus šią repozitoriją tam pačiame kataloge įvykdyti `vagrant up` komandą. Tuomet bus įmanoma prisijungti prie naujo IRC serverio, kurio adresas - `seabattle.dev', bei apsilankyti  #seabattle kanale. Būtent ten ir sedės botas.

****

## Description in English

### What is this?

This is scripts adds a possibility to play classical [Sea batlle/Battleship](https://en.wikipedia.org/wiki/Battleship_(game)) game in IRC channel to [Eggdrop](http://www.eggheads.org)/[Windrop](http://windrop.sourceforge.net) bots.

Features included in this script:
 * Text-only
 * Multiplayer for two users
 * Use [MySQL](http://mysql.org) for game data
 * Build-in user registrations
 * Nickserver support
 * Multilanguage support
 
### How to install?

First thing what you need is to make sure that your [Eggdrop](http://www.eggheads.org)/[Windrop](http://windrop.sourceforge.net) bot is running. How to do, you can find information at your choised bot website. Next things todo:
 * Download [the latest release archive](https://github.com/MekDrop/eggdrop-scripts-seabattle-game/releases/latest)
 * Unpack archive 
 * Copy `seabattle.tcl` file into folder for your bot scripts
 * Add `source seabattle.tcl` line in your `eggdrop.conf` file (NOTE: you need to prefix `seabattle.tcl` with correct path)
 * Install [mysqltcl](http://www.xdobry.de/mysqltcl/) library (if you use bot on windows or on shared server download compiled *3.02* version and put in `tcllibs` (create if this folder doesn't exists in your system!) subfolder in same folder where `seabattle.tcl` is placed.
 * Create new MySQL database and import there `seabattle.sql` 
 * Edit settings in `seabattle.tcl`
 * Run your bot. 
 
### How to develop?

If you want to add some functionality or fix bugs, you can fork, change and create pull request. If you not sure how this works, try   [interactive GitHub tutorial](https://try.github.io/).

It's possible to run Seabattle in local machine with [Vagrant](http://vagrantup.com). All required files exists in this repo. In that case you must just clone the repo and run `vagrant up`. Than it's possible to connect to IRC server at `seabattle.dev' and join #seabattle IRC channel. There the bot should sit.
