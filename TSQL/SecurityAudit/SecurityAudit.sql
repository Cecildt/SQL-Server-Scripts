-- FROM URL: http://www.sqlserver-dba.com/2012/05/how-to-create-a-sql-server-security-audit.html

--Contains one row for each logon account.
--The system views are : sys.sql_logins , sys.server_principals , but use this one. 
SELECT * 
  FROM sys.syslogins

--Reports the login security configuration of Microsoft® SQL Server™
--Is a deprecated feature 
EXEC xp_loginconfig

--Returns version information about Microsoft SQL Server
EXEC xp_msver

--Returns one row for each table privilege that is granted to or granted by the current user in the current database. 
EXEC sp_table_privileges  '%'

--Returns information about the roles in the current database.
--sp_helprole for every database
EXEC sp_helprole

--Reports information about database-level principals in the current database
--sp_helpuser for every database 
EXEC sp_helpuser

--Returns the physical names and attributes of files associated with the current database. 
--Use this stored procedure to determine the names of files to attach to or detach from the server. 
--sp_helpfile for every database
EXEC sp_helpfile

--Returns a report that has information about user permissions for an object, or statement permissions, in the current database. 
--sp_helprotect for every database
EXEC sp_helprotect

