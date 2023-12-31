USE [BaseOne]
GO
/****** Object:  StoredProcedure [dbo].[Insert_Update_f_receipt]    Script Date: 16.10.2020 3:36:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	--CREATE TYPE Ins_Del1 AS TABLE
 --   ( ins_id nvarchar(255), del_id nvarchar(255))
	--go

ALTER PROCEDURE [dbo].[Insert_Update_f_receipt]
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



	DECLARE @hdoc int

    EXEC sp_xml_preparedocument @hdoc OUTPUT, @xml
	
    DECLARE @table Ins_Del

	--;WITH XMLNAMESPACES(DEFAULT 'urn:schemas-microsoft-com:sql:SqlRowSet1')
	--INSERT INTO [f_receipt] ([receipt_id],[terminalid],[warehouseid],[doc_type],[date],[items_count])
	--SELECT OgrRol.value('(receipt_id/text())[1]','nvarchar(255)') AS receipt_id,
	--       OgrRol.value('(terminalid/text())[1]','bigint') AS [terminalid],
	--	   OgrRol.value('(warehouseid/text())[1]','int') AS [warehouseid],
	--	   OgrRol.value('(doc_type/text())[1]','nvarchar(255)') AS [doc_type],
	--	   OgrRol.value('(date/text())[1]','smalldatetime') AS [date],
	--	   OgrRol.value('(items_count/text())[1]','int') AS [items_count]
 --   FROM @xml.nodes('/*:root/receipts/receipt') A(ogrRol);


	
	
	--Insert into [f_receipt] ([receipt_id],[terminalid], [warehouseid], [doc_type], [date], [items_count]) 
	--Select receipt_id, terminalid, warehouseid, doc_type, convert( smalldatetime, [date], 105) as [date], items_count
	--from OpenXml(@hdoc, 'root/receipts/receipt', 2)
 --   With (
	--		receipt_id nvarchar(255) 'receipt_id',
	--		terminalid bigint 'terminalid',
	--		warehouseid bigint 'terminalid',
	--		doc_type nvarchar(255) 'doc_type',
	--		[date] nvarchar(255) 'date',
	--		items_count bigint 'items_count'
	--      )

 --    INSERT INTO [f_receipt_lines] ([line_id], [receipt_id], [itemid], [quantity], 
	--			  [pricebase], [pricesale], [discount], [amount], [cogs]) 
	-- SELECT * FROM OPENXML (@hdoc, '/root/receipts/receipt/items/item', 2)
 --           WITH (
	--		      [line_id] nvarchar(255) 'line_id',
	--			  [receipt_id] nvarchar(255) '../../receipt_id',
	--			  [itemid] bigint 'itemid',
	--			  --[discount_name] nvarchar(max) 'discount_name',
	--			  [quantity] nvarchar(max) 'quantity', 
	--			  [pricebase] nvarchar(max) 'pricebase', 
	--			  [pricesale] nvarchar(max) 'pricesale',
	--			  [discount] nvarchar(max) 'discount',
	--			  [amount] nvarchar(max) 'amount',
	--			  [cogs] nvarchar(max) 'cogs'
	--		      )

--		  INSERT INTO tab_teacher
--   SET name_teacher = 'Dr. Smith';
--INSERT INTO tab_student 
--   SET name_student = 'Bobby Tables',
--       id_teacher_fk = LAST_INSERT_ID()

	MERGE INTO [f_receipt] as g
        USING 
        (
		    	Select receipt_id, terminalid, warehouseid, doc_type, convert( smalldatetime, [date], 105), items_count
	            from OpenXml(@hdoc, 'root/receipts/receipt', 2)
                With (
						receipt_id nvarchar(255) 'receipt_id',
						terminalid bigint 'terminalid',
						warehouseid bigint 'terminalid',
						doc_type nvarchar(255) 'doc_type',
						[date] nvarchar(255) 'date',
						items_count bigint 'items_count'
	                 )
        ) as temp ([receipt_id], [terminalid], [warehouseid], [doc_type], [date],  [items_count])
        ON (g.[receipt_id] = temp.[receipt_id])
        WHEN MATCHED THEN UPDATE SET g.[receipt_id] = temp.[receipt_id],
									 g.[terminalid] = temp.[terminalid],
									 g.[warehouseid] = temp.[warehouseid],
									 g.[doc_type] = temp.[doc_type],
									 g.[date] = temp.[date], 
									 g.[items_count] = temp.[items_count]
        WHEN NOT MATCHED THEN INSERT ([receipt_id], [terminalid], [warehouseid], [doc_type], [date],  [items_count])
        VALUES (temp.[receipt_id], temp.[terminalid], temp.[warehouseid], temp.[doc_type], temp.[date], temp.[items_count]);
		--OUTPUT Inserted.[receipt_id], Deleted.[receipt_id] INTO @table;

		exec BaseOne.Log_ProcedureCall @ObjectID = @@PROCID,  @RowCount = @@ROWCOUNT, @table1 = @table;

		--truncate table @table

		MERGE INTO [f_receipt_lines] as g
        USING 
        (
		    SELECT [line_id], [receipt_id], [itemid], /*[discount_name],*/ [quantity], [pricebase], [pricesale], [discount], [amount], [cogs] 
			FROM OPENXML (@hdoc, '/root/receipts/receipt/items/item', 2)
            WITH (
			      [line_id] nvarchar(255) 'line_id',
				  [receipt_id] nvarchar(255) '../../receipt_id',
				  [itemid] bigint 'itemid',
				  --[discount_name] nvarchar(max) 'discount_name',
				  [quantity] nvarchar(max) 'quantity', 
				  [pricebase] nvarchar(max) 'pricebase', 
				  [pricesale] nvarchar(max) 'pricesale',
				  [discount] nvarchar(max) 'discount',
				  [amount] nvarchar(max) 'amount',
				  [cogs] nvarchar(max) 'cogs'
			      )
        ) as temp ([line_id], [receipt_id], [itemid], /*[discount_name],*/ [quantity], [pricebase], [pricesale], [discount], [amount], [cogs])
        ON (g.[line_id] = temp.[line_id])
        WHEN MATCHED THEN UPDATE SET g.[line_id] = temp.[line_id],
		                             g.[receipt_id] = temp.[receipt_id], 
									 g.[itemid] = temp.[itemid], 
									 --g.[discount_name] = temp.[discount_name], 
									 g.[quantity] = temp.[quantity], 
									 g.[pricebase] = temp.[pricebase], 
									 g.[pricesale] = temp.[pricesale], 
									 g.[discount] = temp.[discount], 
									 g.[amount] = temp.[amount], 
									 g.[cogs] = temp.[cogs]
        WHEN NOT MATCHED THEN INSERT ([line_id], [receipt_id], [itemid], /*[discount_name],*/ [quantity], [pricebase], [pricesale], [discount], [amount], [cogs])
        VALUES (temp.[line_id], temp.[receipt_id], temp.[itemid], /*temp.[discount_name],*/ temp.[quantity], temp.[pricebase], temp.[pricesale], temp.[discount], temp.[amount], temp.[cogs]);
		--OUTPUT Inserted.[line_id], Deleted.[line_id] INTO @table;
    
	EXEC sp_xml_removedocument @hdoc
	exec BaseOne.Log_ProcedureCall @ObjectID = @@PROCID,  @RowCount = @@ROWCOUNT, @table1 = @table;

    COMMIT
END TRY
BEGIN CATCH

    ROLLBACK
	exec BaseOne.Log_ProcedureCall @ObjectID = @@PROCID,  @RowCount = @@ROWCOUNT, @table1 = @table;
END CATCH
END
