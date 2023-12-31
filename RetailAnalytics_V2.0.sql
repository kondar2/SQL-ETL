USE [master]
GO
/****** Object:  Database [RetailAnalytics]    Script Date: 05.03.2020 11:51:39 ******/
CREATE DATABASE [RetailAnalytics]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'RetailAnalytics', FILENAME = N'C:\Program Files\Microsoft SQL Server 2019\MSSQL15.MSSQLSERVER\MSSQL\DATA\RetailAnalytics.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'RetailAnalytics_log', FILENAME = N'C:\Program Files\Microsoft SQL Server 2019\MSSQL15.MSSQLSERVER\MSSQL\DATA\RetailAnalytics_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [RetailAnalytics] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [RetailAnalytics].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [RetailAnalytics] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [RetailAnalytics] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [RetailAnalytics] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [RetailAnalytics] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [RetailAnalytics] SET ARITHABORT OFF 
GO
ALTER DATABASE [RetailAnalytics] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [RetailAnalytics] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [RetailAnalytics] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [RetailAnalytics] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [RetailAnalytics] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [RetailAnalytics] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [RetailAnalytics] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [RetailAnalytics] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [RetailAnalytics] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [RetailAnalytics] SET  DISABLE_BROKER 
GO
ALTER DATABASE [RetailAnalytics] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [RetailAnalytics] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [RetailAnalytics] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [RetailAnalytics] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [RetailAnalytics] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [RetailAnalytics] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [RetailAnalytics] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [RetailAnalytics] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [RetailAnalytics] SET  MULTI_USER 
GO
ALTER DATABASE [RetailAnalytics] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [RetailAnalytics] SET DB_CHAINING OFF 
GO
ALTER DATABASE [RetailAnalytics] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [RetailAnalytics] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [RetailAnalytics] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'RetailAnalytics', N'ON'
GO
ALTER DATABASE [RetailAnalytics] SET QUERY_STORE = OFF
GO
USE [RetailAnalytics]
GO
/****** Object:  User [WIN-9ILM1LFDQC3\vlailin]    Script Date: 05.03.2020 11:51:39 ******/
--CREATE USER [WIN-9ILM1LFDQC3\vlailin] FOR LOGIN [WIN-9ILM1LFDQC3\vlailin] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  Schema [oth]    Script Date: 05.03.2020 11:51:39 ******/
CREATE SCHEMA [oth]
GO
/****** Object:  Schema [stg]    Script Date: 05.03.2020 11:51:39 ******/
CREATE SCHEMA [stg]
GO
/****** Object:  UserDefinedFunction [dbo].[date_to_int]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Дружинин
-- Create date: 2017-06-02
-- Description: из даты в int
-- =============================================
--select dbo.date_to_int('2017-01-01')
CREATE FUNCTION [dbo].[date_to_int]
(
	@date date
)
RETURNS int
AS
BEGIN
	
	declare @res_date as int

	select @res_date = year(@date) * 10000 + month(@date) * 100 + day(@date)

	return @res_date

END


GO
/****** Object:  UserDefinedFunction [dbo].[int_dateadd]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Дружинин
-- Create date: 2017-06-02
-- Description: Прибавить n дней или месяцев или лет к дате типа int
-- =============================================
--select [dbo].[int_dateadd]('yy',5,20170130) as dt 
--select [dbo].[int_dateadd]('dd',5,20170130) as dt 
--select [dbo].[int_dateadd]('mm',5,20170130) as dt 
CREATE FUNCTION [dbo].[int_dateadd]
(
	@date_format nvarchar(10),
	@number int,
	@date_int int
)
RETURNS int
AS
BEGIN
	
	declare @res_date date
	declare @res_date_int int

	if(@date_format = 'd' or @date_format = 'dd')
	begin
		select @res_date = DATEADD(dd,@number,cast(cast(@date_int as varchar)as date ))		
	end		
	if(@date_format = 'm' or @date_format = 'mm')
	begin
		select @res_date = DATEADD(m,@number,cast(cast(@date_int as varchar)as date ))
	end	
	if(@date_format = 'yy' or @date_format = 'yyyy')
	begin
		select @res_date = DATEADD(yy,@number,cast(cast(@date_int as varchar)as date ))
	end				
	

	set @res_date_int = year(@res_date) * 10000 + month(@res_date) * 100 + day(@res_date)
	return 	@res_date_int

END




GO
/****** Object:  UserDefinedFunction [dbo].[int_datediff]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Дружинин
-- Create date: 2017-06-02
-- Description: Разность дат типа int
-- =============================================
--select [dbo].[int_datediff]('yy',20160130,20170130) as dt 
--select [dbo].[int_datediff]('dd',20160130,20170130) as dt 
--select [dbo].[int_datediff]('mm',20160130,20170130) as dt 
CREATE FUNCTION [dbo].[int_datediff]
(
	@date_format nvarchar(10),
	@date_start_int int,
	@date_end_int int
)
RETURNS int
AS
BEGIN
	
	declare @res int

	declare @date_start date
	declare @date_end date

	set @date_start = cast(cast(@date_start_int as varchar)as datetime )
	set @date_end = cast(cast(@date_end_int as varchar)as datetime )

	if(@date_format = 'd' or @date_format = 'dd')
	begin
		select @res = DATEDIFF(dd, @date_start, @date_end)		
	end		
	if(@date_format = 'm' or @date_format = 'mm')
	begin
		select @res = DATEDIFF(m, @date_start, @date_end)	
	end	
	if(@date_format = 'yy' or @date_format = 'yyyy')
	begin
		select @res = DATEDIFF(yy, @date_start, @date_end)	
	end				
	
		
	return @res

END




GO
/****** Object:  UserDefinedFunction [dbo].[int_day]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Дружинин
-- Create date: 2017-06-02
-- Description: Номер дня из даты типа int
-- =============================================
--select dbo.int_day(20170101)
CREATE FUNCTION [dbo].[int_day]
(
	@date_int int
)
RETURNS int
AS
BEGIN
	
	declare @res_day as int

	select @res_day = day(cast(cast(@date_int as varchar) as date))

	return @res_day

END


GO
/****** Object:  UserDefinedFunction [dbo].[int_getdate]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Дружинин
-- Create date: 2017-06-02
-- Description: Текущая дата дат типа int
-- =============================================
--select [dbo].[int_getdate]()
create FUNCTION [dbo].[int_getdate]
(	
)
RETURNS int
AS
BEGIN
	
	declare @res int

	set @res = year(GETDATE()) * 10000 + month(GETDATE()) * 100 + day(GETDATE())	
			
	return @res

END



GO
/****** Object:  UserDefinedFunction [dbo].[int_month]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Дружинин
-- Create date: 2017-06-02
-- Description: Номер месяца из даты типа int
-- =============================================
--select dbo.int_month(20170101)
create FUNCTION [dbo].[int_month]
(
	@date_int int
)
RETURNS int
AS
BEGIN
	
	declare @res_month as int

	select @res_month = month(cast(cast(@date_int as varchar) as date))

	return @res_month

END


GO
/****** Object:  UserDefinedFunction [dbo].[int_to_date]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Дружинин
-- Create date: 2017-06-02
-- Description: из int в дату
-- =============================================
--select dbo.int_to_date(20170101)
CREATE FUNCTION [dbo].[int_to_date]
(
	@date_int int
)
RETURNS date
AS
BEGIN
	
	declare @res as date

	select @res = cast(cast(@date_int as varchar) as date)

	return @res

END


GO
/****** Object:  UserDefinedFunction [dbo].[int_year]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Дружинин
-- Create date: 2017-06-02
-- Description: Номер года из даты типа int
-- =============================================
--select int_year(20170101)
CREATE FUNCTION [dbo].[int_year]
(
	@date_int int
)
RETURNS int
AS
BEGIN
	
	declare @res_year as int

	select @res_year = year(cast(cast(@date_int as varchar) as date))

	return @res_year

END


GO
/****** Object:  UserDefinedFunction [dbo].[split]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--select * from dbo.split ('sadsad,adsad,asdasd',',') as t

create Function [dbo].[split](
   @InputText Varchar(max), -- The text to be split into rows
   @Delimiter Varchar(10)) -- The delimiter that separates tokens.
                           -- Can be multiple characters, or empty

RETURNS @Array TABLE (
   TokenID Int PRIMARY KEY IDENTITY(1,1), --Comment out this line if
                                          -- you don't want the
                                          -- identity column
   Value Varchar(max))

AS

-----------------------------------------------------------
-- Function Split                                        --
--    • Returns a Varchar rowset from a delimited string --
-----------------------------------------------------------

BEGIN

   DECLARE
      @Pos Int,        -- Start of token or character
      @End Int,        -- End of token
      @TextLength Int, -- Length of input text
      @DelimLength Int -- Length of delimiter

-- Len ignores trailing spaces, thus the use of DataLength.
-- Note: if you switch to NVarchar input and output, you'll need to divide by 2.
   SET @TextLength = DataLength(@InputText)

-- Exit function if no text is passed in
   IF @TextLength = 0 RETURN

   SET @Pos = 1
   SET @DelimLength = DataLength(@Delimiter)

   IF @DelimLength = 0 BEGIN -- Each character in its own row
      WHILE @Pos <= @TextLength BEGIN
         INSERT @Array (Value) VALUES (SubString(@InputText,@Pos,1))
         SET @Pos = @Pos + 1
      END
   END
   ELSE BEGIN
      -- Tack on delimiter to 'see' the last token
      SET @InputText = @InputText + @Delimiter
      -- Find the end character of the first token
      SET @End = CharIndex(@Delimiter, @InputText)
      WHILE @End > 0 BEGIN
         -- End > 0, a delimiter was found: there is a(nother) token
         INSERT @Array (Value) VALUES (SubString(@InputText, @Pos, @End - @Pos))
         -- Set next search to start after the previous token
         SET @Pos = @End + @DelimLength
         -- Find the end character of the next token
         SET @End = CharIndex(@Delimiter, @InputText, @Pos)
      END
   END
   
   RETURN

END




GO
/****** Object:  Table [dbo].[dim_date]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dim_date](
	[date_id] [int] NOT NULL,
	[date_time] [datetime] NULL,
	[date_name] [char](10) NULL,
	[day_type_id] [int] NULL,
	[day_type_name] [nvarchar](255) NULL,
	[weekday_number] [int] NULL,
	[weekday_name] [nvarchar](255) NULL,
	[week_id] [int] NULL,
	[week_name] [char](9) NULL,
	[week_full_name] [char](14) NULL,
	[week_number] [int] NULL,
	[month_id] [int] NULL,
	[month_name] [nvarchar](255) NULL,
	[month_full_name] [nvarchar](255) NULL,
	[month_number] [int] NULL,
	[quarter_id] [int] NULL,
	[quarter_name] [char](9) NULL,
	[quarter_full_name] [char](14) NULL,
	[year_id] [int] NULL,
	[year_name] [char](4) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [ix_cl_dim_Date__date_id]    Script Date: 05.03.2020 11:51:39 ******/
