/****** Скрипт для команды SelectTopNRows из среды SSMS  ******/
SELECT [date_final], [id_store], [id_goods], sum([quantity]), sum([Cost])
  FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_fact_month_balance]
  GROUP BY [date_final], [id_store] ,[id_goods]
  --HAVING id_store IN ()
  ORDER BY  [date_final], [id_store], [id_goods]


  SELECT [date_final]
      ,[id_store]
      ,[id_goods]
      ,[quantity_tot]
      ,[Cost_tot]
  FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_fact_total_month_balance]
  WHERE [id_store] = 22 and [id_goods] = 10435
   ORDER BY [date_final]
   
   
   
   
   SELECT [id_store], [id_goods], sum(quantity), sum(Cost) 
   FROM [dbo].[lasmart_v_fact_movement]
   inner join 


   SELECT tt.* /*count(tt.id_goods)*/ --tt.[date_final], tt.id_goods, tt.id_store, tt.[quantity_tot], tt.[Cost_tot]
   FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_fact_total_month_balance] as tt
   INNER JOIN
   (SELECT max([date_final]) as max_date ,[id_store] as store ,[id_goods] as good
	  FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_fact_total_month_balance]
	  GROUP BY /*tt.[date_final],*/ [id_store] ,[id_goods]
    ) as gr
	ON tt.[date_final] = gr.max_date and tt.id_store = gr.store AND tt.id_goods = gr.good
	--GROUP BY tt.[date_final], tt.id_goods, tt.id_store

   Where (dt BETWEEN 20190601 AND 20190901) and id_store = 22 and id_goods = 10435
   group by [id_store], [id_goods]
   --ORDER BY dt

   --

--   SELECT m.[date_final], m.id_store, m.id_goods, m.[quantity_tot], m.[Cost_tot]               -- get the row that contains the max value
--FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_fact_total_month_balance] m                 -- "m" from "max"
--    LEFT JOIN [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_fact_total_month_balance] b        -- "b" from "bigger"
--        ON m.[date_final] < b.[date_final] and m.id_store = b.id_store AND m.id_goods = b.id_goods
--WHERE b.[date_final] IS NULL
----GROUP BY m.[date_final], m.id_store, m.id_goods
--ORDER BY m.id_goods, m.id_store


--  SELECT [id_store], [id_goods], sum([quantity]), sum([Cost])
--  FROM [dbo].[lasmart_v_fact_movement]
--  WHERE ([dt] BETWEEN 20190601 AND 20190831)
--  GROUP BY [id_store], [id_goods]
--  ORDER BY [id_goods], [id_store]

  SELECT [date_final], sum([quantity_tot]) ,sum([Cost_tot])
  FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_fact_total_month_balance]
  WHERE [date_final] = 20190701
  GROUP BY [date_final]

  SELECT sum([quantity]), sum([Cost])
  FROM [dbo].[lasmart_v_fact_movement]
  WHERE [dt] BETWEEN 20180123 AND 20190630

  --

    SELECT sum([quantity]), sum([Cost])
  FROM [dbo].[lasmart_v_fact_movement]
  WHERE [dt] BETWEEN 20180123 AND 20190731

    SELECT  sum([quantity_tot]) ,sum([Cost_tot])
  FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_fact_total_month_balance]
  WHERE [date_final] = 20190801

  --
    SELECT sum([quantity]), sum([Cost])
  FROM [dbo].[lasmart_v_fact_movement]
  WHERE [dt] BETWEEN 20180123 AND 20180801

    SELECT  sum([quantity_tot]) ,sum([Cost_tot])
  FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_fact_total_month_balance]
  WHERE [count_date] = 20180801
  --GROUP BY [date_final]
  --нет
  SELECT sum([quantity]), sum([Cost])
  FROM [dbo].[lasmart_v_fact_movement]
  WHERE [dt] BETWEEN 20180123 AND 20190816

    SELECT [date_final], sum([quantity_tot]) ,sum([Cost_tot])
  FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_fact_total_month_balance]
  WHERE [date_final] = 20190817
  GROUP BY [date_final]

  TRUNCATE TABLE [lasmart_fact_total_month_balance]


  SET @dt_min = 20180801 
