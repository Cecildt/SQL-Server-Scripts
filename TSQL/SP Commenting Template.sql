----------------------------------------------------------------------------------------------
-- OBJECT NAME  : MyStoredProcedure
-- INPUTS       : @myParam1 NVARCHAR(128),@myParam2 INT
-- OUTPUTS      : @myOutParam1 NVARCHAR(128)
-- DEPENDENCIES : None
-- AUTHOR       : Firstname Lastname
-- DESCRIPTION  : This stored procedure accepts 2 parameters 
--
-- EXAMPLES (optional) : EXEC MyStoredProcedure ‘sqlserver’, 2
--
-- Version HISTORY : version|Author|Date| Comment
-- 1.0  JV 7\10\2011  - Initial Version
-- 1.1  JV 11\10\2011 - Added CONVERT

CREATE PROCEDURE usp_description