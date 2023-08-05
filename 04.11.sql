
CREATE TABLE lasmart_fact_balance_date_interval(
[did] int,
[store_name] nvarchar(500),
[goodgroups_name] nvarchar(500),
[goods_name] nvarchar(500),
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
--declare @dt_max int
--SET @dt_max = 20180131
--declare @id_store int
--SET @id_store = 1

CREATE TABLE #tmp_date(
[date_start] int,
[date_final] int,
[did] int
)


-- создаем диапазон дат по справочнику dim_date
INSERT INTO #tmp_date([date_start], [date_final], [did])
SELECT distinct @dt_min, @dt_max, d.did FROM lasmart_dim_date as d
  inner join [dbo].[lasmart_v_fact_movement] as m on d.did = m.dt
  --join [dbo].[lasmart_dim_goods] 
WHERE d.did BETWEEN @dt_min AND @dt_max
order by d.did

--SELECT * FROM #tmp_date


--поместить во временную таблицу с distinct d.did
--сделать переменную date_finish

CREATE TABLE #lasmart_fac_date_balance_of_goods(
[date_start] int,
[date_final] int,
[did] int,
[id_store] int,
[id_goods] bigint,
[quantity] money,
[Cost] money
)


--делаем join предыдущей таблицы >= по дате, в результате вычисляется остаток с @date_start до @date_finish
INSERT INTO #lasmart_fac_date_balance_of_goods([date_start], [date_final], [did], [id_store], [id_goods], [quantity], [Cost])
SELECT @dt_min, @dt_max, d.did, m.id_store, m.id_goods, m.quantity, m.Cost  FROM #tmp_date as d
  join [dbo].[lasmart_v_fact_movement] as m on d.did >= m.dt
ORDER BY d.did

DROP TABLE #tmp_date
--SELECT * FROM #lasmart_fac_date_balance_of_goods


CREATE TABLE #tmp_day_balance(
[did] int,
[id_store] int,
[id_goods] bigint,
[quantity] money,
[Cost] money
)

-- считаем остаток на день @final_day по товарам в магазине @id_store
INSERT INTO #tmp_day_balance([did], [id_store], [id_goods], [quantity], [Cost])
SELECT [did], [id_store], [id_goods], sum([quantity]), sum([Cost])
  FROM #lasmart_fac_date_balance_of_goods
  where id_store = @id_store and did = @dt_max  --and id_goods = 14169
  GROUP BY [did], [id_store], [id_goods]
  ORDER BY did

  DROP TABLE #lasmart_fac_date_balance_of_goods
  --SELECT * FROM #tmp_day_balance


INSERT INTO lasmart_fact_balance_date_interval ([did], [store_name], [goodgroups_name], [goods_name], [quantity], [Cost])
SELECT t.[did], s.[name], gg.[name], g.[name], [quantity], [Cost] 
FROM #tmp_day_balance as t
  INNER JOIN [dbo].[lasmart_dim_stores] as s ON t.id_store = s.store_id
  INNER JOIN [dbo].[lasmart_dim_goods] as g ON t.id_goods = g.good_id
  INNER JOIN [dbo].[lasmart_dim_goodgroups] as gg ON g.group_id = gg.goodgroup_id

  DROP TABLE #tmp_day_balance

END
go

exec [dbo].[_p_lasmart_fac_balance_of_goods] @dt_max = 20180131, @id_store = 1