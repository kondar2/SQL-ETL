
ALTER PROCEDURE [dbo].[p_lasmart_plan_report] (@date_from int, @date_to int, @id_stores nvarchar(100))
	
AS
SET NOCOUNT ON;
BEGIN

DECLARE 
	@name varchar(500) = '[' + OBJECT_SCHEMA_NAME(@@PROCID) + '].[' + OBJECT_NAME(@@PROCID) + ']',
	@description varchar(500) = '[dbo].[lasmart_fact_balance_report]',
	@input_parametrs varchar(500) = N'@date_from =' + STR(@date_from) + '@date_to =' + STR(@date_to) + '@id_stores =' + @id_stores

begin try

EXEC [oth].[fill_sup_log] @name = @name, @state_name = 'start', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs



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

SELECT [dm] as 'Месяц', 
       s.[name] as 'Магазин',
	   h.[goodgroup_lvl1] as 'Категория номенклатуры',
	   sum(sum_sales) as 'Факт продаж',
	   sum([plan]) as 'План продаж',
	   sum([dev_pl]) as 'Отклонение от плана в ед',
	   iif(sum([plan]) != 0 and sum([sum_sales]) != 0,((sum([sum_sales]) - sum([plan])) / sum([plan])), 0) * 100 as 'Отклонение от плана в %',
	   sum(sum_sales) - sum([sum_sales_prev]) as 'Отклонение от факта продаж предыдущего года ед',
	   iif(sum([sum_sales_prev]) != 0 and sum([sum_sales]) != 0,((sum([sum_sales]) - sum([sum_sales_prev])) / sum([sum_sales_prev])), 0) * 100 as 'Отклонение от факта продаж предыдущего года %'
   
FROM (
SELECT d.tmid as [dm],
       c.[ID_Store] as [store_id],
	   t3.group_id as [goodgroup_id],
	   sum(c.Sale) as [sum_sales],
	   0 as [plan],
	   sum(c.Sale) as [dev_pl],
	   0 as [sum_sales_prev]
FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_v_fact_cheques] as c
left join [dbo].[lasmart_dim_date] as d
on c.dt = d.did
left join lasmart_dim_goods as t3
on c.ID_GOODS = t3.good_id
WHERE (c.dt BETWEEN @date_from and @date_to) and 
      (c.ID_Store in (SELECT [store_number] FROM #tmp_input_store ))
GROUP BY d.tmid,
		 c.[ID_Store],
		 t3.group_id

UNION ALL

SELECT t2.tmid as [dm],
       t1.store_id as [store_id],
	   t3.group_id as [goodgroup_id],
	   0 as [sum_sales],
	   sum(t1.[plan]) as [plan],
	   -sum(t1.[plan]) as [dev_pl],
	   sum(sum_sales) as [sum_sales_prev]
FROM lasmart_fact_plan_sales as t1
left join lasmart_dim_date as t2
on t1.dt = t2.did
left join lasmart_dim_goods as t3
on t1.good_id = t3.good_id
where (t1.dt between @date_from and @date_to) and 
      (t1.store_id in (SELECT [store_number] FROM #tmp_input_store ))
GROUP BY t2.tmid,
         t1.store_id,
		 t3.group_id

) as balanse_report
LEFT JOIN #tmp_hierarchy as h
on balanse_report.[goodgroup_id] = h.[goodgroup_id]
LEFT JOIN [dbo].[lasmart_dim_stores] as s
on balanse_report.store_id = s.store_id
GROUP BY [dm], 
         s.[name],
	     h.[goodgroup_lvl1]
ORDER BY [dm], 
         s.[name],
	     h.[goodgroup_lvl1]


EXEC [oth].[fill_SUP_LOG] @name = @name, @state_name = 'finish', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs


IF OBJECT_ID(N'tempdb..#tmp_input_store', N'U') IS NOT NULL
	DROP TABLE #tmp_input_store
IF OBJECT_ID(N'tempdb..#tmp_hierarchy', N'U') IS NOT NULL
	DROP TABLE #tmp_hierarchy

end try
begin catch
	EXEC [oth].[fill_SUP_LOG] @name = @name, @state_name = 'error', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs
    
IF OBJECT_ID(N'tempdb..#tmp_input_store', N'U') IS NOT NULL
	DROP TABLE #tmp_input_store
IF OBJECT_ID(N'tempdb..#tmp_hierarchy', N'U') IS NOT NULL
	DROP TABLE #tmp_hierarchy

	RETURN
end catch

END
