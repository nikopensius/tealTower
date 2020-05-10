//annab kirikud, millel on etteantud arv torne
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
// vastavalt sisendile nt: 0 - adventkirik 0/ 1 - Tartu katoliku kirik 1 Kolgata kirik 1 Jaani kirik 1/ 6 - Jumalaema uinumise katedraalkirik 6


// annab oreliga kirikud, kus peetakse jumalateenistust ja mis vastavad sisestatud usutunnistusele
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
// vastavalt sisendile: 'Vene õigeusk': Jumalaema uinumise katedralkirik Vene õigeusk/ 'Evangeelne luterlus': Jaani kirik Evangeelne luterlus

// lisab ürituste tabelisse etteantud ürituse. Kui etteantud tüüpi pole ürituste tüüpide tabelis, siis protseduur loob tabelisse vastava tüübi
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
//Protseduuri kutsumine ei anna midagi välja