USE [OrganicNeva_Nekhvyadovich]
GO
/****** Object:  StoredProcedure [dbo].[check_message]    Script Date: 23.11.2020 10:56:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[p_lasmart_check_message] (@d_start int, @d_finish int)
	
AS
BEGIN
--Пример запуска
--exec [p_lasmart_check_message] @d_start = 20190601, @d_finish = 20190831

	
	SET NOCOUNT ON;

    declare @body nvarchar(MAX)
	declare @error_count int
	declare @importance varchar(6) = 'Normal'

	CREATE TABLE #tmp_error(
	[dm] int,
    [name] nvarchar(500),
    [order_type] nvarchar(100),
    [dwh_kol] money,
    [dwh_sum] money,
    [olap_kol] money,
    [olap_sum] money
	)


INSERT INTO #tmp_error
SELECT  d.m,
        st.[name],
        t1.[OperTypeID],
		sum(q_m) as q_m,
        sum(c_m) as c_m,
        sum(q_o)  as q_o,
		sum(c_o)  as c_o
FROM (
        select [dt],
		       [OperTypeID],
			   [id_store],
			   sum([quantity]) as q_m,
			   sum(sale) as c_m,
			   0 as q_o,
               0 as c_o

        from [lasmart_v_fact_movement]
		WHERE (dt between 20190601  and 20190831) and
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
			   sum(sale) as c_o

        from [lasmart_v_fact_movement_FROM_OLAP]
		WHERE (dt between 20190601  and 20190831) and
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

having  sum(q_m) - sum(q_o) != 0 or
        sum(c_m) - sum(c_o) != 0


	SELECT @error_count = count(*) FROM #tmp_error

		SET @body =
			N'<html>
			<head>
			<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
			<title></title>
			</head>
			<body style="margin: 0px; padding: 0px;"> 
		    <br><span style = "background-color:white; color:black"><font face="Calibri" size="3" style="font-weight: normal;">Отчет о сверке данных ОЛАП куба и данных ХД от: ' + CONVERT(nvarchar,CAST(GETDATE() as date)) + '</span><br/>'

	IF @error_count > 0
	BEGIN		
    SET @body = @body + N'<br><span style = "background-color:red; color:white"><font face="Calibri" size="3" style="font-weight: normal;">Обнаружено расхождений: '+ CONVERT(nvarchar,@error_count) + N'</span><br/>'
     set @body = @body +
			N'	<table border="0" bordercolor="#d18d8d" width="100%" cellpadding="0" cellspacing="0" style="font:12pt sans-serif; white-space: nowrap; font-family: Calibri, Arial; border-spacing:0px;">
				<tr><th bgcolor="#73C2FB" style="padding: 5px; font-weight: normal; color: black;">Месяц</th>
				<th bgcolor="#73C2FB" style="padding: 5px; font-weight: normal; color: black;">Магазин</th>
				<th bgcolor="#73C2FB" style="padding: 5px; font-weight: normal; color: black;">Тип движения</th>
				<th bgcolor="#73C2FB" style="padding: 5px; font-weight: normal; color: black;">DWH Количество, шт.</th>
				<th bgcolor="#73C2FB" style="padding: 5px; font-weight: normal; color: black;">DWH Сумма, руб.</th>
				<th bgcolor="#73C2FB" style="padding: 5px; font-weight: normal; color: black;">OLAP Количество, шт.</th>
				<th bgcolor="#73C2FB" style="padding: 5px; font-weight: normal; color: black;">OLAP Сумма, руб.</th>
			'
			+
							isnull(replace(replace(CAST(
							(SELECT 
			N'<td bgcolor="#efefef" style="padding: 5px; text-align: center; border-bottom: 2px solid #e8e8e8; color: black;">' + CONVERT(nvarchar,[dm]) + N'</td>'+
			N'<td bgcolor="#efefef" style="padding: 5px; text-align: center; border-bottom: 2px solid #e8e8e8; color: black;">' + CONVERT(nvarchar(500),[name]) + N'</td>'+
			N'<td bgcolor="#efefef" style="padding: 5px; text-align: center; border-bottom: 2px solid #e8e8e8; color: black;">' + CONVERT(nvarchar,[order_type]) + N'</td>'+
			N'<td bgcolor="#efefef" style="padding: 5px; text-align: center; border-bottom: 2px solid #e8e8e8; color: black;">' + CONVERT(nvarchar,[dwh_kol]) + N'</td>'+
			N'<td bgcolor="#efefef" style="padding: 5px; text-align: center; border-bottom: 2px solid #e8e8e8; color: black;">' + CONVERT(nvarchar,[dwh_sum]) + N'</td>'+
			N'<td bgcolor="#efefef" style="padding: 5px; text-align: center; border-bottom: 2px solid #e8e8e8; color: black;">' + CONVERT(nvarchar,[olap_kol]) + N'</td>'+
			N'<td bgcolor="#efefef" style="padding: 5px; text-align: center; border-bottom: 2px solid #e8e8e8; color: black;">' + CONVERT(nvarchar,[olap_sum]) + N'</td>'
							FROM #tmp_error
							ORDER BY [dm]
							FOR XML PATH('tr'), TYPE)
							AS NVARCHAR(MAX)), '&gt;', '>'), '&lt;', '<'), N'') +
							N'</table>
			'
        END
	ELSE
	BEGIN
	SET @body = @body + N'<br><span style="background-color: green; color: white;"><font face="Calibri" size="3" style="font-weight: normal;">Расхождений в данных DWH и OLAP куба не обнаружено</span><br/>'
	END
	
	SET @body = @body +
		N'<hr color="#e9e9e9" style="margin-top: 40px;"/>
			<table border="0" width="100%" cellspacing="0" cellpadding="0" style="margin: 0px auto; padding: 0px auto; margin-top: 0px; background-color: white;">
				<tr><td align="center"><font face="Calibri" color="#525266" size="3" style="line-height:20px;"><b><i>Отчет о сверке данных:</b></i> <a href="mailto:nekhvyadovich@lasmart.ru" style="color:#28166f;text-decoration:none;">nekhvyadovich@lasmart.ru</a></font>				
				</td></tr>
			</table>
		</td></tr></table>
		</body>
		</html>'


	IF OBJECT_ID(N'tempdb..#tmp_error', N'U') IS NOT NULL 
				DROP TABLE #tmp_error

	EXEC msdb.dbo.sp_send_dbmail  
		@profile_name = 'noreply@lasmart.ru',  --необходимо настроить почтовый профиль
		@recipients = 'nekhvyadovich@lasmart.ru',  --получатели  ;		
		@body = @body,  
		@subject = 'Отчет о сверке данных ' ,
		@importance = @importance,
		@body_format = 'HTML' 


END
