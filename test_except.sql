


exec [dbo].[p_lasmart_fact_except_movement] @date_from = 20190601, @date_to = 20190831



SELECT d.m,
       m.[id_store],
	   m.[OperTypeID],
       sum(m.[quantity]) as 'шт'
      ,sum(m.[Cost]) as 'руб'
FROM [dbo].[lasmart_v_fact_movement] as m
left join [dbo].[lasmart_dim_date] as d
on m.dt = d.did
where (m.[dt] between 20190601 and 20190831) and 
      (m.[OperTypeID] = 'Приход' or
	  m.[OperTypeID] = 'Продажа' or
	  m.[OperTypeID] = 'Списание')
group by d.m,
m.[id_store],
[OperTypeID]



exec [p_lasmart_check_message] @d_start = 20190601, @d_finish = 20190831


CREATE TABLE lasmart_fact_discrepancy_OLAP_DWH(
[dm] int,
[name] nvarchar(500),
[order_type] nvarchar(100),
[dwh_kol] money,
[dwh_sum] money,
[olap_kol] money,
[olap_sum] money
)

DROP TABLE discrepancy_OLAP_DWH

SELECT * FROM lasmart_fact_discrepancy_OLAP_DWH



--24,11

SELECT d.m as [dm],
       m.[id_store] as [store_id],
	   m.[OperTypeID] as [order_type],
       sum(m.[quantity]) as [dwh_kol],
       sum(m.[Cost]) as [dwh_sum],
	   0 as [olap_kol],
	   0 as [olap_sum]
FROM [dbo].[lasmart_v_fact_movement] as m
left join [dbo].[lasmart_dim_date] as d
on m.dt = d.did
where (m.[dt] between 20190601 and 20190831) and 
      (m.[OperTypeID] = 'Приход' or
	  m.[OperTypeID] = 'Продажа' or
	  m.[OperTypeID] = 'Списание')
group by d.m,
m.[id_store],
[OperTypeID]
EXCEPT
SELECT d.m as [dm],
       m.[id_store] as [store_id],
	   m.[OperTypeID] as [order_type],
       sum(m.[quantity]) as [dwh_kol],
       sum(m.[Cost]) as [dwh_sum],
	   0 as [olap_kol],
	   0 as [olap_sum]
FROM [dbo].[lasmart_v_fact_movement_FROM_OLAP] as m
left join [dbo].[lasmart_dim_date] as d
on m.dt = d.did
where (m.[dt] between 20190601 and 20190831) and 
      (m.[OperTypeID] = 'Приход' or
	  m.[OperTypeID] = 'Продажа' or
	  m.[OperTypeID] = 'Списание')
group by d.m,
m.[id_store],
[OperTypeID]

-------

SELECT 
    --   d.m as [dm],
       om.[id_store] as [store_id],
	   om.[OperTypeID] as [order_type],
	   dm.[id_store] as [store_id],
	   dm.[OperTypeID] as [order_type],
       sum(om.[quantity]) as [dwh_kol],
       sum(om.[Cost]) as [dwh_sum],
	   sum(dm.[quantity]) as [dwh_kol],
       sum(dm.[Cost]) as [dwh_sum]
FROM [dbo].[lasmart_v_fact_movement_FROM_OLAP] as om
FULL OUTER JOIN [lasmart_v_fact_movement] dm 
ON om.dt = dm.dt and om.id_store = dm.id_store and om.OperTypeID = dm.OperTypeID
--left join [dbo].[lasmart_dim_date] as d
--on om.dt = d.did and dm.dt = d.did
where ((om.dt is null /*and om.id_store is null and om.OperTypeID is null*/) or (dm.dt is null /*and dm.id_store is null and dm.OperTypeID is null*/)) 
and
 ((om.[dt] between 20190601 and 20190831) and (dm.[dt] between 20190601 and 20190831)) and
      (om.[OperTypeID] = 'Приход' or
	  om.[OperTypeID] = 'Продажа' or
	  om.[OperTypeID] = 'Списание') or
	  (dm.[OperTypeID] = 'Приход' or
	  dm.[OperTypeID] = 'Продажа' or
	  dm.[OperTypeID] = 'Списание')
