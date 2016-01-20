Postgres Day Partition
======================

You have a massive table with records going back for years.  It has become unmanageable.  Even deleting old ata is slow and inconvenient.  What do you do?

Postgres inheritance provides a transparent way of splitting a massive table into many smaller tables, one for each day.  Queries don't have to be changed - postgres will transparently run a select query on all the small tables and glue the results together:

	-- Create a parent table:
	create table ht
	( my_daynum	int
	, score		int
	, size		int
	, domain	text
	, country	text
	, browser	text
	, hack_type	int
	);
	-- Create a small table for UNIX daynums 16791 and 16792 and give it some data:
	create table ht_16791 () inherits (ht);
	create table ht_16792 () inherits (ht);
	copy ht_16791 from '/tmp/ht_16791.csv' csv;
	copy ht_16792 from '/tmp/ht_16792.csv' csv;
	-- Querying the parent table gives you data in the small tables:
	select * from br limit 20;
	-- Data too old to be interesting?  Delete that day:
	drop table ht_16791;

However postgres does NOT manage insertions transparently.  Not out of the box.  That is what these functions are for:


	CREATE TRIGGER ht_insert_trigger
	    BEFORE INSERT ON ht
	    FOR EACH ROW EXECUTE PROCEDURE daytable_insert_trigger('my_daynum');
	insert into ht values (19,10,3,'loopy','NZ','Panda',96758769);
	\dt
	select * from ht;

This will automagically create the small table, if necessary, and insert the data into the appropriate small table.
