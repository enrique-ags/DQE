drop table #temp
drop table #temp2
drop table #temp3
declare @d varchar(max);
set @d = '[{"employee_id": "5181816516151", "department_id": "1", "class": "src\bin\comp\json"}, {"employee_id": "925155", "department_id": "1", "class": "src\bin\comp\json"}, {"employee_id": "815153", "department_id": "2", "class": "src\bin\comp\json"}, {"employee_id": "967", "department_id": "", "class": "src\bin\comp\json"},{"employee_id": "5181816516152", "department_id": "5", "class": "src\bin\comp\json"},{"employee_id": "5181816516153", "department_id": "10", "class": "src\bin\comp\json"}]';

WITH
	json_string AS
	(
	Select LEFT(@d,CHARINDEX(',', @d + ',') - 1) string_item_1,STUFF(@d,1,CHARINDEX(',', @d + ','),'') string_items_1
		union all
		SELECT left(string_items_1,CHARINDEX(',', string_items_1 + ',') - 1) as str1,STUFF(string_items_1,1,CHARINDEX(',', string_items_1 + ','),'') as s
		FROM json_string
	where string_items_1 <>''
	)
SELECt case 
	when CHARINDEX('employee_id',string_item_1) >0 then CHARINDEX('employee_id',string_item_1)
	when CHARINDEX('department_id',string_item_1)>0 then CHARINDEX('department_id',string_item_1)
	else 0
	end as index_data
,* into #temp
FROM json_string;
--select * from #temp

Select  * into #temp2 from 
(
		Select  
		case
			when CHARINDEX('employee_id',string_item_1)>0  then 'Employee_id'
			when CHARINDEX('department_id',string_item_1)>0  then 'Department_id'
		end as type,

		case 
				when CHARINDEX('employee_id',string_item_1)>0 then cast((substring(substring(string_item_1,CHARINDEX(':',string_item_1),LEN(string_item_1) -CHARINDEX(':',string_item_1)),4,LEN(string_item_1)-3 )) AS bigint)
				when CHARINDEX('department_id',string_item_1)>0 then cast(substring(substring(string_item_1,CHARINDEX(':',string_item_1),LEN(string_item_1) -CHARINDEX(':',string_item_1)),4,LEN(string_item_1)-3) as int )
				else ''
		end as transform 
		from #temp e where e.index_data >0) as ds

		select  ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS number, * into #temp3 from #temp2 d

select ds.Employee_id,ds.Department_id  from (
	Select d.number, 
	d.transform as Department_id ,
	lag(d.transform) over( order by d.number) as Employee_id 
from #temp3 d
) as ds
where ds.number%2=0

		






