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

/*
MERGE INTO lasmart_fact_plan_sales as t1
USING 
(
    SELECT k.d_rep as [dm_rep],
	       c.[dt] as [dt],
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
	WHERE k.d_rep is not null
	GROUP BY k.d_rep,
	         c.[dt],
		     c.[ID_Store],
		     c.[ID_GOODS],
		     k.persent
)as t2
	ON t1.[dt] = t2.dt and t1.store_id = t2.store_id and t1.good_id = t2.good_id

WHEN NOT MATCHED  BY TARGET THEN			 
	INSERT ( 
			[dm_rep],
            [dt],
            [store_id],
            [good_id],
            [kef],
            [sum_sales],
            [plan]
	) 
	VALUES (
	        t2.[dm_rep],
            t2.[dt],
            t2.[store_id],
            t2.[good_id],
            t2.[kef],
            t2.[sum_sales],
            t2.[plan]
	) 
WHEN MATCHED THEN
UPDATE SET
	 t1.[kef] = t2.[kef]
	,t1.[sum_sales] = t2.sum_sales
	,t1.[plan] = t2.[plan]
;
*/			
DECLARE @date_from int = 201901,
        @date_to int = 201905
		select top 1 * from [stg].[lasmart_v_fact_cheques] (nolock) where [date] between dbo.int_to_date(@date_from) and dbo.int_to_date(@date_to)
		IF exists (select top 1 * from [stg].[lasmart_v_fact_cheques] (nolock) where [date] between dbo.int_to_date(@date_from) and dbo.int_to_date(@date_to)) --Обязательная проверка наличия данных в STG слое
		BEGIN
			

			-- Удаление
			/*для этой конструкции важно наличие кластерного индекса по [date_id]*/
			DELETE TOP (1000000) t 
			FROM [dbo].[fct_movements] as t 
			WHERE t.[date_id] >= @date_from 
				and t.[date_id] < @date_to
			WHILE @@rowcount > 0
			BEGIN
				DELETE TOP (1000000) t 
				FROM [dbo].[fct_movements] as t 
				WHERE t.[date_id] >= @date_from 
					and t.[date_id] < @date_to
			END

			-- Вставка
			INSERT INTO [dbo].[fct_movements] ([date_id]
											  ,[item_id]
											  ,[store_id]
											  ,[doc_id]
											  ,[qty]
											  ,[cost_net]
											  ,[cost_grs]
											  ,[sale_net]
											  ,[sale_grs])
			SELECT
				dbo.date_to_int (f.[date]) as [date_id],
				isnull(i.item_id,-1) as [item_id],
				isnull(s.store_id,-1) as [store_id],
				isnull(d.doc_id,-1) as [doc_id],
				sum([qty]) as [qty],
				sum([cost_net]) as [cost_net], /*себ. без НДС*/
				sum([cost_grs]) as [cost_grs], /*себ. с НДС*/
				sum([sale_net]) as [sale_net], /*продажа. без НДС*/
				sum([sale_grs]) as [sale_grs]  /*продажа. с НДС*/
			from [stg].[fct_movements] f with(nolock)
			left join [dbo].[dim_item] i with(nolock, index ([ix_dim_item__item_rref&item_id]))
				ON f.item_source_id = i.item_source_id
			left join [dbo].[dim_store] s with(nolock, index ([ix_dim_store__store_rref&store_id]))
				ON f.store_source_id = s.store_source_id
			left join [dbo].[dim_doc] d with(nolock, index ([ix_dim_doc__doc_source_id&doc_type&item_id]))
				ON f.doc_source_id = d.doc_source_id
				and f.doc_type = d.doc_type
			group by dbo.date_to_int (f.[date]),
				isnull(i.item_id,-1),
				isnull(s.store_id,-1),
				isnull(d.doc_id,-1)




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