-- ((om.dt is null and om.id_store is null and om.OperTypeID is null))
group by 
       om.[id_store] ,
	   om.[OperTypeID] ,
	   dm.[id_store] ,
	   dm.[OperTypeID] 


SELECT *
FROM [dbo].[lasmart_v_fact_movement_FROM_OLAP] as om
FULL OUTER JOIN [lasmart_v_fact_movement] dm 
ON om.dt = dm.dt and om.id_store = dm.id_store and om.OperTypeID = dm.OperTypeID
where ((om.dt is null /*and om.id_store is null and om.OperTypeID is null*/) or (dm.dt is null /*and dm.id_store is null and dm.OperTypeID is null*/)) 

SELECT *
FROM [lasmart_v_fact_movement] dm 
FULL OUTER JOIN [dbo].[lasmart_v_fact_movement_FROM_OLAP] as om
ON om.dt = dm.dt and om.id_store = dm.id_store and om.OperTypeID = dm.OperTypeID and om.id_goods = dm.id_goods
where (om.dt is null or dm.dt is null) 
--------------
SELECT [dm] as 'Месяц',
       s.[name] as 'Магазин',
	   [order_type],
       sum([kol]) as 'DWH Количество, шт.',
       sum([sum]) as 'DWH Сумма, руб.',
	   sum([olap_kol]) as 'OLAP Количество, шт.',
	   sum([olap_sum]) as 'OLAP Сумма, руб.'
FROM(

SELECT d.m as [dm],
       m.[id_store] as [store_id],
	   m.[OperTypeID] as [order_type],
       sum(m.[quantity]) as [kol],
       sum(m.[Cost]) as [sum]
	   --sum(m.[quantity]) as [olap_kol],
	   --sum(m.[Cost]) as [olap_sum]
FROM [dbo].[lasmart_v_fact_movement] as m
left join [dbo].[lasmart_dim_date] as d
on m.dt = d.did
where (m.[dt] between 20190601 and 20190831) and 
      (m.[OperTypeID] = 'Приход' or
	  m.[OperTypeID] = 'Продажа' or
	  m.[OperTypeID] = 'Списание')
group by d.m,
m.[id_store],
m.[OperTypeID]

UNION ALL

SELECT d.m as [dm],
       m.[id_store] as [store_id],
	   m.[OperTypeID] as [order_type],
       -sum(m.[quantity]) as [kol],
       -sum(m.[Cost]) as [sum],
	   --sum(m.[quantity]) as [olap_kol],
	   --sum(m.[Cost]) as [olap_sum]
FROM [dbo].[lasmart_v_fact_movement_FROM_OLAP] as m
left join [dbo].[lasmart_dim_date] as d
on m.dt = d.did
where (m.[dt] between 20190601 and 20190831) and 
      (m.[OperTypeID] = 'Приход' or
	  m.[OperTypeID] = 'Продажа' or
	  m.[OperTypeID] = 'Списание')
group by d.m,
m.[id_store],
m.[OperTypeID]

) as [except]
left join lasmart_dim_stores as s
on [except].store_id = s.store_id
GROUP BY [dm],
         s.[name],
	     [order_type]
HAVING sum([kol])<>0 and sum([sum])<>0



SELECT [dm] as 'Месяц',
       s.[name] as 'Магазин',
	   [order_type],
       sum([kol]) as 'DWH Количество, шт.',
       sum([sum]) as 'DWH Сумма, руб.',
	   sum([olap_kol]) as 'OLAP Количество, шт.',
	   sum([olap_sum]) as 'OLAP Сумма, руб.'
