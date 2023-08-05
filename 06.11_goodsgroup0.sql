/****** Скрипт для команды SelectTopNRows из среды SSMS  ******/
SELECT 
      s.[id_goods]
      
  FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_fact_month_balance] as s
  LEFT JOIN [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_dim_goods] as d on s.[id_goods] = d.[good_id] 
  --INNER JOIN lasmart_dim_goodgroups as a ON  d.group_id = a.goodgroup_id
  WHERE s.[id_goods] <> d.[good_id]
  --WHERE s.[group_id] <> a.goodgroup_id


  /****** Скрипт для команды SelectTopNRows из среды SSMS  ******/
SELECT *        
  FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_dim_goods] 
WHERE good_id = 2329



SELECT [good_id] 
      ,[group_id]
FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_dim_goods] 
WHERE [group_id] = 0





  
  SELECT a.goodgroup_id, a.[name], b.parent_group, b.[name], c.good_id, c.group_id, c.[name]
  FROM  [dbo].[lasmart_dim_goodgroups] as a
  inner join [dbo].[lasmart_dim_goodgroups] as b ON b.parent_group = a.goodgroup_id
  inner join [dbo].[lasmart_dim_goods] as c ON c.group_id = b.goodgroup_id
  ORDER BY a.goodgroup_id,b.goodgroup_id, c.group_id, c.[name]


