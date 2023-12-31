USE [OrganicNeva_Nekhvyadovich]
GO
/****** Object:  StoredProcedure [dbo].[p_lasmart_fact_month_balance]    Script Date: 06.11.2020 11:28:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[p_lasmart_fact_month_balance] (@dt_min int, @dt_max int)
	
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

--
--DECLARE @dt_min int
--SET @dt_min = 20180401
--DECLARE @dt_max int
--SET @dt_max = 20180501
--

CREATE TABLE #tmp_date(
[date_start] int,
[date_final] int,
[did] int
)

--DROP TABLE #tmp_date
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

--DECLARE @count_date int

DECLARE @max_date_in_balance int
SET @max_date_in_balance = (SELECT TOP 1 MAX([count_date]) FROM [lasmart_fact_total_month_balance] )

INSERT INTO #tmp_balance_date([in_date], [dt], [id_store], [id_goods], [quantity], [Cost])
SELECT [date_final], [count_date], [id_store] ,[id_goods], [quantity_tot], [Cost_tot] FROM [dbo].[lasmart_fact_total_month_balance]
WHERE [count_date] = @max_date_in_balance 




DECLARE @max_count_date int
SET @max_count_date = (SELECT TOP 1 [dt] FROM #tmp_balance_date)

DECLARE @count_count_f int

DECLARE @count_first int
SET @count_first = (SELECT TOP 1 did FROM #tmp_date)

DECLARE @count_last int
SET @count_last = (SELECT TOP 1 did FROM #tmp_date ORDER BY did DESC)

SET @count_count_f = @count_first

WHILE @count_count_f <= @count_last
BEGIN

    INSERT INTO #tmp_balance_date([in_date], [dt], [id_store], [id_goods], [quantity], [Cost])
    SELECT @dt_max, @count_count_f, [id_store], [id_goods], sum([quantity]), sum([Cost])
	FROM
	(
	SELECT [id_store], [id_goods], [quantity], [Cost] FROM #tmp_balance_date
	WHERE dt = @max_count_date

	UNION ALL

	SELECT [id_store] ,[id_goods], [quantity], [Cost]  FROM [dbo].[lasmart_v_fact_movement]
	WHERE dt = @count_count_f

	) as bal
	GROUP BY [id_store], [id_goods]

	SET @max_count_date = @count_count_f

   SET @count_count_f = @count_count_f + 1

END;

DELETE FROM #tmp_balance_date WHERE dt = @max_date_in_balance 

INSERT INTO [lasmart_fact_total_month_balance]([date_final], [count_date], [id_store], [id_goods], [quantity_tot], [Cost_tot])
SELECT [in_date], [dt], [id_store], [id_goods], [quantity], [Cost] FROM #tmp_balance_date


EXEC [oth].[fill_SUP_LOG] @name = @name, @state_name = 'finish', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs


IF OBJECT_ID(N'tempdb..#tmp_date', N'U') IS NOT NULL
	DROP TABLE #tmp_date

IF OBJECT_ID(N'tempdb..#tmp_balance_date', N'U') IS NOT NULL
	DROP TABLE #tmp_balance_date

END
ELSE
BEGIN
--------ELSE-----------

DECLARE @top_value_date_final int
SET @top_value_date_final = (SELECT TOP 1 MAX(date_final) FROM [lasmart_fact_total_month_balance] )

WHILE @top_value_date_final >= @dt_max
BEGIN
   DELETE FROM [lasmart_fact_total_month_balance] WHERE date_final = @top_value_date_final
   SET @top_value_date_final = (SELECT TOP 1 MAX(date_final) FROM [lasmart_fact_total_month_balance] ) 
END;


EXEC [p_lasmart_fact_month_balance] @dt_min = @dt_min, @dt_max = @dt_max

END

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
