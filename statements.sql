-- Tabelite loomine

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
   ,"aeg"                            "datetime"
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

create table Ürituste_Tüübid (
    id                               int not null default autoincrement,
    Tüüp                             varchar(30),
    primary key (id)
);

-- Välisvõtite lisamine

ALTER TABLE kogudused
    ADD NOT NULL FOREIGN KEY "kirik" (id)
    REFERENCES kirikud (id)
;

ALTER TABLE osalemine
    ADD FOREIGN KEY "organisatsioonid_id" (id)
    REFERENCES organisatsioonid (id)   
;

ALTER TABLE osalemine
    ADD FOREIGN KEY "isikud_id" (id)
    REFERENCES isikud (id)
;

alter table üritused
    add foreign key "fk_üritus_tüüp" (Tüüp)
    references Ürituste_Tüübid (id)
;

alter table Üritused
    add foreign key "fk_üritused_kirik" (Kirik)
    references Kirikud (id)
;

alter table Üritused
    add foreign key "fk_üritused_organiseerija" (Organiseerija)
    references Organisatsioonid (id)
;