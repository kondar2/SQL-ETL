

exec [p_lasmart_fact_ABC] @date_from = 20180202, @date_to = 20180502, @id_stores = '1,2,3,4,5'



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

--

exec [p_lasmart_v_ABC_report] @date_from = 20180202, @date_to = 20190502, @id_stores = '1,2,3,4,5,6,7,8,9,10,11,12'

--тестирование

SELECT h.[goodgroup_lvl2] as 'Категория',
       sum(c.Sale) over(partition by h.[goodgroup_lvl2]) as 'Доля',
	   sum(c.Sale) over() as 'сумма всего',
	   sum(c.Sale) over(partition by h.[goodgroup_lvl2]) / sum(c.Sale) over() as 'процент'
FROM [lasmart_v_fact_cheques] as c
LEFT JOIN lasmart_dim_goods as g
ON c.ID_GOODS = g.good_id
LEFT JOIN #tmp_hierarchy as h
on g.group_id = h.[goodgroup_id]
WHERE c.[CHEQUE_TYPE] = 'Продажа'
ORDER BY 2 DESC


SELECT h.[goodgroup_lvl2],
       sum(c.Sale) as 'сумма продаж группы жнвлп'
FROM [lasmart_v_fact_cheques] as c
LEFT JOIN lasmart_dim_goods as g
ON c.ID_GOODS = g.good_id
LEFT JOIN #tmp_hierarchy as h
on g.group_id = h.[goodgroup_id]
WHERE c.[CHEQUE_TYPE] = 'Продажа' and [goodgroup_lvl2] = 'жнвлп'
GROUP BY h.[goodgroup_lvl2]


SELECT sum(c.Sale) as 'сумма продаж всего'
FROM [lasmart_v_fact_cheques] as c
WHERE c.[CHEQUE_TYPE] = 'Продажа'

--тестирование

CREATE TABLE lasmart_v_ABC_report(
group_id nvarchar(500),
share float,
accum_share float,
group_type char
)