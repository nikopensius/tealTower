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