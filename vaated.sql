//loob vaate kirikutest, millel pole torne või on rohkem kui üks torn
create or replace view mitte_ühe_torni_kirikud as select nimi, tornid from kirikud
where tornid <> 1;
//annab välja kirikute nimed: 

//loob vaate kirikutest, kus saab orelisaatega jumalateenistusi kuulata
create or replace view oreliga_jumalateenistusega_kirikud as
select nimi from kirikud, üritused
where kirikud.orel = 1 and
kirikud.id = üritused.kirik and
üritused.nimetus = 'Jumalateenistus';