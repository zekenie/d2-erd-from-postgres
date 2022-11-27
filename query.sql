with 
primary_keys as (
	select 
	       kcu.table_name,
	       kcu.column_name as key_column
	from information_schema.table_constraints tco
	join information_schema.key_column_usage kcu 
	     on kcu.constraint_name = tco.constraint_name
	     and kcu.constraint_schema = tco.constraint_schema
	     and kcu.constraint_name = tco.constraint_name
	where tco.constraint_type = 'PRIMARY KEY'
	order by kcu.table_schema,
	         kcu.table_name
),
foreign_key_relationships as (
	SELECT
	    tc.table_name, 
	    kcu.column_name, 
	    ccu.table_name AS foreign_table_name,
	    ccu.column_name AS foreign_column_name 
	FROM 
	    information_schema.table_constraints AS tc 
	    JOIN information_schema.key_column_usage AS kcu
	      ON tc.constraint_name = kcu.constraint_name
	      AND tc.table_schema = kcu.table_schema
	    JOIN information_schema.constraint_column_usage AS ccu
	      ON ccu.constraint_name = tc.constraint_name
	      AND ccu.table_schema = tc.table_schema
	WHERE tc.constraint_type = 'FOREIGN KEY'
),
cols as (
	select information_schema.columns.table_name, data_type, is_nullable = 'YES' as is_nullable, information_schema.columns.column_name, count(foreign_key_relationships.*) >= 1 as is_fk
	from information_schema.columns
	left join foreign_key_relationships
	  on information_schema.columns.table_name = foreign_key_relationships.table_name and information_schema.columns.column_name = foreign_key_relationships.column_name
	group by information_schema.columns.table_name, information_schema.columns.data_type, is_nullable, information_schema.columns.column_name
)

SELECT information_schema.columns.table_name, primary_keys.key_column as primary_key, JSON_AGG(distinct cols) as columns, json_agg(distinct foreign_key_relationships) AS foreign_relations
FROM information_schema.columns
left join foreign_key_relationships
  on foreign_key_relationships.table_name = information_schema.columns.table_name
left join cols
  on cols.table_name = information_schema.columns.table_name
join primary_keys
  on primary_keys.table_name = information_schema.columns.table_name
WHERE table_schema = 'public'
GROUP BY information_schema.columns.table_name, primary_keys.key_column;


