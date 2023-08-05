USE [OrganicNeva_Nekhvyadovich]
GO
/****** Object:  StoredProcedure [dbo].[p_lasmart_fact_balance_report]    Script Date: 11.11.2020 23:57:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DROP PROCEDURE [dbo].[p_lasmart_fact_balance_report]
ALTER PROCEDURE [dbo].[p_lasmart_plan_calculation] (@year int)
	
AS
SET NOCOUNT ON;
BEGIN
/*
Входные параметры Дата, Идентификатор магазина. 
Возвращаемые колокнки - Название магазина, Группа товаров, Номенклатура, Остаток шт, Остаток руб
*/

DECLARE 
	@name varchar(500) = '[' + OBJECT_SCHEMA_NAME(@@PROCID) + '].[' + OBJECT_NAME(@@PROCID) + ']',
	@description varchar(500) = '[dbo].[lasmart_fact_balance_report]',
	@input_parametrs varchar(500) = N'@year =' + STR(@year)

begin try

EXEC [oth].[fill_sup_log] @name = @name, @state_name = 'start', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs

CREATE TABLE #tbl_kef
(
store_id integer,
did int,
persent float
);

BULK
INSERT #tbl_kef
FROM 'C:\Lasmart\Nekhvyadovich\Plan2018_2019.txt'
WITH
(
FIRSTROW = 2,
FIELDTERMINATOR = ';',
ROWTERMINATOR = '\n'
)


SELECT * FROM #tbl_kef

/*
/*таблица планов */
CREATE TABLE lasmart_dim_plan_sales(
[id_store] int,
[goodgroup] int,
[dm] int,
[ds] int,
[df] int,
[sales] money,
[kef] int,
[plan] money
)
*/

/*
dim_plan_sales
kef
#tmp_month_sales

1) на вход год
2) SELECT в plan_sales кэфов 2019 
SUBSTRING (2019)
@month_start = 2019 + 01 @month_finish = 2019 + 12

3) SELECT в plan_sales продаж 2018
-- dm=201801, ds=20180101, <df=20180201
group by id_store

4) умножение = план 2019
*/

--создание таблиц дат для вычисления плана на год
CREATE TABLE #tbl_date(
[plan_dm] int,
[dm] int,
[ds] int,
[df] int
)

DECLARE 
@previous_year int = @year - 1,
@count_month int = 2,

@current_month int,
@previous_month int,
@day_start int,
@day_finish int


WHILE @count_month <= 13
BEGIN
IF @count_month = 13
BEGIN
SET @current_month = CONCAT(@year, (REPLACE(STR(@count_month - 1,2),' ','0')))
SET @previous_month = CONCAT(@previous_year, (REPLACE(STR(@count_month - 1,2),' ','0')))
SET @day_start = CONCAT(@previous_year, (REPLACE(STR(@count_month - 1,2),' ','0')), '01')
SET @day_finish = CONCAT(@year, '01', '01')
INSERT INTO #tbl_date([plan_dm], [dm], [ds], [df]) VALUES (@current_month, @previous_month, @day_start, @day_finish)
break
END


SET @current_month = CONCAT(@year, (REPLACE(STR(@count_month - 1,2),' ','0')))
SET @previous_month = CONCAT(@previous_year, (REPLACE(STR(@count_month - 1,2),' ','0')))
SET @day_start = CONCAT(@previous_year, (REPLACE(STR(@count_month - 1,2),' ','0')), '01')
SET @day_finish = CONCAT(@previous_year, (REPLACE(STR(@count_month,2),' ','0')), '01')

INSERT INTO #tbl_date([plan_dm], [dm], [ds], [df]) VALUES (@current_month, @previous_month, @day_start, @day_finish)

SET @count_month = @count_month + 1

END

SELECT * FROM #tbl_date


CREATE TABLE #tbl_date_kef(
[id_str] INT IDENTITY(1,1),
[plan_dm] int, 
[dm] int, 
[ds] int, 
[df] int, 
[store_id] int, 
[kef] float
)

--добавление магазинов и кэфов к датам
INSERT INTO #tbl_date_kef([plan_dm], [dm], [ds], [df], [store_id], [kef])
SELECT d.[plan_dm], d.[dm], d.[ds], d.[df], T.store_id, T.persent
FROM #tbl_date as d 
CROSS APPLY 
(
SELECT k.store_id, k.persent 
FROM #tbl_kef as k 
WHERE d.plan_dm = k.did
) as T
ORDER BY d.plan_dm, T.store_id