CREATE CLUSTERED INDEX [ix_cl_dim_Date__date_id] ON [dbo].[dim_date]
(
	[date_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  View [dbo].[v_olap_dim_date]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[v_olap_dim_date]
AS
SELECT [date_id]
      ,[date_time]
      ,[date_name]
      ,[day_type_id]
      ,[day_type_name]
      ,[weekday_number]
      ,[weekday_name]
      ,[week_id]
      ,[week_name]
      ,[week_full_name]
      ,[week_number]
      ,[month_id]
      ,[month_name]
      ,[month_full_name]
      ,[month_number]
      ,[quarter_id]
      ,[quarter_name]
      ,[quarter_full_name]
      ,[year_id]
      ,[year_name]
FROM [dbo].[dim_Date] with(nolock)
where [date_id] >= 20080101
  and date_id < (year(GETDATE()) + 1) * 10000 + 100 + 1

    
UNION ALL

SELECT
	   190001 AS [date_id]
      ,'1900-01-01' AS [date_time]
      ,'01.01.1900' AS [date_name]
      ,1 AS [day_type_id]
      ,'Рабочий' AS [day_type_name]
      ,1 AS [weekday_number]
      ,'Понедельник' AS [weekday_name]
      ,190001 AS [week_id]
      ,'01 Неделя' AS [week_name]
      ,'1900/01 Неделя' AS [week_full_name]
      ,1 AS [week_number]
      ,190001 AS [month_id]
      ,'Январь' AS [month_name]
      ,'1900/Январь' AS [month_full_name]
      ,1 AS [month_number]
      ,19001 AS [quarter_id]
      ,'1 квартал' AS [quarter_name]
      ,'1900/1 квартал' AS [quarter_full_name]
      ,1900 AS [year_id]
      ,'1900' AS [year_name]







GO
/****** Object:  Table [dbo].[fct_movements]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fct_movements](
	[date_id] [int] NULL,
	[item_id] [int] NULL,
	[store_id] [smallint] NULL,
	[doc_id] [int] NULL,
	[qty] [money] NULL,
	[cost_net] [money] NULL,
	[cost_grs] [money] NULL,
	[sale_net] [money] NULL,
	[sale_grs] [money] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [ix_cl_fct_movements_date_id]    Script Date: 05.03.2020 11:51:39 ******/
CREATE CLUSTERED INDEX [ix_cl_fct_movements_date_id] ON [dbo].[fct_movements]
(
	[date_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[fct_stocks]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fct_stocks](
	[date_id] [int] NULL,
	[item_id] [int] NULL,
	[store_id] [smallint] NULL,
	[qty] [money] NULL,
	[cost_net] [money] NULL,
	[cost_grs] [money] NULL,
	[sale_net] [money] NULL,
	[sale_grs] [money] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [ix_cl_fct_stocks_date_id]    Script Date: 05.03.2020 11:51:39 ******/
CREATE CLUSTERED INDEX [ix_cl_fct_stocks_date_id] ON [dbo].[fct_stocks]
(
	[date_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  View [dbo].[v_olap_fct_movements]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[v_olap_fct_movements] AS 
SELECT 
	  [date_id]
	 ,[item_id]	
	 ,[store_id]

	--шт
	,case when [qty] > 0 then [qty] else 0 end AS [qty_in]
	,case when [qty] > 0 then 0 else [qty] end AS [qty_out]
	,[qty]	AS [qty_stock]
	--сумма закупки без НДС
	,case when [cost_net] > 0 then [cost_net] else 0 end AS [cost_net_in]
	,case when [cost_net] > 0 then 0 else [cost_net] end AS [cost_net_out]
	,[cost_net] AS [cost_net_stock]
	--сумма закупки с НДС
	,case when [cost_grs] > 0 then [cost_grs] else 0 end AS [cost_grs_in]
	,case when [cost_grs] > 0 then 0 else [cost_grs] end AS [cost_grs_out]
	,[cost_grs] AS [cost_grs_stock]
	--сумма продажи без НДС
	,case when [sale_net] > 0 then [sale_net] else 0 end AS [sale_net_in]
	,case when [sale_net] > 0 then 0 else [sale_net] end AS [sale_net_out]
	,[sale_net] AS [sale_net_stock]
	--сумма закупки с НДС
	,case when [sale_grs] > 0 then [sale_grs] else 0 end AS [sale_grs_in]
	,case when [sale_grs] > 0 then 0 else [sale_grs] end AS [sale_grs_out]
	,[sale_grs] AS [sale_grs_stock]

	,CAST(NULL AS money) AS [null_money]

FROM [dbo].[fct_movements] with(nolock)

UNION ALL

SELECT 
	 [date_id]
	,[item_id]	
	,[store_id]

	,0     AS [qty_in]
	,0	   AS [qty_out]
	,[qty] AS [qty_stock]

	,0				   AS [cost_net_in]
	,0				   AS [cost_net_out]
	,[cost_net] AS [cost_net_stock]

	,0				   AS [cost_grs_in]
	,0				   AS [cost_grs_out]
	,[cost_grs] AS [cost_grs_stock]

	,0				   AS [sale_net_in]
	,0				   AS [sale_net_out]
	,[sale_net] AS [sale_net_stock]

	,0				   AS [sale_grs_in]
	,0				   AS [sale_grs_out]
	,[sale_grs] AS [sale_grs_stock]

	,CAST(NULL AS money) AS [null_money]

FROM [dbo].[fct_stocks] with(nolock)








GO
/****** Object:  Table [oth].[sup_log]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [oth].[sup_log](
	[date_time] [datetime] NULL,
	[name] [nvarchar](255) NULL,
	[system_user] [nvarchar](255) NULL,
	[state_name] [nvarchar](255) NULL,
	[row_count] [int] NULL,
	[err_number] [int] NULL,
	[err_severity] [int] NULL,
	[err_state] [int] NULL,
	[err_object] [nvarchar](max) NULL,
	[err_line] [int] NULL,
	[err_message] [nvarchar](max) NULL,
	[sp_id] [int] NULL,
	[duration] [nvarchar](50) NULL,
	[duration_ord] [int] NULL,
	[description] [nvarchar](500) NULL,
	[input_parametrs] [nvarchar](500) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [ix_cl_f_SUP_LOG__date_time]    Script Date: 05.03.2020 11:51:39 ******/
CREATE CLUSTERED INDEX [ix_cl_f_SUP_LOG__date_time] ON [oth].[sup_log]
(
	[date_time] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  View [oth].[v_sup_log]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view  [oth].[v_sup_log]AS 
SELECT [date_time]
      ,[name]
      ,[system_user]
      ,[state_name]
      ,[row_count]
      ,[err_number]
      --,[err_severity]
      --,[err_state]
      --,[err_object]
      --,[err_line]
      ,[err_message]
      --,[sp_id]
      ,[duration]
      ,[duration_ord]
      --,[description]
      ,[input_parametrs]
  FROM [oth].[SUP_LOG]





GO
/****** Object:  Table [dbo].[dim_country]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dim_country](
	[country_id] [smallint] IDENTITY(1,1) NOT NULL,
	[country_source_id] [binary](16) NULL,
	[country_name] [nvarchar](150) NULL,
	[country_desc] [nvarchar](150) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [ix_cl_dim_country_country_id]    Script Date: 05.03.2020 11:51:39 ******/
CREATE CLUSTERED INDEX [ix_cl_dim_country_country_id] ON [dbo].[dim_country]
(
	[country_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  View [dbo].[v_olap_dim_country]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[v_olap_dim_country]
AS
SELECT
	 f.[country_id] 
	,f.[country_source_id] -- Код страны

	,f.[country_desc] -- Страна наименование

FROM [dbo].[dim_Country] as f with(nolock)

UNION ALL

SELECT
	 -1 AS [country_id]
	,-1	 AS [country_source_id]
	,'Н/Д'	 AS [country_desc]
GO
/****** Object:  Table [dbo].[dim_item]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dim_item](
	[item_id] [int] IDENTITY(1,1) NOT NULL,
	[item_source_id] [binary](16) NULL,
	[item_name] [nvarchar](150) NULL,
	[item_desc] [nvarchar](150) NULL,
	[country_id] [smallint] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [ix_cl_dim_item_item_id]    Script Date: 05.03.2020 11:51:39 ******/
CREATE CLUSTERED INDEX [ix_cl_dim_item_item_id] ON [dbo].[dim_item]
(
	[item_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  View [dbo].[v_olap_dim_item]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_olap_dim_item]
AS
SELECT
	 f.[item_id] 
	,f.item_source_id -- Код номенклатуры
	,rtrim(ltrim(replace(replace(replace(f.[item_desc],char(9),''),char(10),''),char(13),''))) as [item_desc] --пример как убрать спецсимволы и пробелы
	,ISNULL([dim_Country].[country_desc], 'Н/Д') AS [country_desc] -- Страна

FROM [dbo].[dim_Item] as f with(nolock)
LEFT JOIN [dbo].[dim_Country] with(nolock)
	ON f.country_id = dim_Country.country_id

UNION ALL

SELECT
	 -1 AS [item_id]
	,-1	 AS item_source_id
	,'Н/Д'	 AS [item_desc]
	,'Н/Д'	 AS [country_desc]

GO
/****** Object:  Table [dbo].[dim_store]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dim_store](
	[store_id] [smallint] IDENTITY(1,1) NOT NULL,
	[store_source_id] [binary](16) NULL,
	[store_name] [nvarchar](150) NULL,
	[store_desc] [varchar](150) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [ix_cl_dim_store_store_id]    Script Date: 05.03.2020 11:51:39 ******/
CREATE CLUSTERED INDEX [ix_cl_dim_store_store_id] ON [dbo].[dim_store]
(
	[store_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  View [dbo].[v_olap_dim_store]    Script Date: 05.03.2020 11:51:39 ******/
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
/****** Object:  Table [dbo].[fct_sales]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fct_sales](
	[date_id] [int] NULL,
	[doc_id] [int] NULL,
	[item_id] [int] NULL,
	[store_id] [smallint] NULL,
	[qty] [money] NULL,
	[cost_net] [money] NULL,
	[cost_grs] [money] NULL,
	[sale_net] [money] NULL,
	[sale_grs] [money] NULL,
	[purch_grs] [money] NULL,
	[purch_net] [money] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [ix_cl_fct_sales_date_id]    Script Date: 05.03.2020 11:51:39 ******/
CREATE CLUSTERED INDEX [ix_cl_fct_sales_date_id] ON [dbo].[fct_sales]
(
	[date_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  View [dbo].[v_olap_fct_sales]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[v_olap_fct_sales] AS 
SELECT 
	 [date_id]
	,[doc_id]
	,[item_id]
	,[store_id]

	,[qty] -- Объем продаж шт = Оборот шт
	,[cost_net] -- Сумма закупки без НДС = Оборот себ без НДС
	,[cost_grs] -- Сумма закупки с НДС = Оборот себ
	,[sale_net] -- Сумма продажи без НДС = Оборот руб без НДС
	,[sale_grs] -- Сумма продажи с НДС = Оборот руб

FROM [dbo].[fct_sales]  as f with(nolock)
GO
/****** Object:  Table [oth].[olap_MeasureGroupSettings]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [oth].[olap_MeasureGroupSettings](
	[CubeId] [nvarchar](500) NOT NULL,
	[MeasureGroupId] [nvarchar](500) NOT NULL,
	[Partitioned] [bit] NOT NULL,
	[Period] [nvarchar](30) NULL,
	[PartitionPrefix] [nvarchar](500) NULL,
	[SQLQuery] [nvarchar](500) NOT NULL,
	[Lag] [int] NULL,
	[Lead] [int] NULL,
	[PartitionSlice] [nvarchar](500) NULL,
	[AggregationDesign] [nvarchar](500) NULL,
 CONSTRAINT [PK_t_olap_MeasureGroupSettings] PRIMARY KEY CLUSTERED 
(
	[CubeId] ASC,
	[MeasureGroupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [oth].[olap_MeasureGroups]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [oth].[olap_MeasureGroups](
	[CubeId] [nvarchar](500) NOT NULL,
	[MeasureGroupId] [nvarchar](500) NOT NULL,
	[MeasureGroupName] [nvarchar](500) NOT NULL,
	[Description] [nvarchar](500) NULL,
	[DataSourceId] [nvarchar](500) NULL,
 CONSTRAINT [PK_t_olap_MeasureGroup] PRIMARY KEY CLUSTERED 
(
	[CubeId] ASC,
	[MeasureGroupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [oth].[olap_BICubes]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [oth].[olap_BICubes](
	[CubeId] [nvarchar](500) NOT NULL,
	[CubeName] [nvarchar](500) NOT NULL,
	[Description] [nvarchar](500) NULL,
 CONSTRAINT [PK_t_olap_BICube] PRIMARY KEY CLUSTERED 
(
	[CubeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[v_olap_ProcessingView]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[v_olap_ProcessingView] as 

with PeriodTabLag as ( 
					select 
						'Month' as [Period],
						month_id as [PeriodId],
						cast(year([date_time]) as nvarchar (20)) + ' ' + right('0'+cast(Month([date_time]) as nvarchar (20)),2) as [PeriodName],
						ROW_NUMBER()OVER ( order by month_id desc) as RNPeriod,
						min(date_id) as TimeMinId,
						max(date_id) as TimeMaxId
					from dim_date
					where [date_time] <= eomonth(cast(getdate() as date))
					group by month_id,
						cast(year([date_time]) as nvarchar (20)) + ' ' + right('0'+cast(Month([date_time]) as nvarchar (20)),2)

					union all

					select 
						'Quarter' as [Period],
						quarter_id as [PeriodId],
						cast(year([date_time]) as nvarchar (20)) + ' ' + cast(datepart(qq, ([date_time])) as nvarchar (20)) as [PeriodName],
						ROW_NUMBER()OVER ( order by quarter_id desc) as RNPeriod,
						min(date_id) as TimeMinId,
						max(date_id) as TimeMaxId
					from dim_date
					where [date_time] <= DATEADD(QQ, DATEDIFF(QQ,0,getdate()) + 1, -1) 
					group by quarter_id,
						cast(year([date_time]) as nvarchar (20)) + ' ' + cast(datepart(qq, ([date_time])) as nvarchar (20))
					
					union all

					select 
						'Year' as [Period],
						year_id as [PeriodId],
						cast(year_id as nvarchar (20)) as [PeriodName],
						ROW_NUMBER()OVER ( order by year_id desc) as RNPeriod,
						min(date_id) as TimeMinId,
						max(date_id) as TimeMaxId
					from dim_date
					where [date_time] <= DATEADD(yy, DATEDIFF(yy,0,getdate()) + 1, -1) 
					group by year_id,
						cast(year_id as nvarchar (20))
				  ),
	PeriodTabLead as ( 
					select 
						'Month' as [Period],
						month_id as [PeriodId],
						cast(year([date_time]) as nvarchar (20)) + ' ' + right('0'+cast(Month([date_time]) as nvarchar (20)),2) as [PeriodName],
						ROW_NUMBER()OVER ( order by month_id asc) -1 as RNPeriod,
						min(date_id) as TimeMinId,
						max(date_id) as TimeMaxId
					from dim_date
					where [date_time] >= dateadd(month,datediff(month,0,GetDate()),0) 
						
					group by month_id,
						cast(year([date_time]) as nvarchar (20)) + ' ' + right('0'+cast(Month([date_time]) as nvarchar (20)),2)
					
					union all

					select 
						'Quarter' as [Period],
						quarter_id as [PeriodId],
						cast([quarter_name] as nvarchar (20)) as [PeriodName],
						ROW_NUMBER()OVER ( order by quarter_id asc) -1 as RNPeriod,
						min(date_id) as TimeMinId,
						max(date_id) as TimeMaxId
					from dim_date
					where [date_time] >= dateadd(QQ, datediff(QQ, 0, getdate()), 0)
					group by quarter_id,
						cast([quarter_name] as nvarchar (20))

					union all

					select 
						'Year' as [Period],
						year_id as [PeriodId],
						cast(year_id as nvarchar (20)) as [PeriodName],
						ROW_NUMBER()OVER ( order by year_id asc) -1 as RNPeriod,
						min(date_id) as TimeMinId,
						max(date_id) as TimeMaxId
					from dim_date
					where [date_time] >= dateadd(yy, datediff(yy, 0, getdate()), 0)
					group by year_id,
						cast(year_id as nvarchar (20))
				  )

select
		MS.[CubeId] as [CubeId], 
		MS.[MeasureGroupId] as [MeasureGroupId], 
		C.[CubeName] as [Cube], 
		MG.MeasureGroupName as  [MeasureGroup], 
		MG.[DataSourceId] as [DataSourceId], 
		[PartitionPrefix]+' '+ pt.[PeriodName] as [Partition], 
		replace(replace(MS.[SQLQuery], '@MinTimeKey@', pt.TimeMinId), '@MaxTimeKey@', pt.TimeMaxId) as [SQLQuery],		REPLACE(ms.PartitionSlice,'@SliceKey',cast(pt.[PeriodId] as nvarchar(10)))  as PartitionSlice,
		isnull(MS.[AggregationDesign], '') as [AggregationDesign]
from oth.olap_MeasureGroupSettings MS (nolock)
join oth.olap_BICubes C (nolock) 
	on MS.CubeId = C.CubeId
join oth.olap_MeasureGroups MG (nolock) 
	on MS.CubeId = MG.CubeId 
		and MS.MeasureGroupId= MG.MeasureGroupId
join PeriodTabLag as pt
	on pt.[Period] = ms.[Period]
		and pt.[RNPeriod] <= ms.Lag

union		

select
		MS.[CubeId], 
		MS.[MeasureGroupId], 
		C.[CubeName] as [Cube], 
		MG.MeasureGroupName as  [MeasureGroup], 
		MG.[DataSourceId] as [DataSourceId], 
		[PartitionPrefix]+' '+ pt.[PeriodName] as [Partition], 
		replace(replace(MS.[SQLQuery], '@MinTimeKey@', pt.TimeMinId), '@MaxTimeKey@', pt.TimeMaxId) as [SQLQuery],		cast(REPLACE(ms.PartitionSlice,'@SliceKey',cast(pt.[PeriodId] as nvarchar)) as nvarchar(255)) as PartitionSlice,
		isnull(MS.[AggregationDesign], '') as [AggregationDesign]
from oth.olap_MeasureGroupSettings MS (nolock)
join oth.olap_BICubes C (nolock) 
	on MS.CubeId = C.CubeId
join oth.olap_MeasureGroups MG (nolock) 
	on MS.CubeId = MG.CubeId 
		and MS.MeasureGroupId= MG.MeasureGroupId
join PeriodTabLead as pt
	on pt.[Period] = ms.[Period]
		and ms.Lead >= pt.[RNPeriod]
			and ms.Lead != 0

union 

select
		MS.[CubeId], 
		MS.[MeasureGroupId], 
		C.[CubeName] as [Cube], 
		MG.MeasureGroupName as  [MeasureGroup], 
		MG.[DataSourceId] as [DataSourceId], 
		[PartitionPrefix] as [Partition], 
		MS.[SQLQuery] as [SQLQuery],
		cast(ms.PartitionSlice as nvarchar(255)) as PartitionSlice,
		isnull(MS.[AggregationDesign], '') as [AggregationDesign]
from oth.olap_MeasureGroupSettings MS (nolock)
join oth.olap_BICubes C (nolock) 
	on MS.CubeId = C.CubeId
join oth.olap_MeasureGroups MG (nolock) 
	on MS.CubeId = MG.CubeId 
		and MS.MeasureGroupId= MG.MeasureGroupId
where MS.Partitioned = 0

GO
/****** Object:  View [dbo].[v_olap_dim_time]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[v_olap_dim_time]
AS
SELECT -1 AS [hour_id],	'не указано' AS [hour_desc] UNION ALL
SELECT  0 AS [hour_id],	'00:00' AS [hour_desc] UNION ALL
SELECT  1 AS [hour_id],	'01:00' AS [hour_desc] UNION ALL
SELECT  2 AS [hour_id],	'02:00' AS [hour_desc] UNION ALL
SELECT  3 AS [hour_id],	'03:00' AS [hour_desc] UNION ALL
SELECT  4 AS [hour_id],	'04:00' AS [hour_desc] UNION ALL
SELECT  5 AS [hour_id],	'05:00' AS [hour_desc] UNION ALL
SELECT  6 AS [hour_id],	'06:00' AS [hour_desc] UNION ALL
SELECT  7 AS [hour_id],	'07:00' AS [hour_desc] UNION ALL
SELECT  8 AS [hour_id],	'08:00' AS [hour_desc] UNION ALL
SELECT  9 AS [hour_id],	'09:00' AS [hour_desc] UNION ALL
SELECT 10 AS [hour_id],	'10:00' AS [hour_desc] UNION ALL
SELECT 11 AS [hour_id],	'11:00' AS [hour_desc] UNION ALL
SELECT 12 AS [hour_id],	'12:00' AS [hour_desc] UNION ALL
SELECT 13 AS [hour_id],	'13:00' AS [hour_desc] UNION ALL
SELECT 14 AS [hour_id],	'14:00' AS [hour_desc] UNION ALL
SELECT 15 AS [hour_id],	'15:00' AS [hour_desc] UNION ALL
SELECT 16 AS [hour_id],	'16:00' AS [hour_desc] UNION ALL
SELECT 17 AS [hour_id],	'17:00' AS [hour_desc] UNION ALL
SELECT 18 AS [hour_id],	'18:00' AS [hour_desc] UNION ALL
SELECT 19 AS [hour_id],	'19:00' AS [hour_desc] UNION ALL
SELECT 20 AS [hour_id],	'20:00' AS [hour_desc] UNION ALL
SELECT 21 AS [hour_id],	'21:00' AS [hour_desc] UNION ALL
SELECT 22 AS [hour_id],	'22:00' AS [hour_desc] UNION ALL
SELECT 23 AS [hour_id],	'23:00' AS [hour_desc] 





GO
/****** Object:  View [oth].[v_usage_dataspace]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [oth].[v_usage_dataspace] AS 
SELECT TOP 1000
       --(row_number() over(order by (a1.reserved + ISNULL(a4.reserved,0)) desc))%2 as l1,
       a3.name AS [schemaname],
       a2.name AS [tablename],
       a1.rows as row_count,
      (a1.reserved + ISNULL(a4.reserved,0))* 8 / 1024 AS [reserved_Mb],
       a1.data * 8 / 1024 AS [data_Mb],
      (CASE WHEN (a1.used + ISNULL(a4.used,0)) > a1.data THEN (a1.used + ISNULL(a4.used,0)) - a1.data ELSE 0 END) * 8 / 1024 AS [index_size_Mb],
      (CASE WHEN (a1.reserved + ISNULL(a4.reserved,0)) > a1.used THEN (a1.reserved + ISNULL(a4.reserved,0)) - a1.used ELSE 0 END) * 8 / 1024 AS [unused_Mb]
      --'ALTER TABLE [' + a2.name  + '] REBUILD' as [sql]
  FROM (SELECT ps.object_id,
               SUM(CASE WHEN (ps.index_id < 2) THEN row_count ELSE 0 END) AS [rows],
               SUM(ps.reserved_page_count) AS reserved,
               SUM(CASE WHEN (ps.index_id < 2) THEN (ps.in_row_data_page_count + ps.lob_used_page_count + ps.row_overflow_used_page_count) ELSE (ps.lob_used_page_count + ps.row_overflow_used_page_count) END) AS data,
               SUM(ps.used_page_count) AS used
          FROM sys.dm_db_partition_stats ps
          GROUP BY ps.object_id
       ) AS a1
  LEFT JOIN (SELECT it.parent_id,
                    SUM(ps.reserved_page_count) AS reserved,
                    SUM(ps.used_page_count) AS used
               FROM sys.dm_db_partition_stats ps
               INNER JOIN sys.internal_tables it ON (it.object_id = ps.object_id)
               WHERE it.internal_type IN (202,204)
               GROUP BY it.parent_id
            ) AS a4 ON (a4.parent_id = a1.object_id)
  INNER JOIN sys.all_objects a2  ON ( a1.object_id = a2.object_id )
  INNER JOIN sys.schemas a3 ON (a2.schema_id = a3.schema_id)
  WHERE a2.type <> N'S' and a2.type <> N'IT'
  ORDER BY 1, 2 




GO
/****** Object:  Table [dbo].[dim_doc]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dim_doc](
	[doc_id] [int] IDENTITY(1,1) NOT NULL,
	[doc_source_id] [binary](16) NULL,
	[doc_type] [smallint] NULL,
	[doc_desc] [nvarchar](150) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [ix_cl_dim_doc_doc_id]    Script Date: 05.03.2020 11:51:39 ******/
CREATE CLUSTERED INDEX [ix_cl_dim_doc_doc_id] ON [dbo].[dim_doc]
(
	[doc_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Table [oth].[sup_change_objects_log]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [oth].[sup_change_objects_log](
	[log_id] [int] IDENTITY(1,1) NOT NULL,
	[database_name] [varchar](256) NOT NULL,
	[event_type] [varchar](50) NOT NULL,
	[object_name] [varchar](256) NOT NULL,
	[object_type] [varchar](25) NOT NULL,
	[sql_command] [varchar](max) NOT NULL,
	[event_date] [datetime] NOT NULL,
	[login_name] [varchar](256) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [ix_cl_log_id_sup_change_objects_log]    Script Date: 05.03.2020 11:51:39 ******/
CREATE CLUSTERED INDEX [ix_cl_log_id_sup_change_objects_log] ON [oth].[sup_change_objects_log]
(
	[log_id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Table [oth].[sup_deleted_query_log]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [oth].[sup_deleted_query_log](
	[date_time] [datetime] NULL,
	[spid] [int] NULL,
	[query] [varchar](max) NULL,
	[loginname] [varchar](max) NULL,
	[hostname] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [stg].[fct_movements]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [stg].[fct_movements](
	[date] [date] NULL,
	[item_source_id] [binary](16) NULL,
	[store_source_id] [binary](16) NULL,
	[doc_source_id] [binary](16) NULL,
	[doc_type] [smallint] NULL,
	[qty] [money] NULL,
	[cost_net] [money] NULL,
	[cost_grs] [money] NULL,
	[sale_net] [money] NULL,
	[sale_grs] [money] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ix_dim_country_country_code&country_id]    Script Date: 05.03.2020 11:51:39 ******/
CREATE NONCLUSTERED INDEX [ix_dim_country_country_code&country_id] ON [dbo].[dim_country]
(
	[country_source_id] ASC
)
INCLUDE([country_id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ix_dim_doc_doc_code_doc_type_item_id]    Script Date: 05.03.2020 11:51:39 ******/
CREATE NONCLUSTERED INDEX [ix_dim_doc_doc_code_doc_type_item_id] ON [dbo].[dim_doc]
(
	[doc_source_id] ASC,
	[doc_type] ASC
)
INCLUDE([doc_id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ix_dim_item_item_rref_item_id]    Script Date: 05.03.2020 11:51:39 ******/
CREATE NONCLUSTERED INDEX [ix_dim_item_item_rref_item_id] ON [dbo].[dim_item]
(
	[item_source_id] ASC
)
INCLUDE([item_id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ix_dim_store_store_rref_store_id]    Script Date: 05.03.2020 11:51:39 ******/
CREATE NONCLUSTERED INDEX [ix_dim_store_store_rref_store_id] ON [dbo].[dim_store]
(
	[store_source_id] ASC
)
INCLUDE([store_id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [oth].[sup_change_objects_log] ADD  CONSTRAINT [DF_events_log_event_date]  DEFAULT (getdate()) FOR [event_date]
GO
/****** Object:  StoredProcedure [dbo].[01_fill_stg_fct]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	Заполнение фактов stg
-- =============================================
-- exec fill_stg_fct
CREATE PROCEDURE [dbo].[01_fill_stg_fct]
	@date_from date,
	@date_to date
AS
BEGIN
	
	SET NOCOUNT ON;

	/*факты товародвижений*/	
    exec [stg].[fill_fct_movements] @date_from , @date_to

	/*факты продаж*/	
    --exec [stg].[fill_fct_sales] @date_from , @date_to


END

GO
/****** Object:  StoredProcedure [dbo].[02_fill_dim]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	Заполнение справочной информации. !!!Запускать после заполнения фактов stg слоя!!! exec fill_stg_fct
-- =============================================
-- exec fill_dimmensions
CREATE PROCEDURE [dbo].[02_fill_dim]	
AS
BEGIN
	
	SET NOCOUNT ON;

	/*справочник товаров*/
    exec [dbo].[fill_dim_item]

	/*справочник стран*/
    --exec [dbo].[fill_dim_country]

	/*справочник магазинов*/
    --exec [dbo].[fill_dim_store]

	

END

GO
/****** Object:  StoredProcedure [dbo].[03_fill_dim_by_fct]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	Заполнение справочной информации. !!!Запускать после заполнения фактов stg слоя!!! exec fill_stg_fct
-- =============================================
-- exec fill_dimmensions
CREATE PROCEDURE [dbo].[03_fill_dim_by_fct]	
AS
BEGIN
	
	SET NOCOUNT ON;

	-------------
	/*блок фиктивных справочников на основании фактов stg*/
	-------------
	
	/*справочник документов*/
	exec [dbo].[fill_dim_docs]

END

GO
/****** Object:  StoredProcedure [dbo].[04_fill_fct]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	Заполнение фактов dbo
-- =============================================
-- exec [fill_fct]
CREATE PROCEDURE [dbo].[04_fill_fct]
	@date_from int,
	@date_to int
AS
BEGIN
	
	SET NOCOUNT ON;

	/*факты товародвижений*/	
    exec [dbo].[fill_fct_movements] @date_from , @date_to

	/*остатки на начало месяца*/
	exec [dbo].[fill_fct_stocks]  @date_from , @date_to

	/*продажи*/
	--exec [dbo].[fill_fct_sales]  @date_from , @date_to
	


END


GO
/****** Object:  StoredProcedure [dbo].[check_message]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		
-- Create date: 
-- Description:	Отправка письма со счетчиком ошибок
-- =============================================
CREATE PROCEDURE [dbo].[check_message]
	
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

	--Проверка ETL
	BEGIN		

		set @body = @body + N'<br><span><font face="Calibri" color="#000000" size="3" style="font-weight: normal;">Обновление BI RetailAnalytics выполнено:<span style="text-decoration: underline; "></span><br/>' 
						
		select @error_count = isnull(count(*),0)
		from [oth].[sup_log]
		where [state_name] = 'error'
		and [system_user] = 'KIFR-RU\svc_DWH' --сервисная учетка агента
		and [date_time] > = cast(GETDATE() as date)

		if @error_count = 0
		begin 
			set @body = @body + N'<br><span style="background-color: #5da946; color: white; padding: 1px 5px 1px 5px;">Ошибок в обработке данных (ETL) не возникло</span><br/>'
		end
		else 
		begin 	
			set @body = @body + N'<br><span style="background-color: #e36060; color: white; padding: 1px 5px 1px 5px;">'+ 'Ошибок обработки данных (ETL) = ' + cast(@error_count as nvarchar) +'</span><br/>'
			set @importance = 'High'

			--Список ошибок
			set @body = @body + '<br><span><font face="Calibri" color="#000000" size="3" style="font-weight: normal;">Описание ошибок:<span style="text-decoration: underline; "></span><br/>'
							 
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

		end	
	
	END

	--Проверка Job'ов
	BEGIN
		--!!run_status!!
		--0	Failed
		--1	Succeeded
		--2	Retry (step only)
		--3	Canceled
		--4	In-progress message
		--5	Unknown		
						
		select @error_count = isnull(count(*),0)
		FROM msdb.dbo.sysjobhistory  sjh
		LEFT OUTER JOIN msdb.dbo.sysoperators so1  ON (sjh.operator_id_emailed = so1.id)
		LEFT OUTER JOIN msdb.dbo.sysoperators so2  ON (sjh.operator_id_netsent = so2.id)
		LEFT OUTER JOIN msdb.dbo.sysoperators so3  ON (sjh.operator_id_paged = so3.id),
		msdb.dbo.sysjobs_view sj
		WHERE (sj.job_id = sjh.job_id)
		and sjh.run_date = dbo.int_getdate()
		--and sj.job_id = 'A3ED8775-EE33-42FC-BDF5-3F8E95AEB54B' --RetailAnalytics 1:00
		and sjh.run_status <> 1 --Только те шаги, которые завершились не удачно
		

		if @error_count = 0
		begin 
			set @body = @body + N'<br><span style="background-color: #5da946; color: white; padding: 1px 5px 1px 5px;">Ошибок в работе job-ов не возникло</span><br/>'
		end
		else 	
		begin 			

			set @body = @body + N'<br><span style="background-color: #e36060; color: white; padding: 1px 5px 1px 5px;">'+ 'Ошибок в работе job-ов = ' + cast(@error_count as nvarchar) +'</span><br/>'
			set @importance = 'High'

			--Список ошибок
			set @body = @body + '<br><span><font face="Calibri" color="#000000" size="3" style="font-weight: normal;">Описание ошибок:<span style="text-decoration: underline; "></span><br/>'
							 
			set @body = @body +
			N'	<table border="0" bordercolor="#d18d8d" width="100%" cellpadding="0" cellspacing="0" style="font:12pt sans-serif; font-family: Calibri, Arial; border-spacing:0px;">
				<tr><th bgcolor="#e36060" style="padding: 5px; font-weight: normal; color: white;">Название job-а</th>
				<th bgcolor="#e36060" style="padding: 5px; font-weight: normal; color: white;">Название шага</th>
				<th bgcolor="#e36060" style="padding: 5px; font-weight: normal; color: white;">Время запуска</th>
				<th bgcolor="#e36060" style="padding: 5px; font-weight: normal; color: white;">Статус ошибки</th>
				<th bgcolor="#e36060" style="padding: 5px; font-weight: normal; color: white;">Описание ошибки</th>			
			'+
							isnull(replace(replace(CAST(
							(SELECT 
			N'<td bgcolor="#efefef" style="padding: 5px; text-align: center; border-bottom: 2px solid #e8e8e8;">' + CONVERT(nvarchar,sj.name) + N'</td>'+
			N'<td bgcolor="#efefef" style="padding: 5px; text-align: center; border-bottom: 2px solid #e8e8e8;">' + CONVERT(nvarchar,sjh.step_name) + N'</td>'+
			N'<td bgcolor="#efefef" style="padding: 5px; text-align: center; border-bottom: 2px solid #e8e8e8;">' + convert(nvarchar,cast(cast(sjh.run_date as varchar) as datetime) + 
																																	cast(STUFF(STUFF(STUFF(RIGHT('00000000' + cast(sjh.run_time * 100 AS VARCHAR),8),3,0,':'),6,0,':'),9,0,'.') AS datetime),20) + N'</td>'+
			N'<td bgcolor="#efefef" style="padding: 5px; text-align: center; border-bottom: 2px solid #e8e8e8;">' + CASE 
																														WHEN sjh.run_status = 0 then N'Ошибка'
																														WHEN sjh.run_status = 2 then N'Повторный запуск'
																														WHEN sjh.run_status = 3 then N'Отмена'
																														ELSE N'Прочее'
																													END  + N'</td>'+
			N'<td bgcolor="#efefef" style="padding: 5px; text-align: center; border-bottom: 2px solid #e8e8e8;">' + CONVERT(nvarchar(255),replace(replace(sjh.message,'<',''),'>','')) + N'</td>'		
							FROM msdb.dbo.sysjobhistory  sjh
							LEFT OUTER JOIN msdb.dbo.sysoperators so1  ON (sjh.operator_id_emailed = so1.id)
							LEFT OUTER JOIN msdb.dbo.sysoperators so2  ON (sjh.operator_id_netsent = so2.id)
							LEFT OUTER JOIN msdb.dbo.sysoperators so3  ON (sjh.operator_id_paged = so3.id),
							msdb.dbo.sysjobs_view sj
							WHERE (sj.job_id = sjh.job_id)
							and sjh.run_date = dbo.int_getdate()
							--and sj.job_id = 'A3ED8775-EE33-42FC-BDF5-3F8E95AEB54B' --RetailAnalytics 1:00
							and sjh.run_status <> 1 --Только те шаги, которые завершились не удачно
							order by sj.job_id,sjh.step_id,sjh.run_time
							FOR XML PATH('tr'), TYPE)
							AS NVARCHAR(MAX)), '&gt;', '>'), '&lt;', '<'), N'') +
							N'</table>
			'
		end
	END


	SET @body = @body +
		N'<hr color="#e9e9e9" style="margin-top: 40px;"/>
			<table border="0" width="100%" cellspacing="0" cellpadding="0" style="margin: 0px auto; padding: 0px auto; margin-top: 0px; background-color: white;">
				<tr><td align="center"><font face="Calibri" color="#525266" size="3" style="line-height:20px;"><b><i>Обновление RetailAnalytics:</b></i> <a href="mailto:bannova@lasmart.ru" style="color:#28166f;text-decoration:none;">bannova@lasmart.ru</a></font>				
				</td></tr>
			</table>
		</td></tr></table>
		</body>
		</html>'


	--select @body
	EXEC msdb.dbo.sp_send_dbmail  
		@profile_name = 'dwh-d-101_database_mail_profile',  --необходимо настроить почтовый профиль
		@recipients = 'bannova@lasmart.ru',  --получатели  ;		
		@body = @body,  
		@subject = 'Обновление BI RetailAnalytics ' ,
		@importance = @importance,
		@body_format = 'HTML' ;	


END


GO
/****** Object:  StoredProcedure [dbo].[fill_dim_date]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		
-- Create date: 
-- Description:	
--exec [dbo].[fill_dim_date] '2015-01-01', '2026-01-01'
-- =============================================
CREATE procedure [dbo].[fill_dim_date]
	@date_s date,
	@date_f date 
AS
BEGIN
	SET NOCOUNT ON;
	
	--устанавливаем первый деньо недели - ПОНЕДЕЛЬНИК
	set datefirst 1
	--Очистка таблицы дат перед вставкой
	DELETE t
	FROM [dbo].[dim_Date] t
	WHERE [date_id] >= dbo.date_to_int(@date_s) and 
		[date_id] < dbo.date_to_int(@date_f)

	declare @dt date = @date_s
	--Заполняем таблицу дат в цикле
	WHILE @dt <= @date_f
	BEGIN
		INSERT INTO [dbo].[dim_Date](
			[date_time],
			[date_id],
			[date_name],
			[year_id],
			[year_name],
			[quarter_id],
			[quarter_name],
			[quarter_full_name],
			[month_id],
			[month_name],
			[month_full_name],
			[month_number],
			[week_id],
			[week_name],
			[week_full_name],
			[weekday_number],
			[weekday_name],
			[week_number],
			[day_type_id],
			[day_type_name]
		)
		SELECT
			[date_time] = @dt, 
			[date_id] = convert(int,convert(varchar(8),@dt,112)),
			[date_name] = convert(char(10),@dt,104),
			[year_id] = datepart(yyyy,@dt),
			[year_name] = convert(char(4),datepart(yyyy,@dt)),
			[quarter_id] = datepart(yyyy,@dt)*10+datepart(qq,@dt),
			[quarter_name] = convert(char(1),datepart(qq,@dt)) + ' квартал',
			[quarter_full_name] = convert(char(4),datepart(yyyy,@dt)) +'/'+convert(char(1),datepart(qq,@dt)) + ' квартал',
			[month_id] = datepart(yyyy,@dt)*100+datepart(mm,@dt),
			[month_name] = case datepart(mm,@dt) 
				when 1  then 'Январь'
				when 2  then 'Февраль'
				when 3  then 'Март'
				when 4  then 'Апрель'
				when 5  then 'Май'
				when 6  then 'Июнь'
				when 7  then 'Июль'
				when 8  then 'Август'
				when 9  then 'Сентябрь'
				when 10 then 'Октябрь'
				when 11 then 'Ноябрь'
				when 12 then 'Декабрь'
			end,
			[month_full_name] = convert(char(4),datepart(yyyy,@dt)) + '/' + case datepart(mm,@dt) 
				when 1  then 'Январь'
				when 2  then 'Февраль'
				when 3  then 'Март'
				when 4  then 'Апрель'
				when 5  then 'Май'
				when 6  then 'Июнь'
				when 7  then 'Июль'
				when 8  then 'Август'
				when 9  then 'Сентябрь'
				when 10 then 'Октябрь'
				when 11 then 'Ноябрь'
				when 12 then 'Декабрь'
			end,
			[month_number] = datepart(mm,@dt),					
			[week_id] = datepart(yyyy,@dt)*100+datepart(wk,@dt),
			[week_name] = left ('00', 2-len(convert(char(4),datepart(wk,@dt)-1)) )+convert(varchar(4),datepart(wk,@dt)-1)+ ' Неделя',
			[week_full_name] = convert(char(4),datepart(yyyy,@dt)) +'/'+left ('00', 2-len(convert(varchar(4),datepart(wk,@dt)-1)) )+ convert(varchar(4),datepart(wk,@dt)-1)+ ' Неделя',
			[weekday_number] = 	case datepart(dw,@dt) 
				when 1  then 1
				when 2  then 2
				when 3  then 3
				when 4  then 4
				when 5  then 5
				when 6  then 6
				when 7  then 7
			end,
			[weekday_name] = case datepart(dw,@dt) 
				when 1  then 'Понедельник'
				when 2  then 'Вторник'
				when 3  then 'Среда'
				when 4  then 'Четверг'
				when 5  then 'Пятница'
				when 6  then 'Суббота'
				when 7  then 'Воскресенье'
			end,
			[week_number] = datepart(wk,@dt)-1,	
			[day_type_id] = case datepart(dw,@dt) 
				when 1  then 1
				when 2  then 1
				when 3  then 1
				when 4  then 1
				when 5  then 1
				when 6  then 2
				when 7  then 2
			END,
			[day_type_name] = case datepart(dw,@dt) 
				when 1  then 'Рабочий'
				when 2  then 'Рабочий'
				when 3  then 'Рабочий'
				when 4  then 'Рабочий'
				when 5  then 'Рабочий'
				when 6  then 'Выходной'
				when 7  then 'Выходной'
			end

		--шаг цикла:
		select @dt = dateadd(day,1,@dt)
	END --Конец цикла
END --Конец процедуры





GO
/****** Object:  StoredProcedure [dbo].[fill_dim_docs]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date: 
-- Description:	Заполнение фиктивного справочника документов
-- =============================================
--exec [dbo].[fill_dim_docs]

CREATE PROCEDURE [dbo].[fill_dim_docs] 
AS
BEGIN
	
	SET NOCOUNT ON;
				
	DECLARE 
		 @name varchar(500) = '['+ OBJECT_SCHEMA_NAME(@@PROCID)+'].['+OBJECT_NAME(@@PROCID)+']'
		,@description varchar(500) = 'справочник документов'
		,@input_parametrs varchar(500) = ''
		,@sql varchar(max)
		,@sql_openquery varchar(max)

	begin try

	--=====================================================================
	--  Запускаем процедуру логирования
	--=====================================================================
	EXEC [oth].[fill_SUP_LOG] @name = @name,	@state_name = 'start', @sp_id = @@SPID, @description = @description, @input_parametrs  = @input_parametrs
	--=====================================================================
	--  Тело процедуры:
	--=====================================================================
		IF OBJECT_ID(N'tempdb..#temp_buf_tbl', N'U') IS NOT NULL 
			DROP TABLE #temp_buf_tbl

		CREATE TABLE #temp_buf_tbl(
			[doc_source_id] [binary](16) NULL,
			[doc_type] [smallint] NULL,
		) ON [PRIMARY]
		

		INSERT INTO #temp_buf_tbl
		SELECT
			 [doc_source_id]
			,[doc_type]
		FROM [stg].[fct_movements]		
		group by [doc_source_id]
			,[doc_type]


		--=====================================================================
		-- MERGE
		--=====================================================================
		MERGE INTO [dbo].[dim_doc] as t1
		USING #temp_buf_tbl as t2
			ON t1.[doc_source_id] = t2.[doc_source_id]
			and t1.[doc_type] = t2.[doc_type]					
		WHEN NOT MATCHED  BY TARGET THEN			 
			INSERT ( 
				 [doc_source_id]
				,[doc_type]				
			) 
			VALUES (
				 ISNULL(t2.[doc_source_id], 0x00)
				,ISNULL(t2.[doc_type], -1)				
			) 
		
		;
			
		--------------------------------------------------------------------------------------------------
		--  Завершаем процедуру логирования:
		--------------------------------------------------------------------------------------------------	
		EXEC [oth].[fill_SUP_LOG]  @name = @name, @state_name = 'finish', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs
		IF OBJECT_ID(N'tempdb..#temp_buf_tbl', N'U') IS NOT NULL 
			DROP TABLE #temp_buf_tbl
	end try      
	begin catch
		EXEC [oth].[fill_SUP_LOG]  @name = @name, @state_name = 'error', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs
		IF OBJECT_ID(N'tempdb..#temp_buf_tbl', N'U') IS NOT NULL 
			DROP TABLE #temp_buf_tbl
		RETURN
	end catch
END




GO
/****** Object:  StoredProcedure [dbo].[fill_dim_item]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date: 
-- Description:	Заполнение фиктивного справочника документов
-- =============================================
--exec [dbo].[fill_dim_item]

CREATE PROCEDURE [dbo].[fill_dim_item] 
AS
BEGIN

	SET NOCOUNT ON;
				
	DECLARE 
		 @name varchar(500) = '['+ OBJECT_SCHEMA_NAME(@@PROCID)+'].['+OBJECT_NAME(@@PROCID)+']'
		,@description varchar(500) = 'справочник номенклатуры'
		,@input_parametrs varchar(500) = ''
		,@sql varchar(max)
		,@sql_openquery varchar(max)

	begin try
	--=====================================================================
	--  Запускаем процедуру логирования
	--=====================================================================
	EXEC [oth].[fill_SUP_LOG] @name = @name,	@state_name = 'start', @sp_id = @@SPID, @description = @description, @input_parametrs  = @input_parametrs
	--=====================================================================
	--  Тело процедуры:
	--=====================================================================
		IF OBJECT_ID(N'tempdb..#temp_buf_tbl', N'U') IS NOT NULL 
			DROP TABLE #temp_buf_tbl

		CREATE TABLE #temp_buf_tbl(
			[item_source_id] binary(16) null,
			[item_name] nvarchar(150) null,
			[item_desc] nvarchar(150) null,
			[country_source_id] binary(16) null,
		) ON [PRIMARY]
		/*
		--РАССКОМЕНТИРОВАТЬ! Указать свои данные. Пример для справочника товаров. Источник 1С.

		INSERT INTO #temp_buf_tbl
		SELECT
			 [item_source_id]
			,[item_name]
			,[item_desc]
			,[country_source_id]

		FROM OPENQUERY([linked_server],
		'
		SELECT
			 _idrref AS "item_source_id"
			,_source_id AS "item_name"
			,CAST(_description as VARCHAR(150)) AS "item_desc"
			,_Fld211RRef AS "country_source_id"

		FROM ave_skd.public._reference2
		'
		)*/
		--=====================================================================
		-- MERGE
		--=====================================================================
		MERGE INTO [dbo].[dim_Item] as t1
		USING 
		(
		SELECT
			 f.[item_source_id] 
			,f.[item_name]
			,f.[item_desc]
			,ISNULL(dim_country.country_id, -1) AS [country_id]

		FROM #temp_buf_tbl as f
		LEFT JOIN [dbo].[dim_Country] with(nolock)
			ON f.country_source_id = dim_Country.country_source_id

		)as t2
			ON t1.[item_source_id] = t2.[item_source_id]					
		WHEN NOT MATCHED  BY TARGET THEN			 
			INSERT ( 
				 [item_source_id]
				,[item_name]
				,[item_desc]
				,[country_id]
			) 
			VALUES (
				 ISNULL(t2.[item_source_id], 0x00)
				,ISNULL(t2.[item_name], -1)
				,ISNULL(t2.[item_desc], 'Н/Д')
				,ISNULL(t2.[country_id], -1)
			) 
		WHEN MATCHED AND 
		(
			   t1.[item_name] != ISNULL(t2.[item_name], 'Н/Д')
			OR t1.[item_desc] != ISNULL(t2.[item_desc], 'Н/Д')
			OR t1.[country_id] != ISNULL(t2.[country_id], -1)
		) 
		THEN
			UPDATE SET
			 t1.[item_name] = ISNULL(t2.[item_name], 'Н/Д')
			,t1.[item_desc] = ISNULL(t2.[item_desc], 'Н/Д')
			,t1.[country_id] = ISNULL(t2.[country_id], -1)
		;
			
		--------------------------------------------------------------------------------------------------
		--  Завершаем процедуру логирования:
		--------------------------------------------------------------------------------------------------	
		EXEC [oth].[fill_SUP_LOG]  @name = @name, @state_name = 'finish', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs
		IF OBJECT_ID(N'tempdb..#temp_buf_tbl', N'U') IS NOT NULL 
			DROP TABLE #temp_buf_tbl
	end try      
	begin catch
		EXEC [oth].[fill_SUP_LOG]  @name = @name, @state_name = 'error', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs
		IF OBJECT_ID(N'tempdb..#temp_buf_tbl', N'U') IS NOT NULL 
			DROP TABLE #temp_buf_tbl
		RETURN
	end catch
END



GO
/****** Object:  StoredProcedure [dbo].[fill_fct_movements]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:
-- Create date: 
-- Description:	Заполнение фактов товародвижений за указанный период
-- =============================================
--exec [dbo].[fill_fct_movements] 20170101, 20170201
CREATE PROCEDURE [dbo].[fill_fct_movements]
	@date_from int,
	@date_to int
AS
BEGIN
	SET NOCOUNT ON;	

	DECLARE 
		 @name varchar(500) = '['+ OBJECT_SCHEMA_NAME(@@PROCID)+'].['+OBJECT_NAME(@@PROCID)+']'
		,@description varchar(500) = 'Заполнение фактов товародвижений за указанный период'
		,@input_parametrs varchar(500) = '@date_from = ' + isnull(cast(@date_from as nvarchar),'') + ', @date_to = ' + isnull(cast(@date_to as nvarchar),'')

	begin try
		--=====================================================================
		--  Запускаем процедуру логирования
		--=====================================================================
		EXEC [oth].[fill_sup_log] @name = @name,	@state_name = 'start', @sp_id = @@SPID, @description = @description, @input_parametrs  = @input_parametrs
		--=====================================================================
		--  Тело процедуры:
		--=====================================================================			
		IF exists (select top 1 * from [stg].[fct_movements] (nolock) where [date] between dbo.int_to_date(@date_from) and dbo.int_to_date(@date_to)) --Обязательная проверка наличия данных в STG слое
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
				/*
				Общий подход:
					_net - сумма без НДС
					_grs - сумма c НДС
					_vat - сумма НДС					

					price_ - цена


				[margin_net] /*маржа без НДС*/
				[margin_grs] /*маржа с НДС*/
				[payment_net] /*оплата без НДС*/
				[payment_grs] /*оплата с НДС*/
				[disc_net] /*скидка без НДС*/
				[disc_grs] /*скидка с НДС*/
				[purch_net] /*закупка без НДС*/
				[purch_grs] /*закупка с НДС*/
				[purch_vat] /*закупка НДС*/

				*/
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
			
		END		
		--=====================================================================
		--  Завершаем процедуру логирования:
		--=====================================================================
		EXEC [oth].[fill_sup_log]  @name = @name, @state_name = 'finish', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs
	end try      
	begin catch
		EXEC [oth].[fill_sup_log]  @name = @name, @state_name = 'error', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs
	end catch		
END 




GO
/****** Object:  StoredProcedure [dbo].[fill_fct_stocks]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:
-- Create date: 
-- Description:	Заполнение фактов товародвижений за указанный период
-- =============================================
--exec [dbo].[fill_fct_stocks] @date_from = 20180101, @date_to = 20180301
CREATE procedure [dbo].[fill_fct_stocks] @date_from int , @date_to int
as
BEGIN


	SET NOCOUNT ON;

	DECLARE @name varchar(max) = '['+ OBJECT_SCHEMA_NAME(@@PROCID)+'].['+OBJECT_NAME(@@PROCID)+']'
	DECLARE @description nvarchar(500) = 'Заполнение расчетных начальных остатков'
	DECLARE @input_parametrs nvarchar(500) = '@date_from = ' + isnull(cast(@date_from as nvarchar),'') + ', @date_to = ' + isnull(cast(@date_to as nvarchar),'')
	
	begin try
	--------------------------------------------------------------------------------------------------
	--  Запускаем процедуру логирования
	--------------------------------------------------------------------------------------------------
		exec [oth].[fill_sup_log] @name = @name,	@state_name = 'start', @sp_id = @@SPID, @description = @description, @input_parametrs  = @input_parametrs
	--------------------------------------------------------------------------------------------------
	
		declare @dtss1 int, @dtes1 int
		declare @dtss int, @dtes int

		------------------------------------------------------------------------------------------------------------------------------------------
		--Определим переменные типа дата для условий цикла чтобы корректно делать шаг в 1 месяц
		------------------------------------------------------------------------------------------------------------------------------------------
		DECLARE @dtstart date, @dtend date, @dtendto date
		select @dtstart = dbo.int_to_date(@date_from) ---начальная дата условия
		select @dtend = dbo.int_to_date(@date_to) ---конечная дата условия
		select @dtendto = dateadd(m,1,@dtstart) --- переменная дата для цикла со смещением в один месяц


		CREATE TABLE #stock_temp(
			[date_id] [int] NULL,
			[item_id] [int] NULL,
			[store_id] [smallint] NULL,
			[qty] [money] NULL,
			[cost_net] [money] NULL,
			[cost_grs] [money] NULL,
			[sale_net] [money] NULL,
			[sale_grs] [money] NULL)



		WHILE @dtstart < @dtend

		BEGIN -- Заполняем помесячно, т.к. используются результаты предидущего месяца
	
			select @dtss = dbo.date_to_int(@dtstart)
			select @dtes = dbo.date_to_int(@dtendto)

			--Заполним параметры со смещением на месяц вперед
			SELECT @dtss1 = dbo.date_to_int(DATEADD(month, 1, @dtstart))
			SELECT @dtes1 = dbo.date_to_int(DATEADD(month, 1, @dtendto))

			---------------------------------------------------------------------
			---Очистим временную таблицу
			---------------------------------------------------------------------
			truncate table  #stock_temp


		
			INSERT INTO #stock_temp ([date_id]
				,[item_id]
				,[store_id]
				,[qty]
				,[cost_net]
				,[cost_grs]
				,[sale_net]
				,[sale_grs]		  
				)
			SELECT 
					@dtss1  as [date_id]-- а теперь перекладываем на начало следующего месяца
				,[item_id]
				,[store_id]			
				,SUM([qty]) as [qty]
				,SUM([cost_net]) as [cost_net]
				,SUM([cost_grs]) as [cost_grs]	
				,SUM([sale_net]) as [sale_net]
				,SUM([sale_grs]) as [sale_grs]	
			FROM
			(
			SELECT [date_id]/100 * 100 + 1  as [date_id]--складываем остаток за текущий месяц на его начало (пример: остаток за 2014-01-01 по 2014-02-01 ложим на 2014-01-01) Это необходимо для корректной связки с таблицей остатков
					,[item_id]
					,[store_id]					  
					,SUM([qty]) as [qty]
					,SUM([cost_net]) as [cost_net]
					,SUM([cost_grs]) as [cost_grs]	
					,SUM([sale_net]) as [sale_net]
					,SUM([sale_grs]) as [sale_grs]
				FROM [dbo].[fct_movements] with (nolock)
				where [date_id] >= @dtss and [date_id] < @dtes
				group by [date_id]/100 * 100 + 1
					,[item_id]
					,[store_id]

			UNION ALL

			SELECT [date_id]-- Остатки хранятся на 01 число каждого месяца за предыдущий				  
					,[item_id]
					,[store_id]
					,[qty]
					,[cost_net]
					,[cost_grs]
					,[sale_net]
					,[sale_grs]
			FROM [dbo].[fct_stocks] with (nolock)
			where [date_id] >= @dtss and [date_id] < @dtes ) as tab				
	
			GROUP BY [item_id]
				,[store_id]	
				HAVING
				abs(SUM([qty])) > 0.0001
				or abs(SUM([cost_net])) > 0.0001
				or abs(SUM([cost_grs])) > 0.0001
				or abs(SUM([sale_net])) > 0.0001
				or abs(SUM([sale_grs])) > 0.0001

			---------------------------------------------------------------------
			---Проверяем наличие данных в темповой таблице.
			---Если они есть - заполняем целевую
			---------------------------------------------------------------------
			if exists (select top 1 * from #stock_temp)
			begin
			---------------------------------------------------------------------
			---Удаляем данные из исторической таблицы
			---------------------------------------------------------------------
				delete top(100000)[dbo].[fct_stocks] where date_id>=@dtss1 and date_id<@dtes1
				while @@rowcount > 0
				begin
					delete top(100000) [dbo].[fct_stocks]
					where  date_id>=@dtss1 and date_id<@dtes1
				end

			---------------------------------------------------------------------
			---Вставляем строки в целевую таблицу
			---------------------------------------------------------------------
	
				INSERT INTO [dbo].[fct_stocks] ([date_id]
					  ,[item_id]
					  ,[store_id]
					  ,[qty]
					  ,[cost_net]
					  ,[cost_grs]
					  ,[sale_net]
					  ,[sale_grs])
	  
				SELECT  [date_id]
					  ,[item_id]
					  ,[store_id]
					  ,[qty]
					  ,[cost_net]
					  ,[cost_grs]
					  ,[sale_net]
					  ,[sale_grs]
				FROM #stock_temp

		
			end
			ELSE
			BEGIN
				print 'Данных в таблицу не было вставлено, т.к. не удалось подрузить данные из источника'
				--return
			END

			SET @dtstart = DATEADD( m , 1 , @dtstart)
			SET @dtendto = DATEADD( m , 1 , @dtstart)

		END
			

		exec [oth].[fill_sup_log]  @name = @name, @state_name = 'finish', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs

		if  Object_ID('tempdb..#stock_temp') is not null drop table #stock_temp

	end try      
	begin catch
		exec [oth].[fill_sup_log]  @name = @name, @state_name = 'error', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs
	end catch 

END


GO
/****** Object:  StoredProcedure [oth].[fill_sup_log]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [oth].[fill_sup_log]
	@name varchar(255) = null,		--obj_name
	@state_name varchar(255) = null,	--start, finish, error
	@row_count int = null,	
	@sp_id int = null,
	@description nvarchar(500) = null,
	@input_parametrs nvarchar(500) = null
as
begin

	
	insert into [oth].[SUP_LOG]
	(
		 [date_time]
		,[name]
		,[system_user]
		,[state_name]
		,[row_count]
		,[err_number]
		,[err_severity]
		,[err_state]
		,[err_object]
		,[err_line]
		,[err_message]
		,[sp_id]
		,[duration]
		,[duration_ord]
		,[description]
        ,[input_parametrs]
	)
	select 
		getdate()
		,@name
		,system_user
		,@state_name
		,case 
			when @state_name = 'finish' and @row_count is null then @@rowcount 
			when @state_name = 'finish' and @row_count is not null then @row_count
			when @state_name = 'error' then -1 
			else null 
		end
		,error_number()
		,error_severity()
		,error_state()
		,error_procedure()
		,error_line()
		,error_message()
		,@sp_id
		,case 
			when @state_name = 'start' then null
			else 				 
				 cast(cast((DATEDIFF(ss,(select max(date_time) 
										from [oth].[SUP_LOG]
										where state_name = 'start' 
											and name = @name 
											and sp_id = @sp_id),getdate()))/3600 as int) as varchar(3)) 
				  +':'+ right('0'+ cast(cast(((DATEDIFF(ss,(select max(date_time) 
															from [oth].[SUP_LOG]
															where state_name = 'start' 
																and name = @name 
																and sp_id = @sp_id),getdate()))%3600)/60 as int) as varchar(2)),2) 
				  +':'+ right('0'+ cast(((DATEDIFF(ss,(select max(date_time) 
														from [oth].[SUP_LOG]
														where state_name = 'start' 
															and name = @name 
															and sp_id = @sp_id),getdate()))%3600)%60 as varchar(2)),2) +' (hh:mm:ss)'
		end
		,case 
			when @state_name = 'start' then null
			else 				 
				 DATEDIFF(ss,(select max(date_time) 
								from [oth].[SUP_LOG]
								where state_name = 'start' 
									and name = @name 
									and sp_id = @sp_id),getdate())
		end
		,@description
		,@input_parametrs

	WAITFOR DELAY '00:00:00.100'
end








GO
/****** Object:  StoredProcedure [oth].[kill_blocked_queries]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [oth].[kill_blocked_queries] 

as

begin

	set nocount on

	declare @spid int,
			@query varchar(max), 
			@loginname varchar(max), 
			@hostname varchar(max), 
			@cmd  varchar(max)

	if  Object_ID('tempdb..#deleted_processes') is not null drop table #deleted_processes
	create table #deleted_processes
	(
		[spid] [int],
		[query] [varchar](max),
		[loginname] [varchar](max),
		[hostname] [varchar](max)
	)


	if  Object_ID('tempdb..#spid_list') is not null drop table #spid_list
	create table #spid_list
	(
		[spid] [int],
		[ecid] [int],
		[status] [varchar](max),
		[loginname] [varchar](max),
		[hostname] [varchar](max),
		[blk] [int],
		[dbname] [varchar](max),
		[cmd] [varchar](max),
		[request_id] [int]
	)

	insert into #spid_list
	exec sp_who

	DECLARE cur CURSOR FOR 
	select distinct [spid],
			
			(SELECT TEXT
			 FROM sys.dm_exec_sql_text
				(cast(
						(
						SELECT top 1 sql_handle  
						FROM sys.sysprocesses
						where spid = sl.[spid]
						) as varbinary)
				)
			) as [query], 
			[loginname], 
			[hostname] 
	from #spid_list as sl
	where loginname <> 'KIFR-RU\svc_DWH' --сервисная учетка		
		and loginname <> ''
		and [spid] <> @@spid --не текущая сессия
		and [spid] >= 50 --только пользовательские запросы

	OPEN cur

	FETCH NEXT FROM cur 
	INTO @spid,@query, @loginname, @hostname

	WHILE @@FETCH_STATUS = 0
	BEGIN

		set @cmd = 'kill ' + convert(varchar(max), @spid)

		exec (@cmd) 

		insert into #deleted_processes
		select @spid,@query, @loginname, @hostname

	FETCH NEXT FROM cur INTO @spid,@query, @loginname, @hostname

	END
	CLOSE cur;
	DEALLOCATE cur;

	if exists (select top 1 * from #deleted_processes)
	begin
		
		insert into [oth].[sup_deleted_query_log] ([date_time]
												,[spid]
												,[query]
												,[loginname]
												,[hostname])
		select
			 getdate() as [date_time]
			,[spid]
			,[query]
			,[loginname]
			,[hostname]
		from #deleted_processes

	end	
	
	if  Object_ID('tempdb..#deleted_processes') is not null drop table #deleted_processes
	if  Object_ID('tempdb..#spid_list') is not null drop table #spid_list

end







GO
/****** Object:  StoredProcedure [oth].[rebuild_indexes]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [oth].[rebuild_indexes]
AS
BEGIN
	DECLARE 
		 @name varchar(max) = '['+ OBJECT_SCHEMA_NAME(@@PROCID)+'].['+OBJECT_NAME(@@PROCID)+']'
		,@description varchar(500) = 'Обновление индексов с фрагментацией > 10%'
		,@input_parametrs varchar(500) = ''	

	begin try
		--------------------------------------------------------------------------------------------------
		--  Запускаем процедуру логирования
		--------------------------------------------------------------------------------------------------
		exec [oth].[fill_sup_log] @name = @name,	@state_name = 'start', @sp_id = @@SPID, @description = @description, @input_parametrs  = @input_parametrs
		--------------------------------------------------------------------------------------------------
		--  Тело процедуры:
		--------------------------------------------------------------------------------------------------
			DECLARE 
				@db_name varchar(50) = N'company_DWH', --тут указать название хранилища!
				@table_name varchar(250) = N'db_name.dbo.tbl_name',
				@cmd varchar(max) ='',
				@count int = 1
			------------------------------------------------------------
			--Получаем список индексов, фрагментированных более 10%
			------------------------------------------------------------
			IF OBJECT_ID(N'tempdb..#index_to_rebuild', N'U') IS NOT NULL 
				DROP TABLE #index_to_rebuild

			SELECT  IndStat.database_id, 
							IndStat.object_id, 
							QUOTENAME(s.name) + '.' + QUOTENAME(o.name) AS [object_name], 
							IndStat.index_id, 
							QUOTENAME(i.name) AS index_name,
							rank() over(order by s.name, o.name, i.name) as rnk
			into #index_to_rebuild
			FROM sys.dm_db_index_physical_stats
				(DB_ID(@db_name), OBJECT_ID(@table_name), NULL, NULL , 'LIMITED') AS IndStat
					INNER JOIN sys.objects AS o ON (IndStat.object_id = o.object_id)
					INNER JOIN sys.schemas AS s ON s.schema_id = o.schema_id
					INNER JOIN sys.indexes i ON (i.object_id = IndStat.object_id AND i.index_id = IndStat.index_id)
			WHERE IndStat.avg_fragmentation_in_percent > 10 AND IndStat.index_id > 0

			------------------------------------------------------------
			--В цикле делаем для каждого из индексов Rebuild
			------------------------------------------------------------
			while @count <= (select max(rnk) from #index_to_rebuild)
			begin
				set @cmd = 
						'
						ALTER INDEX '+(select [index_name] from #index_to_rebuild where rnk = @count)+' ON '+(select [object_name] from #index_to_rebuild where rnk = @count)+' 
						REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
						'
				exec (@cmd)
				set @count = @count + 1
			end

			------------------------------------------------------------
			--Очищаем временные таблицы
			------------------------------------------------------------
			IF OBJECT_ID(N'tempdb..#index_to_rebuild', N'U') IS NOT NULL 
				DROP TABLE #index_to_rebuild
		--------------------------------------------------------------------------------------------------
		--  Завершаем процедуру логирования:
		--------------------------------------------------------------------------------------------------
		exec [oth].[fill_sup_log] @name = @name, @state_name = 'finish', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs
	end try      
	begin catch
		exec [oth].[fill_sup_log] @name = @name, @state_name = 'error', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs

		IF OBJECT_ID(N'tempdb..#index_to_rebuild', N'U') IS NOT NULL 
			DROP TABLE #index_to_rebuild
	end catch 
end





GO
/****** Object:  StoredProcedure [stg].[fill_fct_movements]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date: 
-- Description:	Заполнение фактов товародвижений за указанный период
-- =============================================
--exec [stg].[fill_fct_movements] '2017-01-01', '2017-02-01'
CREATE PROCEDURE [stg].[fill_fct_movements]
	@date_from date,
	@date_to date
AS
BEGIN
	SET NOCOUNT ON;
	TRUNCATE TABLE [stg].[fct_movements]

	DECLARE 
		 @name varchar(500) = '['+ OBJECT_SCHEMA_NAME(@@PROCID)+'].['+OBJECT_NAME(@@PROCID)+']'
		,@description varchar(500) = 'Заполнение фактов товародвижений за указанный период'
		,@input_parametrs varchar(500) = '@date_from = ''' + isnull(cast(@date_from as nvarchar),'') + ''', @date_to = ''' + isnull(cast(@date_to as nvarchar),'') + ''''
		
		,@sql varchar(max) = ''
		,@sql_openquery varchar(max) = ''

	begin try
		--=====================================================================
		--  Запускаем процедуру логирования
		--=====================================================================
		EXEC [oth].[fill_sup_log] @name = @name,	@state_name = 'start', @sp_id = @@SPID, @description = @description, @input_parametrs  = @input_parametrs
		
		
		--=====================================================================
		--  Тело процедуры: Тут закладываем всю логику сбора данных
		--=====================================================================			
		begin
			/*ВАРИАНТ №1 с применением openquery*/
			truncate table [stg].[fct_movements]		
		
			set @sql =	@sql +	
			'
			select 	 col1 as [date]
					,col2 as [item_source_id]
					,col3 as [store_source_id]
					,col4 as [doc_source_id]
					,col5 as [doc_type]
					,col6 as [qty]
					,col7 as [cost_net]
					,col8 as [cost_grs]
					,col9 as [sale_net]
					,col10 as [sale_grs]
			from dbo.source_table st (nolock)			
			where st.col1 >= ''' + cast(@date_from as varchar) + ''' 
				and st.col1 < ''' + cast(@date_to as varchar) + ''' '

			set @sql_openquery = @sql_openquery +
			'select *
			from openquery([linked_server], ''' + REPLACE(@sql, '''', '''''') + ''')'
		
			--select @sql_openquery
		
			insert into [stg].[fct_movements] ( [date]
										  ,[item_source_id]
										  ,[store_source_id]
										  ,[doc_source_id]
										  ,[doc_type]
										  ,[qty]
										  ,[cost_net]
										  ,[cost_grs]
										  ,[sale_net]
										  ,[sale_grs])		
			exec (@sql_openquery)
		end 
		/*ВАРИАНТ №2 с применением exec и распределенными транзакциями
		  применимо для сложных расчетов с исользованием временных таблиц на стороне источнике
		  инструкция по настройке DTC на сервере источнике   https://technet.microsoft.com/en-us/library/cc753510(WS.10).aspx
		*/
		begin	
			truncate table [stg].[fct_movements]	
			
			set @sql = 	@sql + 
			'
			select 	 col1 as [date]
					,col2 as [item_source_id]
					,col3 as [store_source_id]
					,col4 as [doc_source_id]
					,col5 as [doc_type]
					,col6 as [qty]
					,col7 as [cost_net]
					,col8 as [cost_grs]
					,col9 as [sale_net]
					,col10 as [sale_grs]
			into #temp_tab
			from dbo.source_table st (nolock)			
			where st.col1 >= ''' + cast(@date_from as varchar) + ''' 
				and st.col1 < ''' + cast(@date_to as varchar) + ''' 
			
			select [date]
				,[item_source_id]
				,[store_source_id]
				,[doc_source_id]
				,[doc_type]
				,[qty]
				,[cost_net]
				,[cost_grs]
				,[sale_net]
				,[sale_grs]
			from #temp_tab

			drop table #temp_tab
			'
		
			insert into [stg].[fct_movements] ( [date]
										  ,[item_source_id]
										  ,[store_source_id]
										  ,[doc_source_id]
										  ,[doc_type]
										  ,[qty]
										  ,[cost_net]
										  ,[cost_grs]
										  ,[sale_net]
										  ,[sale_grs])
			exec(@sql) at [linked_server]			

		end

		--=====================================================================
		--  Завершаем процедуру логирования:
		--=====================================================================
		EXEC [oth].[fill_sup_log]  @name = @name, @state_name = 'finish', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs
	end try      
	begin catch
		EXEC [oth].[fill_sup_log]  @name = @name, @state_name = 'error', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs
	end catch		 	
		
END -- Конец процедуры







GO
/****** Object:  DdlTrigger [backup_objects]    Script Date: 05.03.2020 11:51:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [backup_objects]
ON DATABASE
FOR CREATE_PROCEDURE, 
    ALTER_PROCEDURE, 
    DROP_PROCEDURE,
    CREATE_TABLE, 
    ALTER_TABLE, 
    DROP_TABLE,
    CREATE_FUNCTION, 
    ALTER_FUNCTION, 
    DROP_FUNCTION,
    CREATE_VIEW,
    ALTER_VIEW,
    DROP_VIEW
AS
 
SET NOCOUNT ON
 
DECLARE @data XML
SET @data = EVENTDATA()
 
INSERT INTO [RetailAnalytics].[oth].[sup_change_objects_log]([database_name]
      ,[event_type]
      ,[object_name]
      ,[object_type]
      ,[sql_command]      
      ,[login_name])
VALUES(
@data.value('(/EVENT_INSTANCE/DatabaseName)[1]', 'varchar(256)'),
@data.value('(/EVENT_INSTANCE/EventType)[1]', 'varchar(50)'), 
'['+@data.value('(/EVENT_INSTANCE/SchemaName)[1]', 'varchar(256)') + '].[' +  @data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'varchar(256)') + ']', 
@data.value('(/EVENT_INSTANCE/ObjectType)[1]', 'varchar(25)'), 
@data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'varchar(max)'), 
@data.value('(/EVENT_INSTANCE/LoginName)[1]', 'varchar(256)')
)
GO
ENABLE TRIGGER [backup_objects] ON DATABASE
GO
USE [master]
GO
ALTER DATABASE [RetailAnalytics] SET  READ_WRITE 
GO
