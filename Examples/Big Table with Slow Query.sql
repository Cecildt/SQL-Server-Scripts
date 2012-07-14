
-- Create Big Table
if exists (select * from sysobjects where name = 'test')
   drop table test
go
create table test(
   c1 int, 
   c2 int, 
   c3 char(256) default ' ', 
   c4 char(740) default ' ')
go
create clustered index cix_test on test(c2, c3)
go
 
set nocount on
go
declare  @i int
set @i = 1
begin tran
while @i <= 4000000
begin
      insert test(c1, c2)
      select @i,
             case when @i % 2 = 0 then @i else 4000000 - @i end
      if @i % 100000 = 0
      begin
         commit tran
         begin tran
      end
      set @i = @i + 1
end
commit tran
go

-- Slow Query
DBCC DROPCLEANBUFFERS
go
SELECT COUNT(*) FROM dbo.test;