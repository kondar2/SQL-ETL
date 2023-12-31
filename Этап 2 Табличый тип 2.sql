USE [BaseOne]
GO
/****** Object:  StoredProcedure [BaseOne].[Log_ProcedureCall]    Script Date: 15.10.2020 4:41:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [BaseOne].[Log_ProcedureCall]
 @ObjectID       INT,
 @DatabaseID     INT = NULL,
 @AdditionalInfo NVARCHAR(MAX) = NULL,
 @RowCount INT,
 @table1 Ins_Del READONLY

AS
BEGIN
 SET NOCOUNT ON;
 
 DECLARE @operation CHAR(6)
		

		SET @operation = CASE
				WHEN EXISTS(SELECT ins_id FROM @table1) AND EXISTS(SELECT del_id FROM @table1)
					THEN 'Update'
				WHEN EXISTS(SELECT ins_id FROM @table1)
					THEN 'Insert'
				WHEN EXISTS(SELECT del_id FROM @table1)
					THEN 'Delete'
				ELSE NULL
		END

 DECLARE 
  @ProcedureName NVARCHAR(400),
  @Table_name nvarchar(100)
  
 SELECT
  @DatabaseID = COALESCE(@DatabaseID, DB_ID()), --если null вернет null
  @ProcedureName = COALESCE
  (
   QUOTENAME(DB_NAME(@DatabaseID)) + '.'
   + QUOTENAME(OBJECT_SCHEMA_NAME(@ObjectID, @DatabaseID)) 
   + '.' + QUOTENAME(OBJECT_NAME(@ObjectID, @DatabaseID)),
   ERROR_PROCEDURE()
  );


SET @Table_name = (select top 1 tab.name
FROM sys.sql_modules   m 
INNER JOIN sys.sql_dependencies dep ON m.object_id = dep.object_id
INNER JOIN sys.columns col ON dep.referenced_major_id = col.object_id
INNER JOIN sys.tables tab ON tab.object_id = col.object_id
WHERE m.[object_id] = @ObjectID)


 -- SELECT * FROM inserted

  --DECLARE @data XML,
  --      @EventType nvarchar(100);
  --SET @data = EVENTDATA();
  --SET @EventType = @data.value('(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(100)');
 
 INSERT BaseOne.dbo.ProcedureLog
 (
  DatabaseID,
  ObjectID,
  ProcedureName,
  ErrorLine,
  ErrorMessage,
  AdditionalInfo,
  Row_count,
  [User],
  [EventType],
  [Tabel_name]
 
 )
 SELECT
  @DatabaseID,
  @ObjectID,
  @ProcedureName,
  ERROR_LINE(),
  ERROR_MESSAGE(),
  @AdditionalInfo,
  @RowCount,
  Suser_name(),
  @operation,
  @Table_name;

END

