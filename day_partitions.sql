create or replace function create_daytable(parent_table text, daynum int) returns void AS $$
declare STATEMENT TEXT;
begin
  -- e.g. create table br_16791 () inherits (br);
  SET client_min_messages = error;
  STATEMENT := 'CREATE TABLE IF NOT EXISTS ' || parent_table || '_' || daynum || ' () INHERITS (' || parent_table ||')';
  EXECUTE STATEMENT;
end;
$$ LANGUAGE 'plpgsql';


create or replace function daynum_now() returns integer as $$
begin
	RETURN FLOOR(EXTRACT(EPOCH FROM now())/(24*3600));
end
$$ LANGUAGE 'plpgsql';


create or replace function create_last_daytables(parent_table text, numdays int) returns void as $$
declare DAYNOW INTEGER;	
begin
	perform create_daytable('br', daynum) from (SELECT generate_series(daynum_now()-numdays, daynum_now()) AS daynum) as daynums;
end
$$ LANGUAGE 'plpgsql';


create or replace function daytable_insert_trigger() returns trigger as $$
declare daynum INTEGER;
declare STATEMENT TEXT;
declare daycol TEXT;
begin
	daycol := TG_ARGV[0];
	EXECUTE format('SELECT ($1).%I::integer', daycol) USING NEW INTO daynum;
	PERFORM create_daytable(TG_TABLE_NAME, daynum);
	EXECUTE 'INSERT INTO ' || quote_ident(TG_TABLE_NAME || '_' || daynum) || ' SELECT $1.*' USING NEW;
	RETURN NULL;
end
$$ LANGUAGE 'plpgsql';

