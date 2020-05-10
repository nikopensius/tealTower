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
   ,"kirik"                          integer
   ,"telefon"                        varchar(45)
   ,PRIMARY KEY (id) 
);

CREATE TABLE organisatsioonid (
    "id"                             integer NOT NULL DEFAULT autoincrement
   ,"nimetus"                        varchar(45)
   ,"tüüp"                           varchar(45)
   ,"kommentaarid"                   varchar(45)
   ,PRIMARY KEY (id) 
);

CREATE TABLE üritused (
    "id"                             integer DEFAULT autoincrement
   ,"nimetus"                        varchar(60)
   ,"aeg"                            DATETIME
   ,"tüüp"                           integer
   ,"organiseerija"                  integer
   ,"kirik"                          integer
   ,"avatud"                         bit NOT NULL
   ,"korduv"                         bit NOT NULL
   ,"kommentaar"                     varchar(45)
);

CREATE TABLE isikud (
    "id"                             integer NOT NULL
   ,"nimi"                           varchar(45)
   ,"isikukood"                      varchar(11)
   ,PRIMARY KEY (id) 
);

CREATE TABLE osalemine (
    "organisatsioonid_id"            integer
   ,"isikud_id"                      integer
   ,"id"                             integer
);

create table ürituste_tüübid (
    "id"                              integer NOT NULL DEFAULT autoincrement,
    "tüüp"                            varchar(30),
    PRIMARY KEY (id)
);


----------------------------------------
-- Välisvõtite lisamine
----------------------------------------

ALTER TABLE kogudused
    ADD NOT NULL FOREIGN KEY "fk_kirik" (id)
    REFERENCES kirikud (id)
;

ALTER TABLE osalemine
    ADD FOREIGN KEY "fk_organisatsioonid_id" (id)
    REFERENCES organisatsioonid (id)   
;

ALTER TABLE osalemine
    ADD FOREIGN KEY "fk_isikud_id" (id)
    REFERENCES isikud (id)
;
ALTER TABLE üritused
    add foreign key "fk_üritus_tüüp" (Tüüp)
    REFERENCES Ürituste_Tüübid (id)
;

ALTER TABLE üritused
    add foreign key "fk_üritused_kirik" (Kirik)
    REFERENCES Kirikud (id)
;

ALTER TABLE üritused
    add foreign key "fk_üritused_organiseerija" (Organiseerija)
    REFERENCES Organisatsioonid (id)
;


----------------------------------------
-- Protseduurite loomine
----------------------------------------

-- 4. Tagastab üritused, mis toimuvad järgmise 7 päeva jooksul (nimetused ja ajad)
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

-- 5. 