FROM(
SELECT d.m as [dm],
       m.[id_store] as [store_id],
	   m.[OperTypeID] as [order_type],
       -sum(m.[quantity]) as [kol],
       -sum(m.[Cost]) as [sum],
	   0 as [olap_kol],
	   0 as [olap_sum]
FROM [dbo].[lasmart_v_fact_movement_FROM_OLAP] as m
left join [dbo].[lasmart_dim_date] as d
on m.dt = d.did
where (m.[dt] between 20190601 and 20190831) and 
      (m.[OperTypeID] = 'Приход' or
	  m.[OperTypeID] = 'Продажа' or
	  m.[OperTypeID] = 'Списание')
group by d.m,
m.[id_store],
m.[OperTypeID]


UNION ALL

SELECT d.m as [dm],
       m.[id_store] as [store_id],
	   m.[OperTypeID] as [order_type],
       sum(m.[quantity]) as [kol],
       sum(m.[Cost]) as [sum],
	   0 as [olap_kol],
	   0 as [olap_sum]
FROM [dbo].[lasmart_v_fact_movement] as m
left join [dbo].[lasmart_dim_date] as d
on m.dt = d.did
where (m.[dt] between 20190601 and 20190831) and 
      (m.[OperTypeID] = 'Приход' or
	  m.[OperTypeID] = 'Продажа' or
	  m.[OperTypeID] = 'Списание')
group by d.m,
m.[id_store],
m.[OperTypeID]

) as [except]
left join lasmart_dim_stores as s
on [except].store_id = s.store_id
GROUP BY [dm],
         s.[name],
	     [order_type]
HAVING sum([kol])<>0 and sum([sum])<>0

---

SELECT *--d.m as [dm],
--       om.[id_store] as [store_id],
--	   om.[OperTypeID] as [order_type],
--	   0 as [dwh_kol],
--	   0 as [dwh_sum],
--       sum(om.[quantity]) as [olap_kol],
--       sum(om.[Cost]) as [olap_sum]
FROM [dbo].[lasmart_v_fact_movement_FROM_OLAP] as om
left join [dbo].[lasmart_v_fact_movement] as dm
ON (om.dt = dm.dt and om.id_store = dm.id_store and om.OperTypeID = dm.OperTypeID and om.id_goods = dm.id_goods)
--left join [dbo].[lasmart_dim_date] as d
--on om.dt = d.did
where (om.[dt] between 20190601 and 20190831) and 
      (om.[OperTypeID] = 'Приход' or
	  om.[OperTypeID] = 'Продажа' or
	  om.[OperTypeID] = 'Списание') --and
	 --(dm.dt is null and dm.id_store is null and dm.[OperTypeID] is null)
--group by d.m,
--om.[id_store],
--om.[OperTypeID]

---------------------------






SELECT [dm] as 'Месяц',
       s.[name] as 'Магазин',
	   [order_type],
       sum([kol]) as 'DWH Количество, шт.',
       sum([sum]) as 'DWH Сумма, руб.',
	   sum([olap_kol]) as 'OLAP Количество, шт.',
	   sum([olap_sum]) as 'OLAP Сумма, руб.'
FROM(
SELECT d.m as [dm],
       m.[id_store] as [store_id],
	   m.[OperTypeID] as [order_type],
       -sum(m.[quantity]) as [kol],
       -sum(m.[Cost]) as [sum],
	   0 as [olap_kol],
	   0 as [olap_sum]
FROM [dbo].[lasmart_v_fact_movement_FROM_OLAP] as m
left join [dbo].[lasmart_dim_date] as d
on m.dt = d.did
where (m.[dt] between 20190601 and 20190831) and 
      (m.[OperTypeID] = 'Приход' or
	  m.[OperTypeID] = 'Продажа' or
	  m.[OperTypeID] = 'Списание')
group by d.m,
m.[id_store],
m.[OperTypeID]


UNION ALL

SELECT d.m as [dm],
       m.[id_store] as [store_id],
	   m.[OperTypeID] as [order_type],
       sum(m.[quantity]) as [kol],
       sum(m.[Cost]) as [sum],
	   0 as [olap_kol],
	   0 as [olap_sum]
FROM [dbo].[lasmart_v_fact_movement] as m
left join [dbo].[lasmart_dim_date] as d
on m.dt = d.did
where (m.[dt] between 20190601 and 20190831) and 
      (m.[OperTypeID] = 'Приход' or
	  m.[OperTypeID] = 'Продажа' or
	  m.[OperTypeID] = 'Списание')
group by d.m,
m.[id_store],
m.[OperTypeID]

) as [except]
left join lasmart_dim_stores as s
on [except].store_id = s.store_id
GROUP BY [dm],
         s.[name],
	     [order_type]
