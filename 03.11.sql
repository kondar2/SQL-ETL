USE [OrganicNeva_Nekhvyadovich]
GO

/****** Object:  StoredProcedure [dbo].[_p_lasmart_fact_cheques]    Script Date: 02.11.2020 13:18:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE lasmart_fac_balance_of_goods(
[name_store] int,
[name_goodgroups] int,
[name_good] bigint,
[quantity] money,
[Cost] money
)
go

ALTER PROCEDURE [dbo].[_p_lasmart_fac_balance_of_goods] (@dt_max int, @id_store int)
	
AS
SET NOCOUNT ON;
BEGIN


declare @dt_min int
SET @dt_min = (SELECT min(dt) FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_v_fact_movement])

SELECT s.[name] as name_store, gg.[name] as name_goodgroups, g.[name] as name_good, Sum([quantity]) as quantity, sum([Cost]) as Cost
FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_v_fact_movement] as m
      INNER JOIN [lasmart_dim_stores] as s ON m.id_store = s.store_id
      INNER JOIN [lasmart_dim_goods] as g ON m.id_goods = g.good_id
	  INNER JOIN [lasmart_dim_goodgroups] as gg ON g.group_id = gg.goodgroup_id
WHERE (m.dt BETWEEN @dt_min AND @dt_max) and (m.[id_store] = @id_store)
GROUP BY s.[name], gg.[name], g.[name]



END
go

exec [_p_lasmart_fac_balance_of_goods] @dt_max = 20180131, @id_store = 1

TRUNCATE TABLE lasmart_fac_date_balance_of_goods

/*
Входные параметры Дата, Идентификатор магазина. 
Возвращаемые колокнки - Название магазина, Группа товаров, Номенклатура, Остаток шт, Остаток руб
*/


--создание календаря дат @начало @конец



CREATE TABLE #lasmart_fac_date_balance_of_goods(
[date_start] int,
[date_final] int,
[did] int,
[id_store] int,
[id_goods] bigint,
[quantity] money,
[Cost] money
)
go

declare @dt_min int
SET @dt_min = (SELECT min(dt) FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_v_fact_movement])
declare @dt_max int
SET @dt_max = 20180131
declare @id_store int
SET @id_store = 1


--CREATE TABLE #tmp_date(
--[date_start] int,
--[date_final] int,
--[did] int
--)
--go

-- создаем диапазон дат по справочнику dim_date
INSERT INTO #tmp_date([date_start], [date_final], [did])
SELECT distinct @dt_min, @dt_max, d.did FROM lasmart_dim_date as d
  inner join [dbo].[lasmart_v_fact_movement] as m on d.did = m.dt
  --join [dbo].[lasmart_dim_goods] 
WHERE d.did BETWEEN @dt_min AND @dt_max
order by d.did

SELECT * FROM #tmp_date


--поместить во временную таблицу с distinct d.did
--сделать переменную date_finish


--делаем join предыдущей таблицы >= по дате, в результате вычисляется остаток с @date_start до @date_finish
INSERT INTO #lasmart_fac_date_balance_of_goods([date_start], [date_final], [did], [id_store], [id_goods], [quantity], [Cost])
SELECT @dt_min, @dt_max, d.did, m.id_store, m.id_goods, m.quantity, m.Cost  FROM #tmp_date as d
  join [dbo].[lasmart_v_fact_movement] as m on d.did >= m.dt
--WHERE d.did BETWEEN @dt_min AND @dt_max
--group by d.did
ORDER BY d.did

SELECT * FROM #lasmart_fac_date_balance_of_goods





declare @dt_min int
SET @dt_min = (SELECT min(dt) FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_v_fact_movement])
declare @dt_max int
SET @dt_max = 20180131
declare @id_store int
SET @id_store = 1


--CREATE TABLE #tmp_day_balance(
--[did] int,
--[id_store] int,
--[id_goods] bigint,
--[quantity] money,
--[Cost] money
--)
--go

-- считаем остаток на день @final_day по товарам в магазине @id_store
INSERT INTO #tmp_day_balance([did], [id_store], [id_goods], [quantity], [Cost])
SELECT [did], [id_store], [id_goods], sum([quantity]), sum([Cost])
  FROM #lasmart_fac_date_balance_of_goods
  where id_store = @id_store and did = @dt_max  --and id_goods = 14169
  GROUP BY [did], [id_store], [id_goods]
  ORDER BY did


  SELECT * FROM #tmp_day_balance


  CREATE TABLE lasmart_fact_balance_date_interval(
[did] int,
[store_name] nvarchar(500),
[goodgroups_name] nvarchar(500),
[goods_name] nvarchar(500),
[quantity] money,
[Cost] money
)
go


INSERT INTO lasmart_fact_balance_date_interval ([did], [store_name], [goodgroups_name], [goods_name], [quantity], [Cost])
SELECT t.[did], s.[name], gg.[name], g.[name], [quantity], [Cost] 
FROM #tmp_day_balance as t
  INNER JOIN [dbo].[lasmart_dim_stores] as s ON t.id_store = s.store_id
  INNER JOIN [dbo].[lasmart_dim_goods] as g ON t.id_goods = g.good_id
  INNER JOIN [dbo].[lasmart_dim_goodgroups] as gg ON g.group_id = gg.goodgroup_id

/*
Входные параметры Дата, Идентификатор магазина. 
Возвращаемые колокнки - Название магазина, Группа товаров, Номенклатура, Остаток шт, Остаток руб
*/




---- считаем сумму за весь период от @begin до @finish
--SELECT [date_final], /*[did],*/ [id_store], [id_goods], sum([quantity]), sum([Cost])
--  FROM #lasmart_fac_date_balance_of_goods
--  where id_store = @id_store --and id_goods = 14169
--  GROUP BY [date_final], [id_store], [id_goods]
--  ORDER BY [id_goods]