DECLARE @dt_max int 
SET @dt_max = 20180831

  --id_store in (SELECT a.id_store FROM [lasmart_fact_total_month_balance] as a WHERE [date_final] = 20180401)
  --(id_store IN (SELECT id_store FROM [lasmart_v_fact_movement] where dt between 20180301 and 20180331)) and
  --(id_goods IN (SELECT id_goods FROM [lasmart_v_fact_movement] where dt between 20180301 and 20180331))
  --GROUP BY dt
  --having dt = 20190801
  --ORDER BY [id_goods], [id_store]
  DECLARE @did int
  SET @did = 20190401
  SELECt SUBSTRING(STR(@did), 9, 2)
 
 TRUNCATE TABLE [dbo].[lasmart_fact_total_month_balance]

  exec [p_lasmart_fact_month_balance_final] @dt_min = 20180123, @dt_max = 20180201
  EXEC [p_lasmart_fact_month_balance_final] @dt_min = 20180201, @dt_max = 20180301
  EXEC [p_lasmart_fact_month_balance_final] @dt_min = 20180301, @dt_max = 20180401
  EXEC [p_lasmart_fact_month_balance_final] @dt_min = 20180401, @dt_max = 20180501
  EXEC [p_lasmart_fact_month_balance_final] @dt_min = 20180501, @dt_max = 20180601
  EXEC [p_lasmart_fact_month_balance_final] @dt_min = 20180601, @dt_max = 20180701
  EXEC [p_lasmart_fact_month_balance_final] @dt_min = 20180701, @dt_max = 20180801
  EXEC [p_lasmart_fact_month_balance_final] @dt_min = 20180801, @dt_max = 20180901
  EXEC [p_lasmart_fact_month_balance_final] @dt_min = 20180901, @dt_max = 20181001
  EXEC [p_lasmart_fact_month_balance_final] @dt_min = 20181001, @dt_max = 20181101
  EXEC [p_lasmart_fact_month_balance_final] @dt_min = 20181101, @dt_max = 20181201
  EXEC [p_lasmart_fact_month_balance_final] @dt_min = 20181201, @dt_max = 20190101

  EXEC [p_lasmart_fact_month_balance_final] @dt_min = 20190101, @dt_max = 20190201
  EXEC [p_lasmart_fact_month_balance_final] @dt_min = 20190201, @dt_max = 20190301
  EXEC [p_lasmart_fact_month_balance_final] @dt_min = 20190301, @dt_max = 20190401
  EXEC [p_lasmart_fact_month_balance_final] @dt_min = 20190401, @dt_max = 20190501
  EXEC [p_lasmart_fact_month_balance_final] @dt_min = 20190501, @dt_max = 20190601
  EXEC [p_lasmart_fact_month_balance_final] @dt_min = 20190601, @dt_max = 20190701
  EXEC [p_lasmart_fact_month_balance_final] @dt_min = 20190701, @dt_max = 20190801
  EXEC [p_lasmart_fact_month_balance_final] @dt_min = 20190801, @dt_max = 20190817

  EXEC [p_lasmart_fact_month_balance_final] @dt_min = 20190401, @dt_max = 20190901

  SELECT sum([quantity]), sum([Cost])
  FROM [dbo].[lasmart_v_fact_movement]
  WHERE [dt] BETWEEN 20180123 AND 20190731

  SELECT  sum([quantity_tot]) ,sum([Cost_tot])
  FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_fact_total_month_balance]
  WHERE [date_final] = 20190801


  EXEC [p_lasmart_fact_balance_report_test] @dt = 20190605
  
  SELECT sum([quantity]), sum([Cost])
  FROM [dbo].[lasmart_v_fact_movement]
  WHERE [dt] BETWEEN 20180123 AND 20190616

  EXEC [p_lasmart_fact_balance_report] @dt = 20190617, @id_store = 18

  SELECT sum([quantity]), sum([Cost])
  FROM [dbo].[lasmart_v_fact_movement]
  WHERE [dt] BETWEEN 20180123 AND 20190617

  EXEC [p_lasmart_fact_balance_report] @dt = 20190618, @id_store = 18
  
  SELECT sum([quantity]), sum([Cost])
  FROM [dbo].[lasmart_v_fact_movement]
  WHERE [dt] BETWEEN 20180123 AND 20190618

  EXEC [p_lasmart_fact_balance_report] @dt = 20190619, @id_store = 16
  
  SELECT sum([quantity]), sum([Cost])
  FROM [dbo].[lasmart_v_fact_movement]
  WHERE [dt] BETWEEN 20180123 AND 20190619


TRUNCATE TABLE [dbo].[lasmart_fact_total_month_balance]


exec [dbo].[p_lasmart_fact_balance_report] @dt = 20190801, @id_store = 18

--
   SELECT tt.*
FROM topten tt
INNER JOIN
    (SELECT home, MAX(datetime) AS MaxDateTime
    FROM topten
    GROUP BY home) groupedtt 
ON tt.home = groupedtt.home 
AND tt.datetime = groupedtt.MaxDateTime