HAVING count(1)=1




SELECT d.m,[id_store],[OperTypeID],
       sum(quant_ol) as quant_ol,
       sum(cost_ol) as cost_ol,
	   sum(quant_m) as quant_m,
	   sum(cost_m) as cost_m
       

FROM(

select   count(t_1) * [quantity]  as quant_ol, 
         count(t_1) * [Cost]  as cost_ol, 
         count(t_2) * [quantity] as quant_m, 
		 count(t_2) * [Cost]  as cost_m, 
       [dt]
      ,[OperTypeID]
      ,[id_store]
      ,[quantity]
      ,[Cost]

from     (
           select 'x' as t_1, null as t_2, 
	   [dt]
      ,[OperTypeID]
      ,[id_store]
      ,[quantity]
      ,[Cost]
             from [lasmart_v_fact_movement]
			 where (dt between 20190601 and 20190831) and
       ([OperTypeID] = 'Приход' or
	   [OperTypeID] = 'Продажа' or
	   [OperTypeID] = 'Списание')

           union all

           select null as t_1, 'x' as t_2, 
	   [dt]
      ,[OperTypeID]
      ,[id_store]
      ,[quantity]
      ,[Cost]
             from [lasmart_v_fact_movement_FROM_OLAP]
			 where (dt between 20190601 and 20190831) and
       ([OperTypeID] = 'Приход' or
	   [OperTypeID] = 'Продажа' or
	   [OperTypeID] = 'Списание')
         ) as d
--WHERE   (dt between 20190601 and 20190831) and
--       ([OperTypeID] = 'Приход' or
--	   [OperTypeID] = 'Продажа' or
--	   [OperTypeID] = 'Списание')
group by [dt]
      ,[OperTypeID]
      ,[id_store]
      ,[quantity]
      ,[Cost]
having   count(t_1) != count(t_2)

) as s
Left join lasmart_dim_date as d
ON d.did = s.dt
Group by d.m,[id_store],[OperTypeID]

--=====================ВЕРНО


SELECT d.m
      ,[OperTypeID]
      ,[id_store],
	  sum([quantity]),
	  sum([Cost])
FROM
(SELECT * FROM [lasmart_v_fact_movement]
UNION ALL  
SELECT * FROM [lasmart_v_fact_movement_FROM_OLAP]) as [data]
left join lasmart_dim_date as d
ON [data].dt =d.did
GROUP BY d.m
      ,[OperTypeID]
      ,[id_store]
HAVING count(*)!=2

--===========================xz




SELECT d.m,[id_store],[OperTypeID],
       sum(quant_m) as quant_m,
       sum(cost_m) as cost_m,
	   sum(quant_ol) as quant_ol,
	   sum(cost_ol) as cost_ol
FROM(

select   IIF((sum(t_1) - sum(t_2)) < 0, 0, (sum(t_1) - sum(t_2))) * [quantity]  as quant_m, 
         IIF((sum(t_1) - sum(t_2)) < 0, 0, (sum(t_1) - sum(t_2))) * [Cost]  as cost_m, 
         IIF((sum(t_2) - sum(t_1)) < 0, 0, (sum(t_2) - sum(t_1))) * [quantity] as quant_ol, 
		 IIF((sum(t_2) - sum(t_1)) < 0, 0, (sum(t_2) - sum(t_1))) * [Cost]  as cost_ol, 
       [dt]
      ,[OperTypeID]
      ,[id_store]

from   (
       select 
	   1 as t_1, 
	   0 as t_2, 
	   [dt]
      ,[OperTypeID]
      ,[id_store]
      ,[quantity]
      ,[Cost]
       from [lasmart_v_fact_movement]
	   where dt between 20190601 and 20190831

       union all

       select 
	   0 as t_1, 
	   1 as t_2
	  ,[dt]
      ,[OperTypeID]
      ,[id_store]
      ,[quantity]
      ,[Cost]
       from [lasmart_v_fact_movement_FROM_OLAP]
	   where dt between 20190601 and 20190831
         ) as dу
group by [dt]
        ,[OperTypeID]
        ,[id_store]
        ,[quantity]
        ,[Cost]
having   sum(t_1) != sum(t_2)

) as s
Left join lasmart_dim_date as d
ON d.did = s.dt
WHERE ([OperTypeID] = 'Приход' or
	   [OperTypeID] = 'Продажа' or
	   [OperTypeID] = 'Списание')
