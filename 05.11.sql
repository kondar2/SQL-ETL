CREATE TABLE lasmart_fact_month_balance(
[date_final] int, --баланс на это число
[id_store] int, 
[id_goods] bigint, 
[quantity] money, 
[Cost] money
)
go

DROP TABLE lasmart_fact_month_balance
-- min 20190301   max 20190401

ALTER PROCEDURE [dbo].[p_lasmart_fac_month_balance] (@dt_min int, @dt_max int)
	
AS
SET NOCOUNT ON;
BEGIN

DECLARE 
	@name varchar(500) = '[' + OBJECT_SCHEMA_NAME(@@PROCID) + '].[' + OBJECT_NAME(@@PROCID) + ']',
	@description varchar(500) = 'lasmart_fact_month_balance',
	@input_parametrs varchar(500) = N'[@dt_min =' + STR(@dt_min) + ',' + ' @dt_max =' + STR(@dt_max) +']'

begin try

EXEC [oth].[fill_sup_log] @name = @name, @state_name = 'start', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs


IF @dt_max not in (SELECT [date_final] FROM lasmart_fact_month_balance)
BEGIN

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

-- удаляем первое числo следующего месяца
DELETE FROM #tmp_date WHERE [did] in(SELECT MAX([did]) FROM #tmp_date) 

--DROP TABLE #tmp_balance_date

CREATE TABLE #tmp_balance_date(
[date_final] int,
[did] int,
[dt] int,
[id_store] int,
[id_goods] bigint,
[quantity] money,
[Cost] money
)


--делаем join  таблицы move >= по дате, в результате вычисляется остаток на последний день месяца
INSERT INTO #tmp_balance_date([date_final], [did], [dt], [id_store], [id_goods], [quantity], [Cost])
SELECT @dt_max, d.did, m.dt, m.id_store, m.id_goods, m.quantity, m.Cost  FROM #tmp_date as d
  inner join [dbo].[lasmart_v_fact_movement] as m on d.did >= m.dt
WHERE m.dt in (SELECT [did] FROM #tmp_date) and d.did in (SELECT MAX([did]) FROM #tmp_date)
ORDER BY d.did , m.dt

DROP TABLE #tmp_date



INSERT INTO lasmart_fact_month_balance([date_final], [id_store], [id_goods], [quantity], [Cost])
		SELECT [date_final], [id_store], [id_goods], sum([quantity]), sum([Cost])
		FROM #tmp_balance_date
		GROUP BY date_final, [id_store], [id_goods]


EXEC [oth].[fill_SUP_LOG] @name = @name, @state_name = 'finish', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs

DROP TABLE #tmp_balance_date

END
ELSE
BEGIN
EXEC [oth].[fill_SUP_LOG] @name = @name, @state_name = 'finish', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs
RETURN
END

 --SELECT * FROM sys.objects

--tempdb..#temp_buf_tbl
IF OBJECT_ID(N'[dbo].[OrganicNeva_Nekhvyadovich]', N'U') IS NOT NULL
	DROP TABLE #temp_buf_tbl
end try
begin catch
	EXEC [oth].[fill_SUP_LOG] @name = @name, @state_name = 'error', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs
	IF OBJECT_ID(N'[dbo].[OrganicNeva_Nekhvyadovich]', N'U') IS NOT NULL
	--tempdb..
		DROP TABLE #temp_buf_tbl
	RETURN
end catch




END
go


exec [dbo].[p_lasmart_fac_month_balance] @dt_min = 20190601, @dt_max = 20190701



SELECT [id_store], [id_goods], sum([quantity]), sum([Cost]) FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_v_fact_movement]
where (dt BETWEEN 20190501 and 20190531) and ([id_store] = 16 and [id_goods] = 880)
GROUP BY [id_store], [id_goods]

--


SELECT [id_store], [id_goods], sum([quantity]), sum([Cost]) FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_v_fact_movement]
where (dt BETWEEN 20190701 and 20190731) and ([id_store] = 18 and [id_goods] = 62)
GROUP BY [id_store], [id_goods]


SELECT [id_store], [id_goods], [quantity], [Cost] FROM [lasmart_fact_month_balance]
where [date_final] = 20190801 and ([id_store] = 18 and [id_goods] = 62)
--
SELECT [id_store], [id_goods], sum([quantity]), sum([Cost]) FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_v_fact_movement]
where (dt BETWEEN 20190701 and 20190731) and ([id_store] = 28 and [id_goods] = 15244)
GROUP BY [id_store], [id_goods]


SELECT [id_store], [id_goods], [quantity], [Cost] FROM [lasmart_fact_month_balance]
where [date_final] = 20190801 and ([id_store] = 28 and [id_goods] = 15244)
--
SELECT [id_store], [id_goods], sum([quantity]), sum([Cost]) FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_v_fact_movement]
where (dt BETWEEN 20190801 and 20190831) and ([id_store] = 20 and [id_goods] = 7427)
GROUP BY [id_store], [id_goods]


SELECT [id_store], [id_goods], [quantity], [Cost] FROM [lasmart_fact_month_balance]
where [date_final] = 20190901 and ([id_store] = 20 and [id_goods] = 7427)
--
SELECT [id_store], [id_goods], sum([quantity]), sum([Cost]) FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_v_fact_movement]
where (dt BETWEEN 20190801 and 20190831) and ([id_store] = 22 and [id_goods] = 8169)
GROUP BY [id_store], [id_goods]


SELECT [id_store], [id_goods], [quantity], [Cost] FROM [lasmart_fact_month_balance]
where [date_final] = 20190901 and ([id_store] = 22 and [id_goods] = 8169)
--

--GROUP BY [id_store], [id_goods]

--
SELECT [id_store], [id_goods], sum([quantity]), sum([Cost]) FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_v_fact_movement]
where (dt BETWEEN 20190801 and 20190831) and ([id_store] = 24)
GROUP BY [id_store], [id_goods]


SELECT  [date_final], [id_store], [id_goods], COUNT([id_goods])
FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_fact_month_balance]
GROUP BY [date_final], [id_store], [id_goods]
--HAVING [date_final] = 20190801
ORDER BY date_final
  


SELECT [date_final], [id_store], [quantity], [Cost], [id_goods] 
FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_fact_month_balance]
WHERE [id_store] = 24 and [id_goods] = 62
