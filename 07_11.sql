USE [OrganicNeva_Nekhvyadovich]
GO
/****** Object:  StoredProcedure [dbo].[p_lasmart_fact_month_balance]    Script Date: 05.11.2020 15:39:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [dbo].[_p1_lasmart_fact_month_balance] (@dt_min int, @dt_max int)
	
AS
SET NOCOUNT ON;
BEGIN

DECLARE 
	@name varchar(500) = '[' + OBJECT_SCHEMA_NAME(@@PROCID) + '].[' + OBJECT_NAME(@@PROCID) + ']',
	@description varchar(500) = 'lasmart_fact_month_balance',
	@input_parametrs varchar(500) = N'[@dt_min =' + STR(@dt_min) + ',' + ' @dt_max =' + STR(@dt_max) +']'

begin try

EXEC [oth].[fill_sup_log] @name = @name, @state_name = 'start', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs


IF @dt_max not in (SELECT [date_final] FROM [lasmart_fact_total_month_balance])
BEGIN


--DECLARE @dt_min int
--DECLARE @dt_max int
--SET @dt_min = 20180801
--SET @dt_max = 20180901

CREATE TABLE #tmp_date(
[date_start] int,
[date_final] int,
[did] int
)

-- создаем диапазон дат по справочнику dim_date
INSERT INTO #tmp_date([date_start], [date_final], [did])
SELECT distinct @dt_min, @dt_max, d.did FROM lasmart_dim_date as d
  inner join [dbo].[lasmart_v_fact_movement] as m on d.did = m.dt
WHERE d.did BETWEEN @dt_min AND @dt_max
order by d.did
--
DELETE FROM #tmp_date WHERE [did] in(SELECT MAX([did]) FROM #tmp_date) 



CREATE TABLE #tmp_balance_date(
[in_date] int,
[dt] int,
[id_store] int,
[id_goods] bigint,
[quantity] money,
[Cost] money
)

--DECLARE @dt_min int
--DECLARE @dt_max int
--SET @dt_min = 20180801
--SET @dt_max = 20180901


DECLARE @count_date int

DECLARE @count_count_f int

DECLARE @count_first int
SET @count_first = (SELECT TOP 1 did FROM #tmp_date)

DECLARE @count_last int
SET @count_last = (SELECT TOP 1 did FROM #tmp_date ORDER BY did DESC)

SET @count_count_f = @count_first

WHILE @count_count_f <= @count_last
BEGIN
   SET @count_date = (SELECT TOP 1 did as d FROM #tmp_date WHERE did = @count_count_f)
   

   INSERT INTO #tmp_balance_date ([in_date], [dt], [id_store], [id_goods], [quantity], [Cost])
   SELECT @dt_max, [dt],[id_store], [id_goods], [quantity], [Cost] 
   FROM [dbo].[lasmart_v_fact_movement]
   WHERE dt = @count_date

   SET @count_count_f = @count_count_f + 1

END;

--TRUNCATE TABLE [lasmart_fact_total_month_balance]
--DROP TABLE #tmp_balance_date
--DROP TABLE #tmp_balance_month

--CREATE TABLE #tmp_balance_month(
--	[date_final] [int] NULL,
--	[id_store] [int] NULL,
--	[id_goods] [bigint] NULL,
--	[quantity_tot] [money] NULL,
--	[Cost_tot] [money] NULL
--)


--DECLARE @dt_min int
--DECLARE @dt_max int
--SET @dt_min = 20180801
--SET @dt_max = 20180901

DECLARE @max_date_in_balance int
SET @max_date_in_balance = (SELECT Max(date_final) FROM [lasmart_fact_total_month_balance])

--#tmp_balance_month
INSERT INTO [lasmart_fact_total_month_balance]([date_final] ,[id_store], [id_goods], [quantity_tot], [Cost_tot])
SELECT @dt_max, [id_store], [id_goods], sum([quantity_tot]) as [quantity] , sum([Cost_tot]) as [Cost] FROM (

SELECT [id_store], [id_goods], [quantity_tot], [Cost_tot]
FROM [dbo].[lasmart_fact_total_month_balance]
WHERE [date_final] = @max_date_in_balance


UNION ALL

SELECT [id_store], [id_goods], [quantity], [Cost]
FROM #tmp_balance_date

) as balanse_month
GROUP BY [id_store], [id_goods]

EXEC [oth].[fill_SUP_LOG] @name = @name, @state_name = 'finish', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs

--SELECT sum([quantity_tot]),sum([Cost_tot]) FROM [lasmart_fact_total_month_balance]


--    SELECT sum([quantity]), sum([Cost])
--  FROM [dbo].[lasmart_v_fact_movement]
--  WHERE [dt] BETWEEN 20180801 AND 20180831


--SELECT * FROM [lasmart_fact_total_month_balance]

--SELECT sum([quantity_tot]),sum([Cost_tot]) FROM #tmp_balance_month 
--SELECT * FROM #tmp_balance_month 

--CREATE TABLE [dbo].[lasmart_fact_total_month_balance](
--	[date_final] [int] NULL,
--	[id_store] [int] NULL,
--	[id_goods] [bigint] NULL,
--	[quantity_tot] [money] NULL,
--	[Cost_tot] [money] NULL
--) ON [PRIMARY]
--GO

--IF(
--SELECT 1
--FROM #tmp_balance_date
--WHERE ([id_store] NOT IN (SELECT TOP 1 a.[id_store] FROM [lasmart_fact_total_month_balance] as a)) and 
--      ([id_goods] NOT IN (SELECT TOP 1 b.[id_goods] FROM [lasmart_fact_total_month_balance] as b))) = 1

-----------------------
--SELECT TOP 1 a.[id_store] FROM [lasmart_fact_total_month_balance] as a
--where a.[id_store] 


--IF not EXISTS ( 
--SELECT [id_store], [id_goods] 
--FROM #tmp_balance_date
--WHERE ([id_store] NOT IN (SELECT a.[id_store] FROM [lasmart_fact_total_month_balance] as a)) and 
--      ([id_goods] NOT IN (SELECT b.[id_goods] FROM [lasmart_fact_total_month_balance] as b))
--)
--begin
------------------------
--DECLARE @max_date_in_balance int
--SET @max_date_in_balance = (SELECT Max(date_final) FROM [lasmart_fact_total_month_balance])

--INSERT INTO [lasmart_fact_total_month_balance] ([date_final], [id_store], [id_goods], [quantity], [Cost], [quantity_tot], [Cost_tot])
--SELECT [in_date], [id_store], [id_goods], sum([quantity]) as quantity, sum([Cost]) as Cost ,
--(SELECT sum([quantity])
--   FROM [lasmart_fact_total_month_balance]
--   WHERE [id_store] = o.[id_store] AND [id_goods] = o.id_goods [date_final] <= o.[in_date]) as quantity_tot,

--(SELECT sum([Cost])
--   FROM [lasmart_fact_total_month_balance]
--   WHERE [id_store] = o.[id_store] AND [id_goods] = o.id_goods AND [date_final] <= o.[in_date]) as Cost_tot
--   FROM #tmp_balance_date as o
--group by [in_date], [id_store], [id_goods]

--end
--else
--begin

--INSERT INTO [lasmart_fact_total_month_balance] ([date_final], [id_store], [id_goods], [quantity], [Cost], [quantity_tot], [Cost_tot])
--SELECT [in_date], [id_store], [id_goods], sum([quantity]) as quantity, sum([Cost]) as Cost , sum([quantity]) as quantity_tot, sum([Cost]) as Cost_tot
--FROM #tmp_balance_date as o
--group by [in_date], [id_store], [id_goods]

--end

--EXEC [oth].[fill_SUP_LOG] @name = @name, @state_name = 'finish', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs

--DROP TABLE #tmp_balance_date
--DROP TABLE #tmp_date



--TRUNCATE TABLE [lasmart_fact_total_month_balance]

--SELECT sum([quantity_tot]), sum([Cost_tot]) FROM [lasmart_fact_total_month_balance]


--INSERT INTO lasmart_fact_total_month_balance ([date_final], [id_store], [id_goods], [quantity], [Cost], [quantity_tot], [Cost_tot])
--SELECT [date_final], [id_store], [id_goods], [quantity], [Cost],
--  (SELECT sum([quantity])
--   FROM lasmart_fact_month_balance
--   WHERE [id_store] = o.[id_store] AND [id_goods] = o.id_goods AND [date_final] <= o.[date_final]) as quantity_tot,
--   (SELECT sum([Cost])
--   FROM lasmart_fact_month_balance
--   WHERE [id_store] = o.[id_store] AND [id_goods] = o.id_goods AND [date_final] <= o.[date_final]) as Cost_tot
--FROM lasmart_fact_month_balance as o
----WHERE (date_final BETWEEN 20190701 AND 20190901) --and id_store = 26 and id_goods = 6158
--ORDER BY [date_final], [id_store], [id_goods]




--SELECT sum([quantity]), sum([Cost])
--FROM #tmp_balance_date

--  SELECT sum([quantity]), sum([Cost])
--  FROM [dbo].[lasmart_v_fact_movement]
--  WHERE [dt] BETWEEN 20180801 AND 20180831


-- удаляем первое числo следующего месяца
--DELETE FROM #tmp_date WHERE [did] in(SELECT MAX([did]) FROM #tmp_date) 

--CREATE TABLE #tmp_balance_date(
--[date_final] int,
--[did] int,
--[dt] int,
--[id_store] int,
--[id_goods] bigint,
--[quantity] money,
--[Cost] money
--)

--DECLARE @dt_min int 
--SET @dt_min = 20180801 
--DECLARE @dt_max int 
--SET @dt_max = 20180831

--делаем join  таблицы move >= по дате, в результате вычисляется остаток на последний день месяца
--INSERT INTO #tmp_balance_date([date_final], [did], [dt], [id_store], [id_goods], [quantity], [Cost])
--SELECT @dt_max, d.did, m.dt, m.id_store, m.id_goods, m.quantity, m.Cost  FROM #tmp_date as d
--  join [dbo].[lasmart_v_fact_movement] as m on d.did >= m.dt
--WHERE /*m.dt in (SELECT [did] FROM #tmp_date) and*/ d.did in (SELECT MAX([did]) FROM #tmp_date)
 --ORDER BY d.did , m.dt

 --SELECT sum([quantity]), sum([Cost]) FROM #tmp_balance_date WHERE dt = 20180831


 --DROP TABLE #tmp_balance_date

IF OBJECT_ID(N'tempdb..#tmp_date', N'U') IS NOT NULL
	DROP TABLE #tmp_date
--DROP TABLE #tmp_date


/*month_balanse*/
--INSERT INTO lasmart_fact_month_balance([date_final], [id_store], [id_goods], [quantity], [Cost])
--SELECT [date_final], [id_store], [id_goods], sum([quantity]), sum([Cost])
--FROM #tmp_balance_date
--WHERE 
--GROUP BY date_final, [id_store], [id_goods]

/*total_month_balanse*/
--INSERT INTO lasmart_fact_total_month_balance ([date_final], [id_store], [id_goods], [quantity], [Cost], [quantity_tot], [Cost_tot])
--SELECT [date_final], [id_store], [id_goods], [quantity], [Cost],
--  (SELECT sum([quantity])
--   FROM lasmart_fact_month_balance
--   WHERE [id_store] = o.[id_store] AND [id_goods] = o.id_goods AND [date_final] <= o.[date_final]) as quantity_tot,
--   (SELECT sum([Cost])
--   FROM lasmart_fact_month_balance
--   WHERE [id_store] = o.[id_store] AND [id_goods] = o.id_goods AND [date_final] <= o.[date_final]) as Cost_tot
--FROM lasmart_fact_month_balance as o
----WHERE (date_final BETWEEN 20190701 AND 20190901) --and id_store = 26 and id_goods = 6158
--ORDER BY [date_final], [id_store], [id_goods]

/*
SELECT [date_final], [id_store], [id_goods], [quantity], [Cost],
  (SELECT sum([quantity])
   FROM lasmart_fact_month_balance
   WHERE [id_store] = o.[id_store] AND [id_goods] = o.id_goods AND [date_final] <= o.[date_final]) as quantity_tot,
   (SELECT sum([Cost])
   FROM lasmart_fact_month_balance
   WHERE [id_store] = o.[id_store] AND [id_goods] = o.id_goods AND [date_final] <= o.[date_final]) as Cost_tot
FROM lasmart_fact_month_balance as o
WHERE (date_final BETWEEN 20190701 AND 20190901) and id_store = 26 and id_goods = 6158
ORDER BY [date_final], [id_store], [id_goods]
*/
		


IF OBJECT_ID(N'tempdb..#tmp_balance_date', N'U') IS NOT NULL
	DROP TABLE #tmp_balance_date
--DROP TABLE #tmp_balance_date


END
ELSE
BEGIN
EXEC [oth].[fill_SUP_LOG] @name = @name, @state_name = 'finish', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs
RETURN
END

 --SELECT * FROM sys.objects
 --[dbo].[OrganicNeva_Nekhvyadovich]
end try
begin catch
	EXEC [oth].[fill_SUP_LOG] @name = @name, @state_name = 'error', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs
	IF OBJECT_ID(N'tempdb..#tmp_date', N'U') IS NOT NULL
	DROP TABLE #tmp_date
	IF OBJECT_ID(N'tempdb..#tmp_balance_date', N'U') IS NOT NULL
	DROP TABLE #tmp_balance_date
	RETURN
end catch


END