Group by d.m,[id_store],[OperTypeID]


SELECT TOP 100 *
FROM [lasmart_v_fact_movement]AS a
WHERE NOT EXISTS
(SELECT *
FROM [lasmart_v_fact_movement_FROM_OLAP] )



















SELECT [dm], 
	   [store_id],
	   [order_type],
	   sum([olap_kol]),
	   sum([olap_sum]),
	   sum([dwh_kol]),
	   sum([dwh_sum])
FROM (
	SELECT [dm], 
		   [store_id],
		   [order_type],
		   IIF ((count(t_1) > count(t_2)) , [olap_kol], 0) as [olap_kol],
		   IIF ((count(t_1) > count(t_2)) , [olap_sum], 0) as [olap_sum],
		   IIF ((count(t_1) < count(t_2)) , [olap_kol], 0) as [dwh_kol],
		   IIF ((count(t_1) < count(t_2)) , [olap_sum], 0) as [dwh_sum]
	FROM (
		SELECT null as t_1, 'x' as t_2,
			   d.m as [dm],
			   m.[id_store] as [store_id],
			   m.[OperTypeID] as [order_type],
			   sum(m.[quantity]) as [olap_kol],
			   sum(m.[Cost]) as [olap_sum],
			   0 as [dwh_kol],
			   0 as [dwh_sum]
		FROM [dbo].[lasmart_v_fact_movement_FROM_OLAP] as m
		left join [dbo].[lasmart_dim_date] as d
		on m.dt = d.did
		where (m.[dt] between 20190601 and 20190831) and 
				(m.[OperTypeID] = 'Приход' or
				m.[OperTypeID] = 'Продажа' or
				m.[OperTypeID] = 'Списание')
		group by d.m,
		m.[id_store],
		[OperTypeID]

		union all 

		SELECT 'x' as t_1, null as t_2,
				d.m as [dm],
				m.[id_store] as [store_id],
				m.[OperTypeID] as [order_type],
				sum(m.[quantity]) as [olap_kol],
				sum(m.[Cost]) as [olap_sum],
				0 as [dwh_kol],
				0 as [dwh_sum]
		FROM [dbo].[lasmart_v_fact_movement] as m
		left join [dbo].[lasmart_dim_date] as d
		on m.dt = d.did
		where (m.[dt] between 20190601 and 20190831) and 
				(m.[OperTypeID] = 'Приход' or
				m.[OperTypeID] = 'Продажа' or
				m.[OperTypeID] = 'Списание')
		group by d.m,
		         m.[id_store],
		         m.[OperTypeID]

	) as tbl1
	group by [dm], 
		     [store_id],
		     [order_type],
		     [olap_kol],
		     [olap_sum],
		     [dwh_kol],
		     [dwh_sum]
	HAVING count(t_1) != count(t_2)
) as tbl2
GROUP BY  [dm], 
          [store_id],
          [order_type]
	   












SELECT d.m, 
	   [store_id],
	   [order_type],
	   sum([olap_kol]),
	   sum([olap_sum]),
	   sum([dwh_kol]),
	   sum([dwh_sum])
