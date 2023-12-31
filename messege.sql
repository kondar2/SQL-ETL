USE [OrganicNeva_Nekhvyadovich]
GO
/****** Object:  StoredProcedure [dbo].[check_message]    Script Date: 19.11.2020 15:36:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[check_message]
	
AS
BEGIN
	
	SET NOCOUNT ON;

    declare @body nvarchar(MAX)
	declare @error_count int
	declare @importance varchar(6) = 'Normal'

	SET @body =
			N'<html>
			<head>
			<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
			<title></title>
			</head>
			<body style="margin: 0px; padding: 0px;"> 
				<table border="0" style="margin: 0px auto; max-width: 800px; padding: 70px 30px 50px 30px; background-color: white; ">
				<tr><td><table border="0">
					<tr><td><img src="http://lasmart.ru/theme/lasmart/img/logo.jpg" width="153" height="58" style="margin: 7px 30px 30px 0;"></td>
					<td><h1><font face="Cambria" color="#383484" size="4">Отчет о проверке корректности<br />обработки аналитики от ' + CONVERT(NVARCHAR(10),GETDATE(),120) + '</font></h1></td></tr>
				</table>
			'

	set @body = @body + N'<br><span><font face="Calibri" color="#000000" size="3" style="font-weight: normal;">Отчет о сверке данных ОЛАП куба и данных ХД от :<span style="text-decoration: underline; "></span><br/>' 
		 

			set @body = @body +
			N'	<table border="0" bordercolor="#d18d8d" width="100%" cellpadding="0" cellspacing="0" style="font:12pt sans-serif; font-family: Calibri, Arial; border-spacing:0px;">
				<tr><th bgcolor="#e36060" style="padding: 5px; font-weight: normal; color: white;">Название процедуры</th>
				<th bgcolor="#e36060" style="padding: 5px; font-weight: normal; color: white;">Время запуска</th>
				<th bgcolor="#e36060" style="padding: 5px; font-weight: normal; color: white;">Номер ошибки</th>
				<th bgcolor="#e36060" style="padding: 5px; font-weight: normal; color: white;">Описание ошибки</th>			
			'+
							isnull(replace(replace(CAST(
							(SELECT 
			N'<td bgcolor="#efefef" style="padding: 5px; text-align: center; border-bottom: 2px solid #e8e8e8;">' + CONVERT(nvarchar,[name]) + N'</td>'+
			N'<td bgcolor="#efefef" style="padding: 5px; text-align: center; border-bottom: 2px solid #e8e8e8;">' + CONVERT(nvarchar,convert(nvarchar,[date_time],20)) + N'</td>'+
			N'<td bgcolor="#efefef" style="padding: 5px; text-align: center; border-bottom: 2px solid #e8e8e8;">' + CONVERT(nvarchar,[err_number]) + N'</td>'+
			N'<td bgcolor="#efefef" style="padding: 5px; text-align: center; border-bottom: 2px solid #e8e8e8;">' + CONVERT(nvarchar(255),[err_message]) + N'</td>'		
							from [oth].[sup_log]
							where [state_name] = 'error'
							and [system_user] = 'KIFR-RU\svc_DWH'
							and [date_time] > = cast(GETDATE() as date)
							FOR XML PATH('tr'), TYPE)
							AS NVARCHAR(MAX)), '&gt;', '>'), '&lt;', '<'), N'') +
							N'</table>
										'


--EXECUTE msdb.dbo.sysmail_help_profileaccount_sp;  


	EXEC msdb.dbo.sp_send_dbmail  
		@profile_name = 'lasmart',  --необходимо настроить почтовый профиль
		@recipients = 'kondar03@gmail.com',  --получатели  ;		
		@body = @body,  
		@subject = 'Обновление BI RetailAnalytics ' ,
		@importance = @importance,
		@body_format = 'HTML' 


END