--добавление продаж
DECLARE @max_rows_plan int = (SELECT MAX([id_str]) FROM #tbl_date_kef),
        @count_row int = 1,

		@store_id int,
	    @ds int,
		@df int

WHILE @count_row <= @max_rows_plan
BEGIN
SELECT  @store_id = store_id, 
        @ds = ds,
        @df = df
FROM #tbl_date_kef
WHERE [id_str] = @count_row

DECLARE @last_day int = (SELECT TOP 1 MAX(did) FROM [dbo].[lasmart_dim_date] WHERE did < @df)


INSERT INTO [lasmart_dim_plan_sales]([plan_dm], 
                                     [dm], 
									 [ds], 
									 [df], 
									 [store_id], 
									 [kef], 
									 [sum_sales], 
									 [plan])
SELECT k.[plan_dm], 
       k.[dm], 
       k.[ds], 
       k.[df], 
       k.[store_id], 
       k.[kef], 
       sum(ABS(m.[Cost])), 
       sum(ABS(m.[Cost])) * k.[kef]

--sum(ABS(m.[Cost])) as sum_sales
FROM [dbo].[lasmart_v_fact_movement] as m
   INNER JOIN #tbl_date_kef as k ON m.id_store = k.store_id and m.dt = k.ds
WHERE dt BETWEEN @ds and @last_day and [OperTypeID] = 'Продажа' and m.[id_store] = @store_id
GROUP BY k.[plan_dm], 
       k.[dm], 
       k.[ds], 
       k.[df], 
       k.[store_id], 
       k.[kef]




--------------------------
SET @count_row = @count_row + 1
END


/*
CROSS APPLY
(
SELECT [good_id],
	   sum([sum_sales]) as sum_sales
FROM (

--SELECT [store_id], 
--       [good_id],
--	   [sum_sales]
--FROM [dbo].[lasmart_dim_plan_sales]
--WHERE [ds] = @ds


--UNION ALL

SELECT [id_store], 
       [id_goods],
	   ABS([Cost])
FROM [dbo].[lasmart_v_fact_movement]
WHERE dt BETWEEN @ds and @last_day and [OperTypeID] = 'Продажа'

) as balanse_month
WHERE ps.[store_id] = balanse_month.store_id and ps.[ds] = @ds
GROUP BY [store_id], 
	     [good_id]
) as SS

*/


--CROSS APPLY
--(
--SELECT [good_id],
--	   sum([sum_sales]) as sum_sales
--FROM (

--SELECT [ds],
--       [store_id], 
--       [good_id],
--	   [sum_sales]
--FROM [dbo].[lasmart_dim_plan_sales]
--WHERE [ds] = @ds and [store_id] = @store_id


--UNION ALL

--SELECT @ds,
--       [id_store], 
--       [id_goods],
--	   ABS([Cost])
--FROM [dbo].[lasmart_v_fact_movement]
--WHERE dt BETWEEN @ds and @last_day and [id_store] = @store_id and [OperTypeID] = 'Продажа'

--) as balanse_month
--WHERE ps.[store_id] = balanse_month.store_id and ps.ds = balanse_month.[ds]
--GROUP BY [ds],
--         [store_id], 
--	     [good_id]
--) as SS










----------------------------




--INSERT INTO lasmart_dim_plan_sales ([sum_sales])
--SELECT id_store, id_goods, sum(Cost)
--FROM(
--SELECT [id_store], 
--       [id_goods],
--	   [Cost]
--FROM [dbo].[lasmart_v_fact_movement]
--WHERE [id_store] = @store_id and dt BETWEEN @ds and @last_day
--) as sum_sales
--WHERE [store_id] = @store_id

--SET @count_row = @count_row + 1
--END







--SELECT [id_store], 
--       [id_goods],
--	   [Cost]
--FROM [dbo].[lasmart_v_fact_movement]
--WHERE [id_store] = @store_id and dt BETWEEN @ds and @last_day



/*
    ,[good_id]
      ,[sum_sales]
      ,[plan]
*/




--------------------------------------=======================================
/*

--входящее значение
DECLARE @move_month_1 int
SET @move_month_1 = 201901
--SELECT SUBSTRING(STR(@move_month_1), 9, 2)

--уменьшение года на 1 для поиска в вьюхе move
DECLARE @inc_year int
SET @inc_year = SUBSTRING(STR(@move_month_1), 8, 1) - 1
--SELECT @inc_year

--конкатенация кусков
DECLARE @move_month int
SET @move_month = CONCAT(SUBSTRING(STR(@move_month_1), 5, 3), (SUBSTRING(STR(@move_month_1), 8, 1) - 1), SUBSTRING(STR(@move_month_1), 9, 2))
SELECT @move_month


--запрос для рассчета суммы продаж по группам товаров за месяц
SELECT g.[group_id], 
       ABS(SUM(m.quantity)) as прошлогоднее_колво_продаж, 
	   ABS(SUM(m.Cost)) as прошлогодняя_сумма_продаж
FROM [lasmart_v_fact_movement] as m
   INNER JOIN lasmart_dim_date as d 
     ON m.dt = d.did
   INNER JOIN [dbo].[lasmart_dim_goods] as g 
    ON m.id_goods = g.good_id
   
WHERE m.[OperTypeID] = 'Продажа' and d.m = 201801--@move_month
GROUP BY gg.[goodgroup_lvl2]










*/





EXEC [oth].[fill_SUP_LOG] @name = @name, @state_name = 'finish', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs

-- товары без групп
/*
SELECT distinct id_goods as g_m, good_id as g_g FROM [dbo].[lasmart_v_fact_movement] 
  LEFT JOIN lasmart_dim_goods ON id_goods = good_id
  WHERE good_id is null


  SELECT * FROM [dbo].[lasmart_v_fact_movement] 
  WHERE id_goods = 20668
*/
--exec [p_lasmart_fact_balance_report] @dt = 20190801, @id_store = 18

IF OBJECT_ID(N'tempdb..#tbl_date', N'U') IS NOT NULL
	DROP TABLE #tbl_date
IF OBJECT_ID(N'tempdb..#tbl_kef', N'U') IS NOT NULL
	DROP TABLE #tbl_kef


end try
begin catch
	EXEC [oth].[fill_SUP_LOG] @name = @name, @state_name = 'error', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs
    
IF OBJECT_ID(N'tempdb..#tbl_kef', N'U') IS NOT NULL
	DROP TABLE #tbl_kef

	RETURN
end catch

END