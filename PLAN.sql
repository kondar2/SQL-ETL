USE [OrganicNeva_Nekhvyadovich]
GO
/****** Object:  StoredProcedure [dbo].[p_lasmart_plan_calculation]    Script Date: 13.11.2020 10:27:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[p_lasmart_plan_calculation_2] (@file_path nvarchar(1000))
	
AS
SET NOCOUNT ON;
BEGIN

DECLARE 
	@name varchar(500) = '[' + OBJECT_SCHEMA_NAME(@@PROCID) + '].[' + OBJECT_NAME(@@PROCID) + ']',
	@description varchar(500) = '[dbo].[lasmart_dim_plan_sales]',
	@input_parametrs varchar(500) = N'@file_path =' + @file_path

begin try

EXEC [oth].[fill_sup_log] @name = @name, @state_name = 'start', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs


CREATE TABLE #tbl_kef
(
store_id int,
d_rep int,
persent float
);

DECLARE @SQL varchar(8000)
SET @SQL = 'BULK INSERT #tbl_kef FROM ''' + @file_path + ''' WITH ( FIRSTROW = 2, FIELDTERMINATOR = '';'', ROWTERMINATOR = ''\n'', DATAFILETYPE = ''widechar'' )'

exec(@SQL)

ALTER TABLE #tbl_kef ADD d_plan AS (d_rep - 100)

DELETE FROM lasmart_dim_plan_sales
WHERE [d_rep] >= (SELECT MIN(d_rep) FROM #tbl_kef)

INSERT INTO lasmart_dim_plan_sales
SELECT k.d_rep,
       d.m, 
       c.ID_Store, 
	   g.group_id, 
	   k.persent,
	   sum(c.Sale),
	   sum(c.Sale) * k.persent

FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_v_fact_cheques] as c
LEFT JOIN [dbo].[lasmart_dim_date] as d
  ON c.dt = d.did
LEFT JOIN #tbl_kef as k
  ON d.m = k.d_plan and c.ID_Store = k.store_id
LEFT JOIN lasmart_dim_goods as g
  ON c.[ID_GOODS] = g.good_id
  WHERE k.d_rep is not null
GROUP BY k.d_rep, d.m, g.group_id, c.ID_Store,k.persent

  
EXEC [oth].[fill_SUP_LOG] @name = @name, @state_name = 'finish', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs

IF OBJECT_ID(N'tempdb..#tbl_kef', N'U') IS NOT NULL
	DROP TABLE #tbl_kef



end try
begin catch
	EXEC [oth].[fill_SUP_LOG] @name = @name, @state_name = 'error', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs

IF OBJECT_ID(N'tempdb..#tbl_kef', N'U') IS NOT NULL
	DROP TABLE #tbl_kef

	RETURN
end catch

END