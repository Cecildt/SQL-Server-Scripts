-- http://www.sqlserver-dba.com/2012/06/how-to-find-the-largest-sql-index-and-table-size.html

use AdventureWorks2008R2;
GO
CREATE TABLE #TableSpaceUsed

(
           
           Table_name NVARCHAR(255),
           Table_rows INT,
           Reserved_KB VARCHAR(20),
           Data_KB VARCHAR(20),
           Index_Size_KB VARCHAR(20),
           Unused_KB VARCHAR(20)

)

INSERT INTO #TableSpaceUsed

EXEC sp_MSforeachtable 'sp_spaceused ''?'''

SELECT Table_name,Table_Rows,
CONVERT(INT,SUBSTRING(Index_Size_KB,1,LEN(Index_Size_KB) -2)) as indexSizeKB, 
CONVERT(INT,SUBSTRING(Data_KB,1,LEN(Data_KB) -2)) as dataKB, 
CONVERT(INT,SUBSTRING(Reserved_KB,1,LEN(Reserved_KB) -2)) as reservedKB, 
CONVERT(INT,SUBSTRING(Unused_KB,1,LEN(Unused_KB) -2)) as unusedKB
FROM #TableSpaceUsed
ORDER BY dataKB DESC
DROP TABLE #TableSpaceUsed
