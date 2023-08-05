USE [OrganicNeva_Nekhvyadovich]
GO
/****** Object:  StoredProcedure [dbo].[p_lasmart_plan_calculation]    Script Date: 13.11.2020 10:27:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[p_lasmart_plan_calculation] (@file_path nvarchar(1000))
	
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

DECLARE @date_from int = (SELECT MIN(t2.did)
                          FROM #tbl_kef as t1
						  LEFT JOIN lasmart_dim_date as t2
						  ON t1.d_rep - 100 = t2.m)

DECLARE @date_to int = (SELECT MAX(t2.did)
                          FROM #tbl_kef as t1
						  LEFT JOIN lasmart_dim_date as t2
						  ON t1.d_rep - 100 = t2.m)


delete top(100000)[dbo].[lasmart_fact_plan_sales] where [dt] >= @date_from + 10000 and [dt] <= @date_to + 10000
				while @@rowcount > 0
				begin
					delete top(100000) [dbo].[lasmart_fact_plan_sales]
					where  [dt] >= (@date_from + 10000) and [dt] <= (@date_to + 10000)
				end

INSERT INTO lasmart_fact_plan_sales
SELECT c.[dt] + 10000 as [dt],
	   c.[ID_Store] as [store_id],
	   c.[ID_GOODS] as [good_id],
	   k.persent as [kef],
	   sum(c.Sale) as [sum_sales],
	   sum(c.Sale) * k.persent as [plan]
FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_v_fact_cheques] as c
LEFT JOIN [dbo].[lasmart_dim_date] as d
	ON c.dt = d.did
LEFT JOIN #tbl_kef as k
	ON d.m = (k.d_rep - 100) and c.ID_Store = k.store_id
WHERE d.did between @date_from and @date_to
GROUP BY k.d_rep,
	        c.[dt],
		    c.[ID_Store],
		    c.[ID_GOODS],
		    k.persent


  
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