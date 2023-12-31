USE [OrganicNeva_Nekhvyadovich]
GO
/****** Object:  StoredProcedure [dbo].[_p_lasmart_fact_month_balance]    Script Date: 08.11.2020 3:42:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--запуск в формате @dt_min = 01.??.????, @dt_max = 01.??.????  (остаток на @dt_max)
ALTER PROCEDURE [dbo].[p_lasmart_fact_month_balance_final] (@dt_min int, @dt_max int)
	
AS
SET NOCOUNT ON;
BEGIN

DECLARE 
	@name varchar(500) = '[' + OBJECT_SCHEMA_NAME(@@PROCID) + '].[' + OBJECT_NAME(@@PROCID) + ']',
	@description varchar(500) = 'lasmart_fact_month_balance',
	@input_parametrs varchar(500) = N'@dt_min =' + STR(@dt_min) + ',' + ' @dt_max =' + STR(@dt_max)

begin try

EXEC [oth].[fill_sup_log] @name = @name, @state_name = 'start', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs

--удаляем данные из таблицы, дата которых больше @dt_min
DELETE FROM [lasmart_fact_total_month_balance] 
WHERE date_final > @dt_min


--создаю таблицу дат в которую входят @dt_min, первые числа месяцев, на которые рассчитывается остаток, @dt_max
CREATE TABLE #tmp_first_days_of_months(
[id_day] INT IDENTITY(1,1),
[first_day] int
)

INSERT INTO #tmp_first_days_of_months([first_day])
SELECT distinct did 
FROM lasmart_dim_date
WHERE did BETWEEN @dt_min AND @dt_max and 
      SUBSTRING(STR(did), 9, 2) = '01' OR 
	  did = @dt_min OR 
	  did = @dt_max
order by did

--для цикла
DECLARE @day_start int
DECLARE @day_count int
DECLARE @id_day_count int
--для UNION ALL
DECLARE @last_day int
DECLARE @last_balance_day int


SET @day_start = @dt_min
SET @id_day_count = 2
SET @day_count = (SELECT [first_day] FROM #tmp_first_days_of_months WHERE id_day = @id_day_count)


WHILE @day_start <> @dt_max
BEGIN

SET @last_day = (SELECT TOP 1 MAX(did) FROM [dbo].[lasmart_dim_date] WHERE did < @day_count)
SET @last_balance_day = (SELECT TOP 1 Max(date_final) FROM [lasmart_fact_total_month_balance])


INSERT INTO [lasmart_fact_total_month_balance]([date_final],
                                               [id_store], 
											   [id_goods], 
											   [quantity_tot], 
											   [Cost_tot])
SELECT @day_count, 
       [id_store], 
	   [id_goods], 
	   sum([quantity_tot]) as [quantity], 
	   sum([Cost_tot]) as [Cost] 
FROM (

SELECT [id_store], 
       [id_goods], 
	   [quantity_tot], 
	   [Cost_tot]
FROM [dbo].[lasmart_fact_total_month_balance]
WHERE [date_final] = @last_balance_day


UNION ALL

SELECT [id_store], 
       [id_goods], 
       [quantity],
	   [Cost]
FROM [dbo].[lasmart_v_fact_movement]
WHERE dt BETWEEN @day_start and @last_day

) as balanse_month
GROUP BY [id_store], 
         [id_goods]

SET @day_start = (SELECT [first_day] FROM #tmp_first_days_of_months WHERE id_day = @id_day_count)
SET @id_day_count = @id_day_count + 1 
SET @day_count = (SELECT [first_day] FROM #tmp_first_days_of_months WHERE id_day = @id_day_count)

END


EXEC [oth].[fill_SUP_LOG] @name = @name, @state_name = 'finish',@sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs

IF OBJECT_ID(N'tempdb..#tmp_first_days_of_months', N'U') IS NOT NULL
	DROP TABLE #tmp_first_days_of_months

end try
begin catch
	EXEC [oth].[fill_SUP_LOG] @name = @name, @state_name = 'error', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs

IF OBJECT_ID(N'tempdb..#tmp_first_days_of_months', N'U') IS NOT NULL
	DROP TABLE #tmp_first_days_of_months

	RETURN
end catch


END
