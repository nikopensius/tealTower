----------------------------------------
-- Tabelite loomine
----------------------------------------

CREATE TABLE kirikud (
    "id"                             integer NOT NULL DEFAULT autoincrement
   ,"nimi"                           varchar(50) NOT NULL
   ,"aadress"                        varchar(50) NOT NULL
   ,"valmis"                         integer NOT NULL
   ,"tornid"                         integer
   ,"orel"                           bit NOT NULL
   ,"stiil"                          varchar(20)
   ,PRIMARY KEY (id) 
);

CREATE TABLE kogudused (
    "id"                             integer NOT NULL
   ,"nimi"                           varchar(45)
   ,"usutunnistus"                   varchar(45)
   ,"asutusaasta"                    integer
   ,"kirik"                          integer NOT NULL
   ,"telefon"                        varchar(45)
   ,PRIMARY KEY (id),
   CONSTRAINT `fk_Kirikud_Kogudused`
        FOREIGN KEY (`kirik`)
        REFERENCES `Kirikud` (`id`),
);

CREATE TABLE organisatsioonid (
    "id"                             integer NOT NULL DEFAULT autoincrement
   ,"nimetus"                        varchar(45)
   ,"tüüp"                           varchar(45)
   ,PRIMARY KEY (id) 
);

create table ürituste_tüübid (
    "id"                              integer NOT NULL DEFAULT autoincrement,
    "tüüp"                            varchar(30),
    PRIMARY KEY (id)
);

CREATE TABLE üritused (
    "id"                             integer DEFAULT autoincrement,
    "nimetus"                        varchar(60),
    "aeg"                            DATETIME,
    "tüüp"                           integer,
    "organiseerija"                  integer,
    "kirik"                          integer NOT NULL,
    "avatud"                         bit NOT NULL,
    "korduv"                         bit NOT NULL,
    "kommentaar"                     varchar(45),
    PRIMARY KEY (`id`),
    CONSTRAINT `fk_Üritused_Kirikud`
        FOREIGN KEY (`kirik`)
        REFERENCES `Kirikud` (`id`),
    CONSTRAINT `fk_Üritused_Organisatsioonid`
        FOREIGN KEY (`organiseerija`)
        REFERENCES `Organisatsioonid` (`id`),
    CONSTRAINT `fk_Üritused_Tüübid`
        FOREIGN KEY (`tüüp`)
        REFERENCES `Ürituste_Tüübid` (`id`))
;

CREATE TABLE isikud (
    "isikukood"                      varchar(11),
    "nimi"                           varchar(45),
    PRIMARY KEY (isikukood) 
);

CREATE TABLE osalemine (
    "organisatsioon"            integer,
    "isik"                      VARCHAR(11),
    CONSTRAINT "fk_Osalemine_Organisatsioon"
        FOREIGN KEY ("organisatsioon")
        REFERENCES "organisatsioonid" ("id"),
    CONSTRAINT "fk_Osalemine_Isik"
        FOREIGN KEY ("isik")
        REFERENCES "isikud" ("isikukood")
);

----------------------------------------
-- Andmete lisamine
----------------------------------------

INPUT INTO isikud
FROM 'data\isikud.csv'
DELIMITED BY ',';

INPUT INTO kirikud
FROM 'data\\kirikud.csv'
DELIMITED BY ',';

INPUT INTO kogudused
FROM 'data\\kogudused.csv'
DELIMITED BY ',';

INPUT INTO organisatsioonid
FROM 'data\\organisatsioonid.csv'
DELIMITED BY ',';

INPUT INTO osalemine
FROM 'data\\osalemine.csv'
DELIMITED BY ',';

INPUT INTO ürituste_tüübid
FROM 'data\\ürituste_tüübid.csv'
DELIMITED BY ',';

INPUT INTO üritused
FROM 'data\\üritused.csv'
DELIMITED BY ',';


----------------------------------------
-- Protseduurite loomine
----------------------------------------

-- 1. Tagastab kirikud, millel on etteantud arv torne
create or replace procedure torniga_kirikud (in torni_arv integer)
result (
    nimi varchar(50),
    tornid integer)
