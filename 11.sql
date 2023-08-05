USE [RetailAnalytics]
GO

/****** Object:  View [dbo].[v_olap_dim_store]    Script Date: 02.11.2020 0:24:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[v_olap_dim_store]
AS

SELECT
	 [store_id]
	,store_source_id -- код магазина
	,[store_desc] -- наименование магазина
FROM [dbo].[dim_Store] with(nolock)

UNION ALL

SELECT 
	 -1 AS [store_id]
	,-1 AS store_source_id
	,'Н/Д' AS [store_desc]
GO