FROM (
	SELECT [dt], 
		   [store_id],
		   [order_type],
		   IIF ((count(t_1) > count(t_2)) , [olap_kol], 0) as [olap_kol],
		   IIF ((count(t_1) > count(t_2)) , [olap_sum], 0) as [olap_sum],
		   IIF ((count(t_1) < count(t_2)) , [olap_kol], 0) as [dwh_kol],
		   IIF ((count(t_1) < count(t_2)) , [olap_sum], 0) as [dwh_sum]
	FROM (
		SELECT null as t_1, 'x' as t_2,
			   dt,
			   m.[id_store] as [store_id],
			   m.[OperTypeID] as [order_type],
			   sum(m.[quantity]) as [olap_kol],
			   sum(m.[Cost]) as [olap_sum],
			   0 as [dwh_kol],
			   0 as [dwh_sum]
		FROM [dbo].[lasmart_v_fact_movement_FROM_OLAP] as m
		group by dt,
		         m.[id_store],
		         m.[OperTypeID]

		union all 

		SELECT 'x' as t_1, null as t_2,
				dt,
				m.[id_store] as [store_id],
				m.[OperTypeID] as [order_type],
				sum(m.[quantity]) as [olap_kol],
				sum(m.[Cost]) as [olap_sum],
				0 as [dwh_kol],
				0 as [dwh_sum]
		FROM [dbo].[lasmart_v_fact_movement] as m
		group by dt,
		         m.[id_store],
		         m.[OperTypeID]

	) as tbl1
    Where ([dt] between 20190601 and 20190831) and 
	([order_type] = 'Приход' or
	  [order_type] = 'Продажа' or
	  [order_type] = 'Списание')
	group by dt, 
		     [store_id],
		     [order_type],
		     [olap_kol],
		     [olap_sum],
		     [dwh_kol],
		     [dwh_sum]
	HAVING count(t_1) != count(t_2)
) as tbl2
left join [dbo].[lasmart_dim_date] as d
		on tbl2.dt = d.did
GROUP BY  d.m, 
          [store_id],
          [order_type]
	   




	   ------------------------------------------------



















SELECT d.m,
       st.[name],
	   [OperTypeID],
       sum(s1) as quant_ol,
       sum(c1) as cost_ol,
       sum(s2) as quant_m,
       sum(c2) as cost_m
FROM(

select   d.m,
         [OperTypeID],
         [id_store],
		 sum([s_q]) - sum([s1_q]) as s1,
		 sum([c_q]) - sum([c1_q]) as c1,
		 sum([s1_q]) - sum([s_q]) as s2,
		 sum([c1_q]) - sum([c_q]) as c2

from     (
	      SELECT  m.dt,
                  m.[OperTypeID] as [OperTypeID],
                  m.[id_store] as [id_store],
                  m.[quantity] as s_q,
                  m.[Cost] as c_q,
				  0 as s1_q,
				  0 as c1_q
           from [lasmart_v_fact_movement] as m
		   WHERE   (m.dt between 20190601 and 20190831) and
                   (m.[OperTypeID] = 'Приход' or
	                m.[OperTypeID] = 'Продажа' or
	                m.[OperTypeID] = 'Списание')
		   group by m.dt,
                    m.[OperTypeID],
                    m.[id_store],
					m.[quantity],
					m.[Cost]

           union all

           select m.dt,
                  m.[OperTypeID] as [OperTypeID],
                  m.[id_store] as [id_store],
                  0 as s_q,
                  0 as c_q,
				  m.[quantity] as s1_q,
				  m.[Cost] as c1_q
           from [lasmart_v_fact_movement_FROM_OLAP] as m
		   WHERE   (m.dt between 20190601 and 20190831) and
                   (m.[OperTypeID] = 'Приход' or
	                m.[OperTypeID] = 'Продажа' or
	                m.[OperTypeID] = 'Списание')
		   group by m.dt,
                    m.[OperTypeID],
                    m.[id_store],
					m.[quantity],
					m.[Cost]
         ) as ds
		   Left join lasmart_dim_date as d
           ON d.did = ds.dt

group by d.m,
         [OperTypeID],
         [id_store]
having sum(s_q) !=0 and sum(c_q) != 0 and sum(s1_q) != 0 and sum(c1_q) != 0
   --     [s_q],
		 --[c_q],
		 --[s1_q],
		 --[c1_q]
) as s
Group by d.m,
         st.[name],
		 s.[OperTypeID]

having sum(s1) !=0 and sum(c1) != 0 and sum(s2) != 0 and sum(c2) != 0

left join lasmart_dim_stores as st
ON st.store_id = s.id_store


















