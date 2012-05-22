-- FROM URL: http://sqlblog.com/blogs/tibor_karaszi/archive/2009/06/25/table-restore-and-filegroups.aspx

--Drop and create the database 
USE master 
IF DB_ID('fgr') IS NOT NULL DROP DATABASE fgr 
GO 
--Three filegroups 
CREATE DATABASE fgr ON  PRIMARY  
( NAME = N'fgr', FILENAME = 'E:\Data\fgr.mdf'),  
 FILEGROUP fg1  
( NAME = N'fg1', FILENAME = 'E:\Data\fg1.ndf'),  
 FILEGROUP fg2  
( NAME = N'fg2', FILENAME = 'E:\Data\fg2.ndf') 
 LOG ON  
( NAME = N'fgr_log', FILENAME = 'E:\Log\fgr_log.ldf') 
GO 
ALTER DATABASE fgr SET RECOVERY FULL 

--Base backup 
BACKUP DATABASE fgr TO DISK = 'E:\Backups\fgr.bak' WITH INIT 
GO 

--One table on each filegroup 
CREATE TABLE fgr..t_primary(c1 INT) ON "PRIMARY"
CREATE TABLE fgr..t_fg1(c1 INT) ON fg1 
CREATE TABLE fgr..t_fg2(c1 INT) ON fg2 

--Insert data into each table 
INSERT INTO fgr..t_primary(c1) VALUES(1) 
INSERT INTO fgr..t_fg1(c1) VALUES(1) 
INSERT INTO fgr..t_fg2(c1) VALUES(1) 

BACKUP LOG fgr TO DISK = 'E:\Backups\fgr.trn' WITH INIT --1 

--Filegroup backup of fg2 
BACKUP DATABASE fgr FILEGROUP = 'fg2' TO DISK = 'E:\Backups\fgr_fg2.bak' WITH INIT 

BACKUP LOG fgr TO DISK = 'E:\Backups\fgr.trn' WITH NOINIT --2 

--Delete from t_fg2 
--Ths is our accident which we want to rollback!!! 
DELETE FROM fgr..t_fg2 

BACKUP LOG fgr TO DISK = 'E:\Backups\fgr.trn' WITH NOINIT --3 

--Now, try to restore that filegroup to previos point in time 
RESTORE DATABASE fgr FILEGROUP = 'fg2' FROM DISK = 'E:\Backups\fgr_fg2.bak' 
GO 

SELECT * FROM fgr..t_fg2 --error 8653 
GO 

--If we are on 2005+ and EE or Dev Ed, the restore can be online 
--This means that rest of the database is accessible during the restore 
INSERT INTO fgr..t_fg1(c1) VALUES(2) 
SELECT * FROM fgr..t_fg1 

--We must restore *all* log backups since that db backup 
RESTORE LOG fgr FROM DISK = 'E:\Backups\fgr.trn' WITH FILE = 2 --out of 3 
RESTORE LOG fgr FROM DISK = 'E:\Backups\fgr.trn' WITH FILE = 3 --out of 3 
GO 

SELECT * FROM fgr..t_fg2 --Success 
--We didn't get to the data before the accidental DELETE! 
GO 

---------------------------------------------------------------------------- 
--What we can do is restore into a new database instead, 
--to an earlier point in time. 
--We need the PRIMARY filegroup and whatever more we want to access 
---------------------------------------------------------------------------- 
IF DB_ID('fgr_tmp') IS NOT NULL DROP DATABASE fgr_tmp 
GO 
RESTORE DATABASE fgr_tmp FILEGROUP = 'PRIMARY' FROM DISK = 'E:\Backups\fgr.bak' 
WITH 
 MOVE 'fgr' TO 'E:\Data\fgr_tmp.mdf' 
,MOVE 'fg2' TO 'E:\Data\fg2_tmp.ndf' 
,MOVE 'fgr_log' TO 'E:\Log\fgr_tmp_log.ldf' 
,PARTIAL, NORECOVERY 

RESTORE DATABASE fgr_tmp FILEGROUP = 'fg2' FROM DISK = 'E:\Backups\fgr_fg2.bak' 

RESTORE LOG fgr_tmp FROM DISK = 'E:\Backups\fgr.trn' WITH FILE = 1, NORECOVERY 
RESTORE LOG fgr_tmp FROM DISK = 'E:\Backups\fgr.trn' WITH FILE = 2, RECOVERY 

--Now the data in PRIMARY and fg2 is accessible 
SELECT * FROM fgr_tmp..t_fg2 

--We can use above to import to our production db: 
INSERT INTO fgr..t_fg2(c1) 
SELECT c1 FROM fgr_tmp..t_fg2 

--And now the data is there again :-) 
SELECT * FROM fgr..t_fg2 