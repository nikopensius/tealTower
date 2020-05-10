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