SELECT --d.m as [dm],
       m.[id_store] as [store_id],
	   m.[OperTypeID] as [order_type],
       -sum(m.[quantity]) as [kol],
       -sum(m.[Cost]) as [sum],
	   0 as [olap_kol],
	   0 as [olap_sum]
FROM [dbo].[lasmart_v_fact_movement] as m
WHERE NOT EXISTS ()

SELECT * FROM [lasmart_v_fact_movement_FROM_OLAP]
WHERE NOT EXISTS (SELECT * FROM [lasmart_v_fact_movement]) --and [dt] between 20190601 and 20190831

left join [dbo].[lasmart_dim_date] as d
on m.dt = d.did
where (m.[dt] between 20190601 and 20190831) and 
      (m.[OperTypeID] = 'Приход' or
	  m.[OperTypeID] = 'Продажа' or
	  m.[OperTypeID] = 'Списание')
group by d.m,
m.[id_store],
m.[OperTypeID]



------------



SELECT d.m, 
	   [store_id],
	   [order_type],
	   sum([olap_kol]),
	   sum([olap_sum]),
	   sum([dwh_kol]),
	   sum([dwh_sum])
FROM (
	SELECT [dt], 
		   [store_id],
		   [order_type],
		   IIF ((count(t_1) > count(t_2)) , [olap_kol], 0) as [olap_kol],
		   IIF ((count(t_1) > count(t_2)) , [olap_sum], 0) as [olap_sum],
		   IIF ((count(t_1) < count(t_2)) , [olap_kol], 0) as [dwh_kol],
		   IIF ((count(t_1) < count(t_2)) , [olap_sum], 0) as [dwh_sum]
	FROM (
		SELECT null as t_1, 'x' as t_2,
			   dt,
			   m.[id_store] as [store_id],
			   m.[OperTypeID] as [order_type],
			   sum(m.[quantity]) as [olap_kol],
			   sum(m.[Cost]) as [olap_sum],
			   0 as [dwh_kol],
			   0 as [dwh_sum]
		FROM [dbo].[lasmart_v_fact_movement_FROM_OLAP] as m
		group by dt,
		         m.[id_store],
		         m.[OperTypeID]

		union all 

		SELECT 'x' as t_1, null as t_2,
				dt,
				m.[id_store] as [store_id],
				m.[OperTypeID] as [order_type],
				sum(m.[quantity]) as [olap_kol],
				sum(m.[Cost]) as [olap_sum],
				0 as [dwh_kol],
				0 as [dwh_sum]
		FROM [dbo].[lasmart_v_fact_movement] as m
		group by dt,
		         m.[id_store],
		         m.[OperTypeID]

	) as tbl1
    Where ([dt] between 20190601 and 20190831) and 
	([order_type] = 'Приход' or
	  [order_type] = 'Продажа' or
	  [order_type] = 'Списание')
	group by dt, 
		     [store_id],
		     [order_type],
		     [olap_kol],
		     [olap_sum],
		     [dwh_kol],
		     [dwh_sum]
	HAVING count(t_1) != count(t_2)
) as tbl2
left join [dbo].[lasmart_dim_date] as d
		on tbl2.dt = d.did
