create or replace function create_hourtable(parent_table text, hournum int) returns void AS $$
declare STATEMENT TEXT;
begin
  -- e.g. create table br_16791 () inherits (br);
  SET client_min_messages = error;
  STATEMENT := 'CREATE TABLE IF NOT EXISTS ' || parent_table || '_' || hournum || ' () INHERITS (' || parent_table ||')';
  EXECUTE STATEMENT;
end;
$$ LANGUAGE 'plpgsql';


create or replace function hournum_now() returns integer as $$
begin
	RETURN FLOOR(EXTRACT(EPOCH FROM now())/(24*3600));
end
$$ LANGUAGE 'plpgsql';


create or replace function create_last_hourtables(parent_table text, numhours int) returns void as $$
declare DAYNOW INTEGER;	
begin
	perform create_hourtable('br', hournum) from (SELECT generate_series(hournum_now()-numhours, hournum_now()) AS hournum) as hournums;
end
$$ LANGUAGE 'plpgsql';


create or replace function hourtable_insert_trigger() returns trigger as $$
declare hournum INTEGER;
declare STATEMENT TEXT;
declare hourcol TEXT;
begin
	hourcol := TG_ARGV[0];
	EXECUTE format('SELECT ($1).%I::integer', hourcol) USING NEW INTO hournum;
	PERFORM create_hourtable(TG_TABLE_NAME, hournum);
	EXECUTE 'INSERT INTO ' || quote_ident(TG_TABLE_NAME || '_' || hournum) || ' SELECT $1.*' USING NEW;
	RETURN NULL;
end
$$ LANGUAGE 'plpgsql';

