alter procedure getStatistics(@p_DatabaseName varchar(max),@p_SchemaName nvarchar(max),@p_TableName nvarchar(max))
as
begin

declare @p_DatabaseName1 varchar(max);
declare @p_SchemaName1 nvarchar(max);
declare @p_TableName1 nvarchar(max);

set @p_DatabaseName1 = @p_DatabaseName
set @p_SchemaName1 = @p_SchemaName

drop table if exists #tables
drop table if exists #columns_row_count
drop table if exists #tables_and_count
drop table if exists #all_columns
drop table if exists #columns_row_count_distinct
drop table if exists #distinct_count
drop table if exists #all


-----get all tables ------
SELECT 
d.TABLE_CATALOG as 'Database Name',
d.TABLE_SCHEMA  as 'Schema Name',
d.TABLE_NAME as 'Table Name',
CONCAT('[',d.TABLE_SCHEMA,'].','[',d.TABLE_NAME,']') as fullname,*
into #tables
FROM INFORMATION_SCHEMA.TABLES  d
where TABLE_TYPE = 'BASE TABLE' and d.TABLE_CATALOG = @p_DatabaseName1 and d.TABLE_SCHEMA = @p_SchemaName1

--Select * from #tables
--get all the counts ---------

DECLARE @QueryString NVARCHAR(MAX) ;
SELECT @QueryString = COALESCE(@QueryString + ' UNION ALL ','')
                      + 'SELECT '
                      + '''' + QUOTENAME(SCHEMA_NAME(sOBJ.schema_id))
                      + '.' + QUOTENAME(sOBJ.name) + '''' + ' AS [TableName]
                      , COUNT(*) AS [RowCount] FROM '
                      + QUOTENAME(SCHEMA_NAME(sOBJ.schema_id))
                      + '.' + QUOTENAME(sOBJ.name) + ' WITH (NOLOCK) '
FROM sys.objects AS sOBJ
WHERE
      sOBJ.type = 'U'
      AND sOBJ.is_ms_shipped = 0x0
ORDER BY SCHEMA_NAME(sOBJ.schema_id), sOBJ.name ;

create table #columns_row_count(TableName varchar(max), RowCounter bigint)
insert into #columns_row_count
EXEC sp_executesql @QueryString

Select d.[Database Name], d.[Schema Name], d.[Table Name], e.RowCounter as 'Table total row count', CONCAT('[',d.TABLE_SCHEMA,'].','[',d.TABLE_NAME,']') as fullname
 into #tables_and_count
from #tables d left join #columns_row_count e on d.fullname = e.TableName

--Select * from #columns_row_count
--select * from #tables_and_count


--get all the columns along data types

SELECT d.TABLE_SCHEMA, d.TABLE_NAME,CONCAT('[',d.TABLE_SCHEMA,'].','[',d.TABLE_NAME,']') as fullname, d.COLUMN_NAME, d.DATA_TYPE into #all_columns
FROM INFORMATION_SCHEMA.COLUMNS d
ORDER BY ORDINAL_POSITION





--get all the distinct counts ---------
SELECT s.name AS [Schema], o.name AS [Table], SUM(p.rows) AS rows, CONCAT('[',s.name,'].','[',o.NAME,']') as fullname into #distinct_count
FROM   sys.schemas s
JOIN   sys.objects o ON s.schema_id = o.schema_id
JOIN   sys.partitions p ON o.object_id = p.object_id
WHERE  p.index_id IN (0, 1)
  AND  o.type = 'U'
GROUP BY s.name, o.name
ORDER  BY s.name, o.name

--putting all together
Select d.[Database Name], d.[Schema Name], d.[Table Name], d.[Table total row count] ,e.COLUMN_NAME, e.DATA_TYPE, f.rows as 'count of Distinct values' into #all from #tables_and_count d 
inner join #all_columns e on e.fullname = d.fullname
inner join #distinct_count f on f.fullname = d.fullname

Select * from #all
end 


--drop table if exists #dynamic_query
--Select d.COLUMN_NAME, CONCAT('[',d.[Schema Name],'].','[',d.[Table Name],']') as fullname , concat('Select count(',d.COLUMN_NAME,') as Count',' from ',CONCAT('[',d.[Schema Name],'].','[',d.[Table Name],'] where ' ,d.COLUMN_NAME, ' is null')) as dynamic_query
--into #dynamic_query from #all d

--select * from #dynamic_query



--drop table if exists #ordered_tables
--declare @numrows int;
--Select @numrows = count(*) from #dynamic_query
--declare @results int;

--Select ROW_NUMBER() over( order by fullname ) as id, * into #ordered_tables from #dynamic_query 
--drop table if exists #columns_row_count_nulls
--create table #columns_row_count_nulls (TableName varchar(max), RowCounter bigint)


----Select * from #ordered_tables
--DECLARE @Counter INT , @MaxId INT,@full varchar(max),
--        @qry NVARCHAR(100)
--SELECT @Counter = 1 , @MaxId = @numrows
--FROM #ordered_tables
 
--WHILE(@Counter IS NOT NULL
--      AND @Counter <= @MaxId)
--BEGIN
--   SELECT @qry = dynamic_query,@full=fullname
--   FROM #ordered_tables WHERE Id = @Counter
--   --PRINT CONVERT(VARCHAR,@Counter) + '. query is ' + @qry + @full
--     exec dbo.getCount strQuery=@qry, @results output
--   --insert into #columns_row_count values EXEC dbo.getCount @QueryString 

   
--   SET @Counter  = @Counter  + 1 
   
   
--END
----exec dbo.getCount @strQuery='Select count(BusinessEntityID) as Count from [HumanResources].[EmployeePayHistory] where BusinessEntityID is null'

