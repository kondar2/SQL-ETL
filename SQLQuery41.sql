USE [OrganicNeva_Nekhvyadovich]
GO
/****** Object:  StoredProcedure [dbo].[p_lasmart_fact_balance_report]    Script Date: 03.12.2020 13:30:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DROP PROCEDURE [dbo].[p_lasmart_fact_balance_report]
ALTER PROCEDURE [dbo].[p_lasmart_fact_balance_report] (@dt int, @id_store int)
	
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
	@input_parametrs varchar(500) = N'@dt =' + STR(@dt) + ',' + ' @id_store =' + STR(@id_store)

begin try

EXEC [oth].[fill_sup_log] @name = @name, @state_name = 'start', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs




--выбрано 1вое число текущего месяца в остатках по месяцам
DECLARE @date_start int
SET @date_start = SUBSTRING(STR(@dt), 3, 6) + '01'

--таблица остатков на текущую дату (для отчета)
CREATE TABLE #tbl_report(
[id_store] int,
[id_goods] bigint,
[quantity] money,
[Cost] money
)


INSERT INTO #tbl_report([id_store], 
                        [id_goods], 
						[quantity], 
						[Cost])
SELECT [id_store], 
       [id_goods], 
	   sum([quantity_tot]) as [quantity], 
	   sum([Cost_tot]) as [Cost] 
FROM (

SELECT [id_store], 
       [id_goods], 
	   [quantity_tot], 
	   [Cost_tot]
FROM [dbo].[lasmart_fact_total_month_balance]
WHERE [date_final] = @date_start


UNION ALL

SELECT [id_store], 
       [id_goods], 
	   [quantity], 
	   [Cost]
FROM [dbo].[lasmart_v_fact_movement]
WHERE dt BETWEEN @date_start and @dt

) as balanse_report
GROUP BY [id_store], 
         [id_goods]


--SELECT SUM([quantity]), sum([Cost])
--FROM #tbl_report


CREATE TABLE #tmp_hierarchy(
[goodgroup_id] int,
[goodgroup_lvl1] nvarchar(500),
[goodgroup_lvl2] nvarchar(500)
)

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

SELECT s.[name] as [Название магазина],
	   gg.[goodgroup_lvl2] as [Группа товаров], 
	   g.[name] as [Номенклатура], 
	   t.[quantity] as [Остаток шт], 
	   t.[Cost] as [Остаток руб]
FROM #tbl_report as t
  INNER JOIN [dbo].[lasmart_dim_stores] as s 
    ON t.id_store = s.store_id
  INNER JOIN [dbo].[lasmart_dim_goods] as g 
    ON t.id_goods = g.good_id
  INNER JOIN #tmp_hierarchy as gg 
    ON g.group_id = gg.goodgroup_id
WHERE t.[id_store] = @id_store and 
      t.[quantity] > 0
ORDER BY s.[name],
		 gg.[goodgroup_lvl2]

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

IF OBJECT_ID(N'tempdb..#tmp_hierarchy', N'U') IS NOT NULL
	DROP TABLE #tmp_hierarchy

IF OBJECT_ID(N'tempdb..#tbl_report', N'U') IS NOT NULL
	DROP TABLE #tbl_report
 
end try
begin catch
	EXEC [oth].[fill_SUP_LOG] @name = @name, @state_name = 'error', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs
    
IF OBJECT_ID(N'tempdb..#tbl_report', N'U') IS NOT NULL
	DROP TABLE #tbl_report

IF OBJECT_ID(N'tempdb..#tmp_hierarchy', N'U') IS NOT NULL
	DROP TABLE #tmp_hierarchy
 
	RETURN
end catch

END