GROUP BY  d.m, 
          [store_id],
          [order_type]








































	--INSERT INTO #tmp_error
	SELECT d.m,
		   st.[name],
		   [OperTypeID],
		   sum(quant_ol) as quant_ol,
		   sum(cost_ol) as cost_ol,
		   sum(quant_m) as quant_m,
		   sum(cost_m) as cost_m
	FROM(








	SELECT sum(quant_ol), sum(cost_ol), sum(quant_m), sum(cost_m), d.m,
			 [OperTypeID],
			 [id_store]
	FROM 
	(

	select   
	         sum(q_m) - sum(q_o) as quant_ol, 
			 sum(c_m) - sum(c_o)  as cost_ol, 
			 sum(q_o) - sum(q_m) as quant_m, 
			 sum(c_o) - sum(c_m) as cost_m, 
			 [dt],
			 [OperTypeID],
			 [id_store]

	from     (
			   select [dt],
					  [OperTypeID],
					  [id_store],
					  [quantity] as q_m,
					  [Cost] as c_m,
					  -[quantity] as q_o,
					  -[Cost] as c_o
			   from [lasmart_v_fact_movement]

			   union all

			   select [dt],
					  [OperTypeID],
					  [id_store],
					  -[quantity] as q_m,
					  -[Cost] as c_m,
					  [quantity] as q_o,
					  [Cost] as c_o
			   from [lasmart_v_fact_movement_FROM_OLAP]
			 ) as d
	WHERE   (dt between 20190601 and 20190831) and
		   ([OperTypeID] = 'Приход' or
		   [OperTypeID] = 'Продажа' or
		   [OperTypeID] = 'Списание')
	group by [dt],
			 [OperTypeID],
			 [id_store]
		) as dd
		Left join lasmart_dim_date as d
	ON d.did = dd.dt
		WHERE quant_ol != 0 and cost_ol != 0 and quant_m != 0 and cost_m != 0
		group by 
		d.m,
			 [OperTypeID],
			 [id_store]




	having   quant_ol != 0 and cost_ol != 0 and quant_m != 0 and cost_m != 0

		   ((sum(q_m) - sum(q_o) != 0) and 
			 (sum(c_m) - sum(c_o) != 0) and
			 sum(q_o) - sum(q_m) as quant_m, 
			 sum(c_o) - sum(c_m))



	quant_ol, 
			 sum(c_m) - sum(c_o)  as cost_ol, 
			 sum(q_o) - sum(q_m) as quant_m, 
			 sum(c_o) - sum(c_m) as cost_m





	) as s
	Left join lasmart_dim_date as d
	ON d.did = s.dt
	left join lasmart_dim_stores as st
	ON st.store_id = s.id_store
	Group by d.m,
			 st.[name],
			 s.[OperTypeID]





			 ------------FINAL
SELECT  d.m,
		t1.[OperTypeID],
		st.[name],
		sum(q_u) - sum(q_o) as q_m,
		sum(c_u) - sum(c_o) as c_m,
        sum(q_u) - sum(q_m) as q_o,
        sum(c_u) - sum(c_m) as c_o
FROM (
        select [dt],
               [OperTypeID],
			   [id_store],
			   sum([quantity]) as q_m,
			   sum([sale]) as c_m,
			   0 as q_o,
			   0 as c_o,
			   sum([quantity]) as q_u,
			   sum([sale]) as c_u
        from [lasmart_v_fact_movement]
		WHERE (dt between 20190601 and 20190831) and
		      ([OperTypeID] = 'Приход' or
		       [OperTypeID] = 'Продажа' or
		       [OperTypeID] = 'Списание')
        group by [dt],
		         [OperTypeID],
				 [id_store]

        union all

		select [dt],
		       [OperTypeID],
			   [id_store],
			   0 as q_m,
			   0 as c_m,
			   sum([quantity]) as q_o,
			   sum([sale]) as c_o,
			   sum([quantity]) as q_u,
			   sum([sale]) as c_u

	    from [lasmart_v_fact_movement_FROM_OLAP]
		WHERE (dt between 20190601 and 20190831) and
		      ([OperTypeID] = 'Приход' or
		       [OperTypeID] = 'Продажа' or
		       [OperTypeID] = 'Списание')
        group by [dt],
		         [OperTypeID],
				 [id_store]
    )as t1
Left join lasmart_dim_date as d
 ON d.did = t1.dt
left join lasmart_dim_stores as st
 ON st.store_id = t1.id_store
Group by d.m,
		 st.[name],
		 t1.[OperTypeID]
having  sum(q_m) - sum(q_o) != 0 and 
        sum(q_o) - sum(q_m) != 0 and
        sum(c_o) - sum(c_m) != 0 and
        sum(c_m) - sum(c_o) != 0











					  sum(q_m) - sum(q_o) as qmo_dif,
					  sum(q_o) - sum(q_m) as qom_dif,
                      sum(c_o) - sum(c_m) as com_dif,
					  sum(c_m) - sum(c_o)