USE [BaseOne]
GO
/****** Object:  StoredProcedure [dbo].[Insert_Update_Suppliers]    Script Date: 15.10.2020 4:41:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE TYPE Ins_Del AS TABLE
    ( ins_id int, del_id int)
	go

ALTER PROCEDURE [dbo].[Insert_Update_Suppliers]
( @file_path varchar(max) )
AS
BEGIN
    BEGIN TRANSACTION
    BEGIN TRY

	declare @xml xml
	declare @xmlload nvarchar(300)
	declare @editXml varchar(max)
    SET @xmlload= N'select @editXml = (SELECT P FROM OPENROWSET (BULK N' + '''' + @file_path + '''' + ',' + ' SINGLE_BLOB, CODEPAGE=' + '''' + '1251' + '''' + ') AS Product(P));'
    exec sp_executesql @xmlload, N'@editXml varchar(max) output', @editXml=@editXml output

	SET @editXml = REPLACE (@editXml, 'UTF-8', 'windows-1251')
    SET @xml = @editXml


    --    DECLARE @doc nvarchar(1000);
    --DECLARE @xmlDoc integer;
    
	DECLARE @hdoc int

    EXEC sp_xml_preparedocument @hdoc OUTPUT, @xml
	--EXEC sp_XML_preparedocument @xmlDoc OUTPUT, @doc;
    
	--CREATE TYPE Ins_Del AS TABLE
 --   ( ins_id int, del_id int)

	DECLARE @table Ins_Del

	MERGE INTO suppliers as g
        USING 
        (
		    SELECT * FROM OPENXML (@hdoc, '/root/suppliers/supplier', 2)
            WITH (
					 [id] int,
				  [name] varchar(MAX),
				  [legal_name] varchar(MAX),
				  [inn] varchar(MAX),
				  [kpp] varchar(MAX),
				  [address] varchar(MAX),
				  [phone] varchar(MAX),
				  [email] varchar(MAX),
				  [www] varchar(MAX),
				  [created_date] smalldatetime,
				  [created_by] int,
				  [last_update_date] smalldatetime,
				  [last_update_by] int,
				  [attribute1] varchar(MAX),
				  [attribute2] varchar(MAX),
				  [attribute3] varchar(MAX),
				  [attribute4] varchar(MAX),
				  [attribute5] varchar(MAX),
				  [attribute6] varchar(MAX),
				  [attribute7] varchar(MAX),
				  [attribute8] varchar(MAX),
				  [attribute9] varchar(MAX),
				  [attribute10] varchar(MAX),
				  [attribute11] varchar(MAX),
				  [attribute12] int,
				  [attribute13] varchar(MAX),
				  [attribute14] varchar(MAX),
				  [attribute15] varchar(MAX),
				  [type_id] int,
				  [code] int,
				  [OKPO] int,
				  [OKONH] varchar(MAX),
				  [corraccount] varchar(MAX),
				  [bankaccount] varchar(MAX),
				  [BIK] varchar(MAX),
				  [bank_name] varchar(MAX),
				  [status] varchar(MAX),
				  [delivaddress] varchar(MAX),
				  [external_id] varchar(MAX), --int, но стоит как char тк в goods стоит _ вместо цифры
				  [price_coef] varchar(MAX),
				  [pricelist_life_length] int,
				  [type_name] varchar(MAX)
			      )
        ) as temp ([id], [name], [legal_name], [inn], [kpp], [address], [phone], [email], [www], [created_date], [created_by], [last_update_date],
                   [last_update_by], [attribute1], [attribute2], [attribute3], [attribute4], [attribute5], [attribute6], [attribute7],
                   [attribute8], [attribute9], [attribute10], [attribute11], [attribute12], [attribute13], [attribute14], [attribute15],
                   [type_id], [code], [OKPO], [OKONH], [corraccount], [bankaccount], [BIK], [bank_name], [status], [delivaddress], [external_id],
                   [price_coef], [pricelist_life_length], [type_name])
        ON (g.id = temp.id)
        WHEN MATCHED THEN UPDATE SET g.[name] = temp.[name],
		                             g.[legal_name] = temp.[legal_name], 
									 g.[inn] = temp.[inn], 
									 g.[kpp] = temp.[kpp], 
									 g.[address] = temp.[address], 
									 g.[phone] = temp.phone, 
									 g.[email] = temp.[email], 
									 g.[www] = temp.[www], 
									 g.[created_date] = temp.[created_date], 
									 g.[created_by] = temp.[created_by], 
									 g.[last_update_date] = temp.[last_update_date],
                                     g.[last_update_by] = temp.[last_update_by], 
									 g.[attribute1] = temp.[attribute1], 
									 g.[attribute2] = temp.[attribute2], 
									 g.[attribute3] = temp.[attribute3], 
									 g.[attribute4] = temp.[attribute4], 
									 g.[attribute5] = temp.[attribute5], 
									 g.[attribute6] = temp.[attribute6], 
									 g.[attribute7] = temp.[attribute7],
                                     g.[attribute8] = temp.[attribute8], 
									 g.[attribute9] = temp.[attribute9], 
									 g.[attribute10] = temp.[attribute10], 
									 g.[attribute11] = temp.[attribute11], 
									 g.[attribute12] = temp.[attribute12], 
									 g.[attribute13] = temp.[attribute13], 
									 g.[attribute14] = temp.[attribute14], 
									 g.[attribute15] = temp.[attribute15],
                                     g.[type_id] = temp.[type_id], 
									 g.[code] = temp.[code], 
									 g.[OKPO] = temp.[OKPO], 
									 g.[OKONH] = temp.[OKONH], 
									 g.[corraccount] = temp.[corraccount], 
									 g.[bankaccount] = temp.[bankaccount], 
									 g.[BIK] = temp.[BIK], 
									 g.[bank_name] = temp.[bank_name], 
									 g.[status] = temp.[status], 
									 g.[delivaddress] = temp.[delivaddress], 
									 g.[external_id] = temp.[external_id],
                                     g.[price_coef] = temp.[price_coef], 
									 g.[pricelist_life_length] = temp.[pricelist_life_length], 
									 g.[type_name] = temp.[type_name]
        WHEN NOT MATCHED THEN INSERT ([id], [name], [legal_name], [inn], [kpp], [address], [phone], [email], [www], [created_date], [created_by], [last_update_date],
                   [last_update_by], [attribute1], [attribute2], [attribute3], [attribute4], [attribute5], [attribute6], [attribute7],
                   [attribute8], [attribute9], [attribute10], [attribute11], [attribute12], [attribute13], [attribute14], [attribute15],
                   [type_id], [code], [OKPO], [OKONH], [corraccount], [bankaccount], [BIK], [bank_name], [status], [delivaddress], [external_id],
                   [price_coef], [pricelist_life_length], [type_name])
        VALUES (temp.[id], temp.[name], temp.[legal_name], temp.[inn], temp.[kpp], temp.[address], temp.[phone], temp.[email], temp.[www], temp.[created_date], temp.[created_by], temp.[last_update_date],
                temp.[last_update_by], temp.[attribute1], temp.[attribute2], temp.[attribute3], temp.[attribute4], temp.[attribute5], temp.[attribute6], temp.[attribute7],
                temp.[attribute8], temp.[attribute9], temp.[attribute10], temp.[attribute11], temp.[attribute12], temp.[attribute13], temp.[attribute14], temp.[attribute15],
                temp.[type_id], temp.[code], temp.[OKPO], temp.[OKONH], temp.[corraccount], temp.[bankaccount], temp.[BIK], temp.[bank_name], temp.[status], temp.[delivaddress], temp.[external_id],
                temp.[price_coef], temp.[pricelist_life_length], temp.[type_name])
				OUTPUT Inserted.id, Deleted.id INTO @table;
     
	EXEC sp_xml_removedocument @hdoc
	exec BaseOne.Log_ProcedureCall @ObjectID = @@PROCID,  @RowCount = @@ROWCOUNT, @table1 = @table;
    COMMIT
END TRY
BEGIN CATCH
 
--SELECT  
        /*ERROR_NUMBER() AS ErrorNumber,
		ERROR_SEVERITY() AS ErrorSeverity,
		ERROR_STATE() AS ErrorState,
		ERROR_PROCEDURE() AS ErrorProcedure,
		ERROR_MESSAGE() AS ErrorMessage;  */
    
	 --RETURN
	 ROLLBACK
	 exec BaseOne.Log_ProcedureCall @ObjectID = @@PROCID,  @RowCount = @@ROWCOUNT,  @table1 = @table;
END CATCH
END
