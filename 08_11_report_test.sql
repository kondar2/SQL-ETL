USE [OrganicNeva_Nekhvyadovich]
GO
/****** Object:  StoredProcedure [dbo].[p_lasmart_fact_balance_report]    Script Date: 08.11.2020 4:54:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DROP PROCEDURE [dbo].[p_lasmart_fact_balance_report]
ALTER PROCEDURE [dbo].[p_lasmart_fact_balance_report_test] (@dt int)
	
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
	@input_parametrs varchar(500) = N'@dt =' + STR(@dt) --+ ',' + ' @id_store =' + STR(@id_store)

begin try

EXEC [oth].[fill_sup_log] @name = @name, @state_name = 'start', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs

--выбрано 1вое число текущего месяца в остатках по месяцам
DECLARE @date_start int
SET @date_start = (SELECT max(date_final) FROM [dbo].[lasmart_fact_total_month_balance] WHERE date_final <= @dt)

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


--тестирование остатка на день
  SELECT sum([quantity]) as quant_move, sum([Cost]) as Cost_move
  FROM [dbo].[lasmart_v_fact_movement]
  WHERE [dt] BETWEEN 20180123 AND @dt

--тестирование остатка на день  
  SELECT sum([quantity]) as Cost_report, sum([Cost]) as Cost_report
  FROM #tbl_report
  

--остаток в #tbl_report, кол-во товаров
SELECT count([id_store]), count([id_goods]),SUM([quantity]), SUM([Cost])
FROM #tbl_report
WHERE [quantity] > 0


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

----остаток в отчете
SELECT COUNT(s.[name]) as [Название магазина],
	   COUNT(gg.[goodgroup_lvl2]) as [Группа товаров], 
	   COunt(g.[name]) as [Номенклатура], 
	   SUM(t.[quantity]) as [Остаток шт], 
	   SUM(t.[Cost]) as [Остаток руб]
FROM #tbl_report as t
  INNER JOIN [dbo].[lasmart_dim_stores] as s 
    ON t.id_store = s.store_id
  INNER JOIN [dbo].[lasmart_dim_goods] as g 
    ON t.id_goods = g.good_id
  INNER JOIN #tmp_hierarchy as gg 
    ON g.group_id = gg.goodgroup_id
WHERE t.[quantity] > 0

EXEC [oth].[fill_SUP_LOG] @name = @name, @state_name = 'finish', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs


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