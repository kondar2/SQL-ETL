exec [p_lasmart_plan_calculation] 2019



CREATE TABLE lasmart_dim_plan_sales(
[plan_dm] int, 
[dm] int,
[ds] int,
[df] int,
[store_id] int,
[good_group_id] int,
[kef] float,
[sum_sales] money,
[plan] money
)


SELECT * FROM lasmart_dim_plan_sales
WHERE sum_sales is not null

SELECT CAST(sum([sum_sales]) AS money)
  FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_dim_plan_sales]
  WHERE dm = 201802


  SELECT sum(ABS([Cost]))
  FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_v_fact_movement]
  WHERE OperTypeID = 'Продажа' and dt BETWEEN 20180201 and 20180228
--
SELECT CAST(sum([sum_sales]) AS money)
  FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_dim_plan_sales]
  


  SELECT sum(ABS([Cost]))
  FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_v_fact_movement]
  WHERE OperTypeID = 'Продажа' and dt BETWEEN 20180123 and 20181231
--


SELECT distinct id_goods as g_m, good_id as g_g FROM [dbo].[lasmart_v_fact_movement] 
  LEFT JOIN lasmart_dim_goods ON id_goods = good_id
  WHERE good_id is null


  SELECT * FROM [dbo].[lasmart_v_fact_movement] 
  WHERE id_goods = 20668 or id_goods = 0




truncate TABLE lasmart_dim_plan_sales






DROP TABLE lasmart_dim_plan_sales
--актуальная
CREATE TABLE lasmart_dim_plan_sales(
[ds] int,
[df] int,
[store_id] int,
[good_group] int,
[kef] float,
[sum_sales] money,
[plan] money
)





SELECT CAST(sum([sum_sales]) AS money)
  FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_dim_plan_sales]
  WHERE ds = 20180201






  SELECT sum(ABS([Cost]))
  FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_v_fact_movement]
  WHERE OperTypeID = 'Продажа' and dt BETWEEN 20180201 and 20180228



  SELECT g.group_id, sum(ABS(m.[Cost]))
FROM [dbo].[lasmart_v_fact_movement] as m
   INNER JOIN lasmart_dim_goods as g
   ON m.id_goods = g.good_id
WHERE m.dt BETWEEN 20180201 and 20180228 and m.[OperTypeID] = 'Продажа' and m.id_store = 1
GROUP BY g.group_id



  ---======================== plan_report

  exec [p_lasmart_plan_report_test] @date_from = 201901, @date_to = 201912, @id_stores = '1,12,14,15'

  exec [p_lasmart_plan_report_final] @date_from = 201901, @date_to = 201912, @id_stores = '1,12,14,15'

 SELECT sum(Sale)
FROM [dbo].[lasmart_v_fact_cheques]
WHERE dt between 20190101 and 20191231



SELECT * FROM lasmart_dim_plan_sales
WHERE sum_sales is not null




--факт по месяцу
SELECT @ds, @df, @store_id, g.group_id, sum(ABS(m.[Cost]))
FROM [dbo].[lasmart_v_fact_movement] as m
   INNER JOIN lasmart_dim_goods as g
   ON m.id_goods = g.good_id
WHERE m.dt BETWEEN @ds and @last_day and m.[OperTypeID] = 'Продажа' and m.id_store = @store_id --and m.quantity > 0
GROUP BY g.group_id


--=================================16.11

 exec [dbo].[p_lasmart_plan_calculation_2] 'C:\Lasmart\Nekhvyadovich\Plan2018_2019.txt'
  exec [dbo].[p_lasmart_plan_calculation] 'C:\Lasmart\Nekhvyadovich\Plan2018_2019.txt'



 SELECT 'C:\Lasmart\Nekhvyadovich\Plan2018_2019.txt'

 
 SELECT sum(Sale)
FROM [dbo].[lasmart_v_fact_cheques]
WHERE dt between 20180101 and 20181231
 
 SELECT sum([sum_sales])
FROM lasmart_fact_plan_sales


CREATE TABLE lasmart_fact_plan_sales(
  [d_rep] int,
[d_plan] int,
[store_id] int,
[good_group] int,
[kef] float,
[sum_sales] money,
[plan] money
)

