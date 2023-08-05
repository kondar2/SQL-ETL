
ALTER PROCEDURE [dbo].[p_lasmart_plan_report_final] (@date_from int, @date_to int, @id_stores nvarchar(100))
	
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


CREATE TABLE #tmp_sales(
[dm] int,
[dt] int,
[store_id] int,
[good_id] int,
[sum_sales] money
)


INSERT INTO #tmp_sales([dm],
                       [dt], 
                       [store_id], 
					   [good_id], 
					   [sum_sales])
SELECT d.m,
       c.[dt],
	   c.[ID_Store],
	   c.[ID_GOODS],
	   sum(c.Sale)
FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_v_fact_cheques] as c
left join [dbo].[lasmart_dim_date] as d
on c.dt = d.did
WHERE c.dt BETWEEN @date_from and @date_to
GROUP BY d.m,
         c.[dt],
		 c.[ID_Store],
		 c.[ID_GOODS]

SELECT sum(sum_sales) FROM #tmp_sales where store_id = 1 or store_id = 12 or store_id = 14 or store_id = 15

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




SELECT */*t2.m as 'Год/Месяц',
       t6.[name] 'Магазин',
	   t5.[goodgroup_lvl1] as 'Категория номенклатуры',*/
       --sum(t1.sum_sales) as 'Факт продаж'
	   --ISNULL(sum(t3.[plan]), 0) as 'План продаж'
	   --ISNULL(ts.sum_sales - ps.[plan], 0) as 'Отклонение от плана ед',
	   --ISNULL(((ts.sum_sales - ps.[plan]) / ps.[plan])*100, 0) as 'Отклонение в %',
	   --ISNULL(ts.sum_sales - ps.[sum_sales], 0) as 'Отклонение от факта продаж предыдущего года'

FROM #tmp_sales as t1
LEFT JOIN lasmart_dim_date as t2
  ON t1.dt = t2.did
LEFT JOIN [dbo].[lasmart_fact_plan_sales] as t3
ON t2.m = t3.dm_rep and 
   --t1.good_id = t3.good_id and 
   t1.store_id = t3.store_id
/*LEFT JOIN lasmart_dim_goods as t4
  ON t1.good_id = t4.good_id
LEFT JOIN #tmp_hierarchy as t5 
    ON t4.group_id = t5.goodgroup_id
LEFT JOIN lasmart_dim_stores as t6
    ON t1.store_id = t6.store_id*/

WHERE (t1.store_id in (SELECT [store_number] FROM #tmp_input_store ))
--GROUP BY t2.m
/*         t6.[name], 
		 t5.[goodgroup_lvl1], 
		 t3.[plan]
	*/	 
ORDER BY t1.dt, t1.store_id, t1.good_id


EXEC [oth].[fill_SUP_LOG] @name = @name, @state_name = 'finish', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs


IF OBJECT_ID(N'tempdb..#tmp_input_store', N'U') IS NOT NULL
	DROP TABLE #tmp_input_store
IF OBJECT_ID(N'tempdb..#tmp_hierarchy', N'U') IS NOT NULL
	DROP TABLE #tmp_hierarchy
IF OBJECT_ID(N'tempdb..#tmp_sales', N'U') IS NOT NULL
	DROP TABLE #tmp_sales

end try
begin catch
	EXEC [oth].[fill_SUP_LOG] @name = @name, @state_name = 'error', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs
    
IF OBJECT_ID(N'tempdb..#tmp_input_store', N'U') IS NOT NULL
	DROP TABLE #tmp_input_store
IF OBJECT_ID(N'tempdb..#tmp_hierarchy', N'U') IS NOT NULL
	DROP TABLE #tmp_hierarchy
IF OBJECT_ID(N'tempdb..#tmp_sales', N'U') IS NOT NULL
	DROP TABLE #tmp_sales

	RETURN
end catch

END
