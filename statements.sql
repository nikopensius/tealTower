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
   ,"t��p"                           varchar(45)
   ,PRIMARY KEY (id) 
);

create table �rituste_t��bid (
    "id"                              integer NOT NULL DEFAULT autoincrement,
    "t��p"                            varchar(30),
    PRIMARY KEY (id)
);

CREATE TABLE �ritused (
    "id"                             integer DEFAULT autoincrement,
    "nimetus"                        varchar(60),
    "aeg"                            DATETIME,
    "t��p"                           integer,
    "organiseerija"                  integer,
    "kirik"                          integer NOT NULL,
    "avatud"                         bit NOT NULL,
    "korduv"                         bit NOT NULL,
    "kommentaar"                     varchar(45),
    PRIMARY KEY (`id`),
    CONSTRAINT `fk_�ritused_Kirikud`
        FOREIGN KEY (`kirik`)
        REFERENCES `Kirikud` (`id`),
    CONSTRAINT `fk_�ritused_Organisatsioonid`
        FOREIGN KEY (`organiseerija`)
        REFERENCES `Organisatsioonid` (`id`),
    CONSTRAINT `fk_�ritused_T��bid`
        FOREIGN KEY (`t��p`)
        REFERENCES `�rituste_T��bid` (`id`))
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

INPUT INTO �rituste_t��bid
FROM 'data\\�rituste_t��bid.csv'
DELIMITED BY ',';

INPUT INTO �ritused
FROM 'data\\�ritused.csv'
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
    from kirikud, kogudused, �ritused
    where �ritused.t��p = 1 and //jumalateenistus
    �ritused.kirik = kirikud.id and
    kirikud.id = kogudused.kirik and
    i_usutunnistus = kogudused.usutunnistus and
    kirikud.orel = 1;
end;
-- vastavalt sisendile: 'Vene �igeusk': Jumalaema uinumise katedralkirik Vene �igeusk/ 'Evangeelne luterlus': Jaani kirik Evangeelne luterlus

-- 3. lisab �rituste tabelisse etteantud �rituse. Kui etteantud t��pi pole �rituste t��pide tabelis, siis protseduur loob tabelisse vastava t��bi
create or replace procedure lisa_�r (in nimetus varchar(45), in aeg datetime, in �_t��p varchar(45), in organiseerija varchar(45), in kirik varchar(45), in avatud bit, in korduv bit, in kommentaar varchar(50), out i_id integer)
begin
	declare a_id integer;
	declare org_id integer;
	declare kir_id integer;
    declare t_id INTEGER ;

    if (select count(*) from �rituste_t��bid where t��p = �_t��p) = 0
    then insert into �rituste_t��bid(t��p) values(�_t��p);
    select @@identity into i_id;
    set t_id = i_id;
    end if;

    select id into t_id from �rituste_t��bid
        where t��p = �_t��p;
    
	select id into org_id from organisatsioonid
		where nimetus = organiseerija;

	select id into kir_id from kirikud
		where nimetus = kirik;
	insert into �ritused(nimetus, aeg, t��p, organiseerija, kirik, avatud, korduv, kommentaar)
	values (nimetus, aeg, t_id, org_id, kir_id, avatud, korduv, kommentaar);
	select @@identity into i_id;
	set a_id = i_id;
end;
-- Protseduuri kutsumine ei anna midagi v�lja

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

call kir_kog_inf('katoliiklus') - 'Tartu katoliku kirik','Veski 1a','P�ha Maarja Tartu katoliku kogudus','500003'
call kir_kog_inf('Vene �igeusk') - 'Jumalaema uinumise katedraalkirik','Magasini 1','�U P�ha J�ri Tartu kogudus','500002'

-- 5. Tagastab �ritused, mis toimuvad j�rgmise 7 p�eva jooksul (nimetused ja ajad)
CREATE OR REPLACE PROCEDURE �ritused_seitsme_p�eva()
RESULT (
    nimetus VARCHAR(45),
    aeg DATETIME
)
BEGIN
    SELECT nimetus, aeg
    FROM �ritused
    WHERE �ritused.aeg BETWEEN CURRENT TIMESTAMP AND �ritused.aeg + dateadd(day, 7, CURRENT TIMESTAMP)
        OR �ritused.korduv = 1
    ORDER BY aeg ASC
END
;