SELECT 
      sum([sum_sales])
      
  FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_dim_plan_sales]
  --ORDER BY [dm]

  TRUNCATE TABLE [dbo].[lasmart_fact_plan_sales]

  DROP TABLE [dbo].[lasmart_fact_plan_sales]

  -----тест плана

 SELECT sum([sum_sales])
 FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_fact_plan_sales]
  
SELECT sum(Sale)
FROM [dbo].[lasmart_v_fact_cheques]
WHERE dt between 20180101 and 20181231

-- тест отчета 

  exec [p_lasmart_plan_report_test] @date_from = 201901, @date_to = 201912, @id_stores = '1,12,14,15'


  SELECT sum(Sale) as 'продажи из вью'
FROM [dbo].[lasmart_v_fact_cheques]
WHERE dt between 20190101 and 20191231


  exec [p_lasmart_plan_report_final] @date_from = 201901, @date_to = 201912, @id_stores = '1,12,14,15'


  --17.11 PLAN

--CREATE TABLE lasmart_fact_plan_sales(
--[month_sourse_id] int,
--[dt] int,
--[store_id] int,
--[good_id] int,
--[kef] float,
--[sum_sales] money,
--[plan] money
--)


CREATE TABLE lasmart_fact_plan_sales(
[dt] int,
[store_id] int,
[good_id] int,
[kef] float,
[sum_sales] money,
[plan] money
)


 exec [dbo].[p_lasmart_plan_calculation] 'C:\Lasmart\Nekhvyadovich\Plan2018_2019.txt'


-- тест плана 
 SELECT sum([sum_sales])
 FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_fact_plan_sales]
  
SELECT sum(Sale)
FROM [dbo].[lasmart_v_fact_cheques]
WHERE dt between 20180101 and 20181231


  exec [p_lasmart_plan_report] @date_from = 20190101, @date_to = 20191231, @id_stores = '1,12,14,15'


  SELECT sum(Sale)
FROM [dbo].[lasmart_v_fact_cheques]
WHERE (dt between 20190101 and 20191231) and ([ID_Store] = '1' or [ID_Store] = '12' or [ID_Store] = '14' or [ID_Store] = '15')



  exec [p_lasmart_plan_report_test] @date_from = 20190101, @date_to = 20191231, @id_stores = '1,12,14,15'


  SELECT sum(Sale) as 'продажи из вью'
FROM [dbo].[lasmart_v_fact_cheques]
WHERE dt between 20190101 and 20191231 and (ID_Store = 1 or ID_Store = 12 or ID_Store = 14 or ID_Store = 15)













SELECT d.m as [dm],
       c.[ID_Store] as [store_id],
	   t3.group_id as [goodgroup_id],
	   sum(c.Sale) as [sum_sales],
	   0 as [plan],
	   sum(c.Sale) as [otk_ed]

FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_v_fact_cheques] as c
left join [dbo].[lasmart_dim_date] as d
on c.dt = d.did
left join lasmart_dim_goods as t3
on c.ID_GOODS = t3.good_id
WHERE (c.dt BETWEEN 20190101 and 20191231) and 
      ([ID_Store] = '1' or [ID_Store] = '12' or [ID_Store] = '14' or [ID_Store] = '15')
GROUP BY d.m,
		 c.[ID_Store],
		 t3.group_id
ORDER BY d.m,
		 c.[ID_Store],
		 t3.group_id

SELECT t2.m as [dm],
       t1.store_id as [store_id],
	   t3.group_id as [goodgroup_id],
	   0 as [sum_sales],
	   sum(t1.[plan]) as [plan],
	   -sum(t1.[sum_sales]) as [otk_ed]
FROM lasmart_fact_plan_sales as t1
left join lasmart_dim_date as t2
on t1.dt = t2.did
left join lasmart_dim_goods as t3
on t1.good_id = t3.good_id
where (t1.dt between 20190101 and 20191231) and 
      ([store_id] = '1' or [store_id] = '12' or [store_id] = '14' or [store_id] = '15')
GROUP BY t2.m,
         t1.store_id,
		 t3.group_id
ORDER BY t2.m,
         t1.store_id,
		 t3.group_id