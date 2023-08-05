USE [OrganicNeva_Nekhvyadovich]
GO
/****** Object:  StoredProcedure [dbo].[p_lasmart_plan_report]    Script Date: 02.12.2020 2:30:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[p_lasmart_v_ABC_report] (@date_from int, @date_to int, @id_stores nvarchar(100))
--exec [p_lasmart_fact_ABC] @date_from = 20180202, @date_to = 20180502, @id_stores = '1,2,3,4,5'
--Пример запуска
AS
SET NOCOUNT ON;
BEGIN

DECLARE 
	@name varchar(500) = '[' + OBJECT_SCHEMA_NAME(@@PROCID) + '].[' + OBJECT_NAME(@@PROCID) + ']',
	@description varchar(500) = '[dbo].[p_lasmart_fact_ABC]',
	@input_parametrs varchar(500) = N'@date_from =' + STR(@date_from) + '@date_to =' + STR(@date_to) + '@id_stores =' + @id_stores

begin try

EXEC [oth].[fill_sup_log] @name = @name, @state_name = 'start', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs


--список подаваемых магазинов
CREATE TABLE #tmp_input_store (
[store_number] int
)


INSERT INTO #tmp_input_store (store_number)
SELECT CAST(value as int) 
FROM STRING_SPLIT(@id_stores, ',');


CREATE TABLE #tmp_hierarchy(
[goodgroup_id] int,
[goodgroup_lvl1] nvarchar(500),
[goodgroup_lvl2] nvarchar(500)
)

--Создание иерархии групп товаров
INSERT INTO #tmp_hierarchy([goodgroup_id], 
                           [goodgroup_lvl1], 
						   [goodgroup_lvl2])  
SELECT b.goodgroup_id, 
       a.[name], 
	   b.[name]
FROM  [dbo].[lasmart_dim_goodgroups] as a
inner join [dbo].[lasmart_dim_goodgroups] as b 
  ON b.parent_group = a.goodgroup_id
ORDER BY a.goodgroup_id,
         b.goodgroup_id


CREATE TABLE #tmp_sum(

group_id nvarchar(500),
sum_goods money
)
-- груп бай по категории товаров для расчета через окнонные ф-ии
INSERT INTO #tmp_sum
SELECT h.[goodgroup_lvl1],
       sum(c.Sale)
FROM [lasmart_v_fact_cheques] as c
LEFT JOIN lasmart_dim_goods as g
ON c.ID_GOODS = g.good_id
LEFT JOIN #tmp_hierarchy as h
on g.group_id = h.[goodgroup_id]
WHERE c.ID_Store in (SELECT [store_number] FROM #tmp_input_store) and 
(c.dt between @date_from and @date_to) and c.[CHEQUE_TYPE] = 'Продажа'
GROUP BY h.[goodgroup_lvl1]

TRUNCATE TABLE lasmart_v_ABC_report

INSERT INTO lasmart_v_ABC_report
SELECT t.group_id as 'Категория товаров',
       t.persent as 'Доля',
	   t.sum_prod / t.sum_all as 'Накопленная доля',
	   case
	     when t.sum_prod / t.sum_all < 0.8 then 'A'
		 when t.sum_prod / t.sum_all between 0.8 and 0.95 then 'B'
		 else 'C'
		 end as 'Тип группы'
FROM 
     (
		SELECT group_id, 
		       sum_goods,
				cast(sum_goods as float) / cast(sum(sum_goods) over() as float) as persent,
			   cast(sum(sum_goods) over(order by sum_goods DESC) as float) as sum_prod,
			   cast(sum(sum_goods) over()as float) as sum_all
	    FROM #tmp_sum
     ) as t

SELECT group_id as 'Категория товаров',
       share as 'Доля',
       accum_share as 'Накопленная доля',
       group_type  as 'Тип группы'
FROM [lasmart_v_ABC_report]

EXEC [oth].[fill_SUP_LOG] @name = @name, @state_name = 'finish', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs


IF OBJECT_ID(N'tempdb..#tmp_input_store', N'U') IS NOT NULL
	DROP TABLE #tmp_input_store
IF OBJECT_ID(N'tempdb..#tmp_hierarchy', N'U') IS NOT NULL
	DROP TABLE #tmp_hierarchy
IF OBJECT_ID(N'tempdb..#tmp_sum', N'U') IS NOT NULL
	DROP TABLE #tmp_sum

end try
begin catch
	EXEC [oth].[fill_SUP_LOG] @name = @name, @state_name = 'error', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs
    
IF OBJECT_ID(N'tempdb..#tmp_input_store', N'U') IS NOT NULL
	DROP TABLE #tmp_input_store
IF OBJECT_ID(N'tempdb..#tmp_hierarchy', N'U') IS NOT NULL
	DROP TABLE #tmp_hierarchy
IF OBJECT_ID(N'tempdb..#tmp_sum', N'U') IS NOT NULL
	DROP TABLE #tmp_sum

	RETURN
end catch

END
