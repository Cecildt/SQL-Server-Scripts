-- URL: http://sqlpimp.com/2012/05/21/hello-world/

USE master
go

WITH DOPE_OR_NOPE AS
(
SELECT -- type of object
(case objtype
when 'Proc' then 'Stored procedure'
when 'Prepared' then 'Prepared statement'
when 'Adhoc' then 'Ad hoc query'
when 'ReplProc' then 'Replication\filter\procedure'
when 'UsrTab' then 'User table'
when 'SysTab' then 'System table'
when 'Check' then 'CHECK constraint'
else objtype -- Trigger/View/Default/Rule
end) AS [CacheType],
-- number of that object in the cache
COUNT_BIG(objtype) AS [Total Plans],
-- size of those objects in MB
sum(cast(size_in_bytes as decimal(18,2))) / 1024 / 1024 AS [Total MBs],
-- average use counts
avg(usecounts) AS [Avg Use Count],
-- size of the single use objects in MB
sum(cast((
CASE
WHEN usecounts = 1 THEN size_in_bytes
ELSE 0
END) as decimal(18,2))/1024/1024) AS [Total MBs - USE Count 1],
-- count of single use objects
sum(CASE WHEN usecounts = 1 then 1 else 0 end) AS [Total USE Count 1 Plans]
FROM sys.dm_exec_cached_plans
GROUP BY objtype
)
SELECT [CacheType],
[Total Plans],
[Total MBs],
[Avg Use Count],
[Total USE Count 1 Plans],
[Total MBs - USE Count 1],
Cast([Total Plans]*1.0/Sum([Total Plans])
OVER() * 100.0 AS DECIMAL(5, 2)) As Cache_Alloc_Pct,
Cast([Total USE Count 1 Plans]*1.0/[Total Plans]
* 100.0 AS DECIMAL(5, 2)) As Cache_Alloc_Pct_USE_Count_1
FROM DOPE_OR_NOPE
ORDER BY [Total Plans] desc;

-- Check Bad Plan Cache usage
select ecp.usecounts, ecp.size_in_bytes, stext.[text], ecp.plan_handle, qplan.query_plan
from sys.dm_exec_cached_plans ecp
cross apply sys.dm_exec_sql_text(ecp.plan_handle) stext
cross apply sys.dm_exec_query_plan(ecp.plan_handle) qplan
where ecp.usecounts = 1
and ecp.objtype in(N'Prepared', N'Adhoc')
order by ecp.size_in_bytes desc;