BEGIN 
    select nimi, tornid
    from kirikud
    where tornid = torni_arv
    order by torni_arv;
end;
-- vastavalt sisendile nt: 0 - adventkirik 0/ 1 - Tartu katoliku kirik 1 Kolgata kirik 1 Jaani kirik 1/ 6 - Jumalaema uinumise katedraalkirik 6

-- 2. Tagastab oreliga kirikud, kus peetakse jumalateenistust ja mis vastavad sisestatud usutunnistusele
create or replace procedure oreliga_jumalat_kir (in i_usutunnistus varchar(50))
result (
    nimi varchar(50),
    usutunnistus varchar(50))
begin
    select kirikud.nimi, kogudused.usutunnistus 
    from kirikud, kogudused, üritused
    where üritused.tüüp = 1 and //jumalateenistus
    üritused.kirik = kirikud.id and
    kirikud.id = kogudused.kirik and
    i_usutunnistus = kogudused.usutunnistus and
    kirikud.orel = 1;
end;
-- vastavalt sisendile: 'Vene õigeusk': Jumalaema uinumise katedralkirik Vene õigeusk/ 'Evangeelne luterlus': Jaani kirik Evangeelne luterlus

-- 3. lisab ürituste tabelisse etteantud ürituse. Kui etteantud tüüpi pole ürituste tüüpide tabelis, siis protseduur loob tabelisse vastava tüübi
create or replace procedure lisa_ür (in nimetus varchar(45), in aeg datetime, in ü_tüüp varchar(45), in organiseerija varchar(45), in kirik varchar(45), in avatud bit, in korduv bit, in kommentaar varchar(50), out i_id integer)
begin
	declare a_id integer;
	declare org_id integer;
	declare kir_id integer;
    declare t_id INTEGER ;

    if (select count(*) from ürituste_tüübid where tüüp = ü_tüüp) = 0
    then insert into ürituste_tüübid(tüüp) values(ü_tüüp);
    select @@identity into i_id;
    set t_id = i_id;
    end if;

    select id into t_id from ürituste_tüübid
        where tüüp = ü_tüüp;
    
	select id into org_id from organisatsioonid
		where nimetus = organiseerija;

	select id into kir_id from kirikud
		where nimetus = kirik;
	insert into üritused(nimetus, aeg, tüüp, organiseerija, kirik, avatud, korduv, kommentaar)
	values (nimetus, aeg, t_id, org_id, kir_id, avatud, korduv, kommentaar);
	select @@identity into i_id;
	set a_id = i_id;
end;
-- Protseduuri kutsumine ei anna midagi välja

-- 4. Tagastab info kiriku ja koguduse kohta vastavalt etteantud usutunnistusele
create or replace procedure kir_kog_inf (in i_usutunnistus varchar(50))
result (
    Kirik varchar(50),
    Aadress varchar(50),
    Kogudus varchar(50),
    Kontakttelefon varchar(50))
begin
select kirikud.nimi, kirikud.aadress, kogudused.nimi, kogudused.telefon 
from kirikud join kogudused where kogudused.usutunnistus = i_usutunnistus;
end;

call kir_kog_inf('katoliiklus') - 'Tartu katoliku kirik','Veski 1a','Püha Maarja Tartu katoliku kogudus','500003'
call kir_kog_inf('Vene õigeusk') - 'Jumalaema uinumise katedraalkirik','Magasini 1','ÕU Püha Jüri Tartu kogudus','500002'

-- 5. Tagastab üritused, mis toimuvad järgmise 7 päeva jooksul (nimetused ja ajad)
CREATE OR REPLACE PROCEDURE üritused_seitsme_päeva()
RESULT (
    nimetus VARCHAR(45),
    aeg DATETIME
)
BEGIN
    SELECT nimetus, aeg
    FROM üritused
    WHERE üritused.aeg BETWEEN CURRENT TIMESTAMP AND üritused.aeg + dateadd(day, 7, CURRENT TIMESTAMP)
        OR üritused.korduv = 1
    ORDER BY aeg ASC
END
;