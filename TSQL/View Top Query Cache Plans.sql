-- http://blogs.msdn.com/b/sqlprogrammability/archive/2007/01/23/4-0-useful-queries-on-dmv-s-to-understand-plan-cache-behavior.aspx

SELECT TOP 1000 st.text, 
                cp.cacheobjtype, 
                cp.objtype, 
                cp.refcounts,
                cp.usecounts, 
                cp.size_in_bytes, 
                cp.bucketid, 
                cp.plan_handle
 FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
WHERE cp.cacheobjtype = 'Compiled Plan'
  AND (cp.objtype = 'Adhoc' or cp.objtype = 'Prepared')
ORDER BY cp.objtype DESC, cp.size_in_bytes DESC
GO