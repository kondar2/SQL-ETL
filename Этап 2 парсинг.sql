
/*
begin
END TRY
BEGIN CATCH 
   PRINT 'This is the error: ' + error_message()
END CATCH */

/*

CREATE TABLE goods (
		id int,
		external_id varchar(MAX), --delete
		name varchar(MAX),
		volume varchar(MAX), --delete
		description varchar(MAX),
		article varchar(MAX),
		enabled int,
		sales_weight int, --delete
		manufacturer_id int,
		type varchar(20),
		weight_good_flag varchar(20),
		not_show_in_shop int,
		html_template_id varchar(MAX), --delete
		group_ids varchar(MAX),
		group_ext_ids varchar(MAX), --delete
		barcodes varchar(MAX),
		vat_percent int, --
		created_date smalldatetime,
		last_update_date smalldatetime,
		attribute1 varchar(20),
		attribute2 varchar(20),
		attribute3 varchar(20),
		attribute4 varchar(MAX),
		attribute5 varchar(MAX),
		attribute6 varchar(MAX),
		attribute7 varchar(MAX),
		attribute8 varchar(MAX),
		attribute9 varchar(MAX), --план в шт
		attribute10 varchar(MAX),
		attribute11 varchar(MAX),
		attribute12 int, --план в руб
		attribute13 varchar(MAX), 
		attribute14 varchar(MAX), --екод
		attribute15 varchar(MAX)
		);
go

CREATE PROCEDURE Insert_Update_Goods
( @file_path varchar(max) )
AS
BEGIN
    BEGIN TRANSACTION
    BEGIN TRY

	declare @xml xml
	declare @xmlload nvarchar(300)
    SET @xmlload= N'select @xml = (SELECT P FROM OPENROWSET (BULK N' + '''' + @file_path + '''' + ',' + ' SINGLE_BLOB, CODEPAGE=' + '''' + '1251' + '''' + ') AS Product(P));'
    exec sp_executesql @xmlload, N'@xml xml output', @xml=@xml output


    --    DECLARE @doc nvarchar(1000);
    --DECLARE @xmlDoc integer;
    
	DECLARE @hdoc int

    EXEC sp_xml_preparedocument @hdoc OUTPUT, @xml
	--EXEC sp_XML_preparedocument @xmlDoc OUTPUT, @doc;
    
	MERGE INTO goods as g
        USING 
        (
		    SELECT * FROM OPENXML (@hdoc, '/root/items/item', 2)
            WITH (
					id int,
					external_id varchar(MAX), --delete
					name varchar(MAX),
					volume varchar(MAX), --delete
					description varchar(MAX),
					article varchar(MAX),
					enabled int,
					sales_weight int, --delete
					manufacturer_id int,
					type varchar(20),
					weight_good_flag varchar(20),
					not_show_in_shop int,
					html_template_id varchar(MAX), --delete
					group_ids varchar(MAX),
					group_ext_ids varchar(MAX), --delete
					barcodes varchar(MAX),
					vat_percent int, --
					created_date smalldatetime,
					last_update_date smalldatetime,
					attribute1 varchar(20),
					attribute2 varchar(20),
					attribute3 varchar(20),
					attribute4 varchar(MAX),
					attribute5 varchar(MAX),
					attribute6 varchar(MAX),
					attribute7 varchar(MAX),
					attribute8 varchar(MAX),
					attribute9 varchar(MAX), --план в шт
					attribute10 varchar(MAX),
					attribute11 varchar(MAX),
					attribute12 int, --план в руб
					attribute13 varchar(MAX), 
					attribute14 varchar(MAX), --екод
					attribute15 varchar(MAX)
			      )

            /*SELECT * FROM OPENXML (@xmlDoc, 'Regions/Region', 0) 
            WITH 
            (
                RegionID int,
                RegionDescription nchar(50)
            )*/
        ) as temp (id, external_id, name, volume, description, article, enabled, sales_weight, manufacturer_id, type, weight_good_flag,
		not_show_in_shop, html_template_id, group_ids, group_ext_ids, barcodes, vat_percent, created_date, last_update_date, attribute1,
		attribute2, attribute3, attribute4, attribute5, attribute6, attribute7, attribute8, attribute9, attribute10, attribute11,
		attribute12, attribute13, attribute14, attribute15)
        ON (g.id = temp.id)
        --WHEN MATCHED THEN UPDATE SET r.RegionDescription = temp.RegionDescription   
        WHEN NOT MATCHED THEN INSERT (id, external_id, name, volume, description, article, enabled, sales_weight, manufacturer_id, type, weight_good_flag,
		not_show_in_shop, html_template_id, group_ids, group_ext_ids, barcodes, vat_percent, created_date, last_update_date, attribute1,
		attribute2, attribute3, attribute4, attribute5, attribute6, attribute7, attribute8, attribute9, attribute10, attribute11,
		attribute12, attribute13, attribute14, attribute15)
        VALUES (temp.id, temp.external_id, temp.name, temp.volume, temp.description, temp.article, temp.enabled, temp.sales_weight, temp.manufacturer_id, temp.type, temp.weight_good_flag,
		temp.not_show_in_shop, temp.html_template_id, temp.group_ids, temp.group_ext_ids, temp.barcodes, temp.vat_percent, temp.created_date, temp.last_update_date, temp.attribute1,
		temp.attribute2, temp.attribute3, temp.attribute4, temp.attribute5, temp.attribute6, temp.attribute7, temp.attribute8, temp.attribute9, temp.attribute10, temp.attribute11,
		temp.attribute12, temp.attribute13, temp.attribute14, temp.attribute15);
    
	EXEC sp_xml_removedocument @hdoc

    COMMIT
END TRY
BEGIN CATCH
SELECT  
        ERROR_NUMBER() AS ErrorNumber  
        ,ERROR_SEVERITY() AS ErrorSeverity  
        ,ERROR_STATE() AS ErrorState  
        ,ERROR_PROCEDURE() AS ErrorProcedure  
        ,ERROR_MESSAGE() AS ErrorMessage;  
    ROLLBACK
END CATCH
END

*/
--exec Insert_Update_Region 'C:\Users\konda\Desktop\ЭТАП 2 Lasmart\virtualpos\goods.xml'

/*
CREATE TABLE good_groups (
		[id] int,
		[external_id] varchar(MAX),
        [name] varchar(MAX),
        [parent_id] int,
        [parent_ext_id] varchar(MAX),
        [not_show_in_shop] int,
        [index_tree] varchar(MAX),
        [created_date] smalldatetime,
        [last_update_date] smalldatetime 
		);
go


CREATE PROCEDURE Insert_Update_Good_Groups
( @file_path varchar(max) )
AS
BEGIN
    BEGIN TRANSACTION
    BEGIN TRY

	declare @xml xml
	declare @xmlload nvarchar(300)
    SET @xmlload= N'select @xml = (SELECT P FROM OPENROWSET (BULK N' + '''' + @file_path + '''' + ',' + ' SINGLE_BLOB, CODEPAGE=' + '''' + '1251' + '''' + ') AS Product(P));'
    exec sp_executesql @xmlload, N'@xml xml output', @xml=@xml output


    --    DECLARE @doc nvarchar(1000);
    --DECLARE @xmlDoc integer;
    
	DECLARE @hdoc int

    EXEC sp_xml_preparedocument @hdoc OUTPUT, @xml
	--EXEC sp_XML_preparedocument @xmlDoc OUTPUT, @doc;
    
	MERGE INTO good_groups as g
        USING 
        (
		    SELECT * FROM OPENXML (@hdoc, '/root/item_groups/item_group', 2)
            WITH (
					[id] int,
					[external_id] varchar(MAX),
					[name] varchar(MAX),
					[parent_id] int,
					[parent_ext_id] varchar(MAX),
					[not_show_in_shop] int,
					[index_tree] varchar(MAX),
					[created_date] smalldatetime,
					[last_update_date] smalldatetime 
			      )
        ) as temp ([id], [external_id], [name], [parent_id], [parent_ext_id], [not_show_in_shop], [index_tree],
		           [created_date], [last_update_date])
        ON (g.id = temp.id)
        --WHEN MATCHED THEN UPDATE SET r.RegionDescription = temp.RegionDescription   
        WHEN NOT MATCHED THEN INSERT ([id], [external_id], [name], [parent_id], [parent_ext_id], [not_show_in_shop], [index_tree],
					                  [created_date], [last_update_date])
        VALUES (temp.[id], temp.[external_id], temp.[name], temp.[parent_id], temp.[parent_ext_id], 
		temp.[not_show_in_shop], temp.[index_tree], temp.[created_date], temp.[last_update_date]);
    
	EXEC sp_xml_removedocument @hdoc

    COMMIT
END TRY
BEGIN CATCH
SELECT  
        ERROR_NUMBER() AS ErrorNumber  
        ,ERROR_SEVERITY() AS ErrorSeverity  
        ,ERROR_STATE() AS ErrorState  
        ,ERROR_PROCEDURE() AS ErrorProcedure  
        ,ERROR_MESSAGE() AS ErrorMessage;  
    ROLLBACK
END CATCH
END
*/
--exec Insert_Update_Good_Groups 'C:\Users\konda\Desktop\ЭТАП 2 Lasmart\virtualpos\goodgroups.xml'

/*
CREATE TABLE manufactures (
		[id] int,
		[name] varchar(MAX),
		[created_date] smalldatetime,
		[last_update_date] smalldatetime 
		);
go

CREATE PROCEDURE Insert_Update_Manufactures
( @file_path varchar(max) )
AS
BEGIN
    BEGIN TRANSACTION
    BEGIN TRY

	declare @xml xml
	declare @xmlload nvarchar(300)
    SET @xmlload= N'select @xml = (SELECT P FROM OPENROWSET (BULK N' + '''' + @file_path + '''' + ',' + ' SINGLE_BLOB, CODEPAGE=' + '''' + '1251' + '''' + ') AS Product(P));'
    exec sp_executesql @xmlload, N'@xml xml output', @xml=@xml output


    --    DECLARE @doc nvarchar(1000);
    --DECLARE @xmlDoc integer;
    
	DECLARE @hdoc int

    EXEC sp_xml_preparedocument @hdoc OUTPUT, @xml
	--EXEC sp_XML_preparedocument @xmlDoc OUTPUT, @doc;
    
	MERGE INTO manufactures as g
        USING 
        (
		    SELECT * FROM OPENXML (@hdoc, '/root/manufacturers/manufacturer', 2)
            WITH (
					[id] int,
					[name] varchar(MAX),
					[created_date] smalldatetime,
					[last_update_date] smalldatetime 
			      )
        ) as temp ([id], [name], [created_date], [last_update_date])
        ON (g.id = temp.id)
        --WHEN MATCHED THEN UPDATE SET r.RegionDescription = temp.RegionDescription   
        WHEN NOT MATCHED THEN INSERT ([id], [name], [created_date], [last_update_date])
        VALUES (temp.[id], temp.[name], temp.[created_date], temp.[last_update_date]);
    
	EXEC sp_xml_removedocument @hdoc

    COMMIT
END TRY
BEGIN CATCH
SELECT  
        ERROR_NUMBER() AS ErrorNumber  
        ,ERROR_SEVERITY() AS ErrorSeverity  
        ,ERROR_STATE() AS ErrorState  
        ,ERROR_PROCEDURE() AS ErrorProcedure  
        ,ERROR_MESSAGE() AS ErrorMessage;  
    ROLLBACK
END CATCH
END
*/
--exec Insert_Update_Manufactures 'C:\Users\konda\Desktop\ЭТАП 2 Lasmart\virtualpos\manufactures.xml'

/*
CREATE TABLE stores (
		 [open_time] time(0),
      [close_time] time(0),
      [id] int,
      [number] int,
      [name] varchar(MAX),
      [address] varchar(MAX),
      [phone] varchar(MAX),
      [headquerter_id] int,
      [created_date] smalldatetime,
      [created_by] int,
      [last_update_date] smalldatetime,
      [last_update_by] int,
      [flag24hours] int,
      [lat] float,
      [lon] float,
      [minusale] int,
      [location_id] int,
      [external_id] int,
      [show_in_shop] int,
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
      [organisation_id] int,
      [vat_mandatory_flag] int,
      [manager_user_id] int,
      [main_store_id] int,
      [location_name] varchar(MAX)
		);
go

CREATE PROCEDURE Insert_Update_Stores
( @file_path varchar(max) )
AS
BEGIN
    BEGIN TRANSACTION
    BEGIN TRY

	declare @xml xml
	declare @xmlload nvarchar(300)
    SET @xmlload= N'select @xml = (SELECT P FROM OPENROWSET (BULK N' + '''' + @file_path + '''' + ',' + ' SINGLE_BLOB, CODEPAGE=' + '''' + '1251' + '''' + ') AS Product(P));'
    exec sp_executesql @xmlload, N'@xml xml output', @xml=@xml output


    --    DECLARE @doc nvarchar(1000);
    --DECLARE @xmlDoc integer;
    
	DECLARE @hdoc int

    EXEC sp_xml_preparedocument @hdoc OUTPUT, @xml
	--EXEC sp_XML_preparedocument @xmlDoc OUTPUT, @doc;
    
	MERGE INTO stores as g
        USING 
        (
		    SELECT * FROM OPENXML (@hdoc, '/root/warehouses/warehouse', 2)
            WITH (
       
	  [open_time] time(0),
      [close_time] time(0),
      [id] int,
      [number] int,
      [name] varchar(MAX),
      [address] varchar(MAX),
      [phone] varchar(MAX),
      [headquerter_id] int,
      [created_date] smalldatetime,
      [created_by] int,
      [last_update_date] smalldatetime,
      [last_update_by] int,
      [flag24hours] int,
      [lat] float,
      [lon] float,
      [minusale] int,
      [location_id] int,
      [external_id] int,
      [show_in_shop] int,
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
      [organisation_id] int,
      [vat_mandatory_flag] int,
      [manager_user_id] int,
      [main_store_id] int,
      [location_name] varchar(MAX)
            )
        ) as temp ([open_time], [close_time], [id], [number], [name], [address], [phone], [headquerter_id], [created_date], [created_by],
		     [last_update_date], [last_update_by], [flag24hours], [lat], [lon], [minusale], [location_id], [external_id], [show_in_shop], 
			 [attribute1], [attribute2], [attribute3], [attribute4], [attribute5], [attribute6], [attribute7], [attribute8], [attribute9], 
			 [attribute10], [attribute11], [attribute12], [attribute13], [attribute14], [attribute15], [organisation_id], [vat_mandatory_flag],
			 [manager_user_id], [main_store_id], [location_name])
        ON (g.id = temp.id)
        --WHEN MATCHED THEN UPDATE SET r.RegionDescription = temp.RegionDescription   
        WHEN NOT MATCHED THEN INSERT ([open_time], [close_time], [id], [number], [name], [address], [phone], [headquerter_id], [created_date], [created_by],
		     [last_update_date], [last_update_by], [flag24hours], [lat], [lon], [minusale], [location_id], [external_id], [show_in_shop], 
			 [attribute1], [attribute2], [attribute3], [attribute4], [attribute5], [attribute6], [attribute7], [attribute8], [attribute9], 
			 [attribute10], [attribute11], [attribute12], [attribute13], [attribute14], [attribute15], [organisation_id], [vat_mandatory_flag],
			 [manager_user_id], [main_store_id], [location_name])
        VALUES (temp.[open_time], temp.[close_time], temp.[id], temp.[number], temp.[name], temp.[address], temp.[phone], temp.[headquerter_id], temp.[created_date], temp.[created_by],
		     temp.[last_update_date], temp.[last_update_by], temp.[flag24hours], temp.[lat], temp.[lon], temp.[minusale], temp.[location_id], temp.[external_id], temp.[show_in_shop], 
			 temp.[attribute1], temp.[attribute2], temp.[attribute3], temp.[attribute4], temp.[attribute5], temp.[attribute6], temp.[attribute7], temp.[attribute8], temp.[attribute9], 
			 temp.[attribute10], temp.[attribute11], temp.[attribute12], temp.[attribute13], temp.[attribute14], temp.[attribute15], temp.[organisation_id], temp.[vat_mandatory_flag],
			 temp.[manager_user_id], temp.[main_store_id], temp.[location_name]);
    
	EXEC sp_xml_removedocument @hdoc

    COMMIT
END TRY
BEGIN CATCH
SELECT  
        ERROR_NUMBER() AS ErrorNumber  
        ,ERROR_SEVERITY() AS ErrorSeverity  
        ,ERROR_STATE() AS ErrorState  
        ,ERROR_PROCEDURE() AS ErrorProcedure  
        ,ERROR_MESSAGE() AS ErrorMessage;  
    ROLLBACK
END CATCH
END
*/
--exec Insert_Update_Stores 'C:\Users\konda\Desktop\ЭТАП 2 Lasmart\virtualpos\stores.xml'


/*
CREATE TABLE suppliers (
      [id] int PRIMARY KEY,
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
		);
go

CREATE PROCEDURE Insert_Update_Suppliers
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
                temp.[price_coef], temp.[pricelist_life_length], temp.[type_name]);
    
	EXEC sp_xml_removedocument @hdoc

    COMMIT
END TRY
BEGIN CATCH
SELECT  
        ERROR_NUMBER() AS ErrorNumber,
		ERROR_SEVERITY() AS ErrorSeverity,
		ERROR_STATE() AS ErrorState,
		ERROR_PROCEDURE() AS ErrorProcedure,
		ERROR_MESSAGE() AS ErrorMessage;  
    ROLLBACK
END CATCH
END
go
*/
--exec Insert_Update_Suppliers 'C:\Users\konda\Desktop\ЭТАП 2 Lasmart\virtualpos\suppliers.xml'


 -- для создания таблицы дат
 /*
declare @start datetime
set @start = '04/20/2012'
while @start <getdate() begin
  print @start                        --вместо print insert
  set @start = dateadd(dd,1,@start)
end
*/



--SET ansi_nulls ON 
--go 
--SET quoted_identifier ON 
--go 
--SET ansi_padding ON 
--go 


--CREATE TABLE tbcategory_log 
--  ( 
--     [tabel_name]   VARCHAR(255) NULL,
--     [count_row]    int, 
--     [operation]      VARCHAR(20) NULL, 
--     [operation_dt]   DATETIME NULL, 
--     [operation_user] VARCHAR(255) NULL 
--  ) 
--go 
/*
Create proc insert_data @table_name varchar(50), 
                        @count_row int, 
						@operation varchar(20),
						@operation_dt DATETIME,
						@operation_user varchar(255)
						*/
--DROP TRIGGER tr_suppliers_u
--DROP TRIGGER tr_suppliers_i
--DROP TRIGGER tr_suppliers_d

--DROP TRIGGER tr_stores_u
--DROP TRIGGER tr_stores_i
--DROP TRIGGER tr_stores_d

--DROP TRIGGER tr_goods_u
--DROP TRIGGER tr_goods_i
--DROP TRIGGER tr_goods_d

--DROP TRIGGER tr_good_groups_u
--DROP TRIGGER tr_good_groups_i
--DROP TRIGGER tr_good_groups_d

--DROP TRIGGER tr_manufactures_u
--DROP TRIGGER tr_manufactures_i
--DROP TRIGGER tr_manufactures_d




--триггер ссылается на одну и ту же хранимую процедуру
--CREATE TRIGGER tr_suppliers_u ON [dbo].[suppliers]
--after UPDATE 
--AS 
--  BEGIN 
--      -- new string 
--      INSERT INTO tbcategory_log 
--      SELECT 'suppliers',
--	         COUNT([id]),
--             'update', 
--             Getdate(), 
--             Suser_name() 
--      FROM   deleted 
--  END 
--go 

--CREATE TRIGGER tr_suppliers_i ON [dbo].[suppliers]
--after INSERT 
--AS 
--  BEGIN 
--      INSERT INTO tbcategory_log 
--      SELECT 'suppliers',
--	         COUNT([id]),
--             'insert', 
--             Getdate(), 
--             Suser_name() 
--      FROM   inserted 
--  END 
--go 

--CREATE TRIGGER tr_suppliers_d ON [dbo].[suppliers]
--after DELETE 
--AS 
--  BEGIN 
--      INSERT INTO tbcategory_log 
--      SELECT 'suppliers',
--	         COUNT([id]),
--             'delete', 
--             Getdate(), 
--             Suser_name() 
--      FROM   deleted 
--  END 
--go 

--CREATE TRIGGER tr_stores_u ON [dbo].[stores]
--after UPDATE 
--AS 
--  BEGIN 
--      -- new string 
--      INSERT INTO tbcategory_log 
--      SELECT 'stores',
--	         COUNT([id]),
--             'update', 
--             Getdate(), 
--             Suser_name() 
--      FROM   inserted 
--  END 
--go 

--CREATE TRIGGER tr_stores_i ON [dbo].[stores]
--after INSERT 
--AS 
--  BEGIN 
--      INSERT INTO tbcategory_log 
--      SELECT 'stores',
--	         COUNT([id]),
--             'insert', 
--             Getdate(), 
--             Suser_name() 
--      FROM   inserted 
--  END 
--go 

--CREATE TRIGGER tr_stores_d ON [dbo].[stores]
--after DELETE 
--AS 
--  BEGIN 
--      INSERT INTO tbcategory_log 
--      SELECT 'stores',
--	         COUNT([id]),
--             'delete', 
--             Getdate(), 
--             Suser_name() 
--      FROM   deleted 
--  END 
--go 

--CREATE TRIGGER tr_manufactures_u ON [dbo].[manufactures]
--after UPDATE 
--AS 
--  BEGIN 
--      -- new string 
--      INSERT INTO tbcategory_log 
--      SELECT 'manufactures',
--	         COUNT([id]),
--             'update', 
--             Getdate(), 
--             Suser_name() 
--      FROM   inserted 
--  END 
--go 

--CREATE TRIGGER tr_manufactures_i ON [dbo].[manufactures]
--after INSERT 
--AS 
--  BEGIN 
--      INSERT INTO tbcategory_log 
--      SELECT 'manufactures',
--	         COUNT([id]),
--             'insert', 
--             Getdate(), 
--             Suser_name() 
--      FROM   inserted 
--  END 
--go 

--CREATE TRIGGER tr_manufactures_d ON [dbo].[manufactures]
--after DELETE 
--AS 
--  BEGIN 
--      INSERT INTO tbcategory_log 
--      SELECT 'manufactures',
--	         COUNT([id]),
--             'delete', 
--             Getdate(), 
--             Suser_name() 
--      FROM   deleted 
--  END 
--go 

--CREATE TRIGGER tr_goods_u ON [dbo].[goods]
--after UPDATE 
--AS 
--  BEGIN 
--      -- new string 
--      INSERT INTO tbcategory_log 
--      SELECT 'goods',
--	         COUNT([id]),
--             'update', 
--             Getdate(), 
--             Suser_name() 
--      FROM   inserted 
--  END 
--go 

--CREATE TRIGGER tr_goods_i ON [dbo].[goods]
--after INSERT 
--AS 
--  BEGIN 
--      INSERT INTO tbcategory_log 
--      SELECT 'goods',
--	         COUNT([id]),
--             'insert', 
--             Getdate(), 
--             Suser_name() 
--      FROM   inserted 
--  END 
--go 

--CREATE TRIGGER tr_goods_d ON [dbo].[goods]
--after DELETE 
--AS 
--  BEGIN 
--      INSERT INTO tbcategory_log 
--      SELECT 'goods',
--	         COUNT([id]),
--             'delete', 
--             Getdate(), 
--             Suser_name() 
--      FROM   deleted 
--  END 
--go 

--CREATE TRIGGER tr_good_groups_u ON [dbo].[good_groups]
--after UPDATE 
--AS 
--  BEGIN 
--      -- new string 
--      INSERT INTO tbcategory_log 
--      SELECT 'good_groups',
--	         COUNT([id]),
--             'update', 
--             Getdate(), 
--             Suser_name() 
--      FROM   inserted 
--  END 
--go 

--CREATE TRIGGER tr_good_groups_i ON [dbo].[good_groups]
--after INSERT 
--AS 
--  BEGIN 
--      INSERT INTO tbcategory_log 
--      SELECT 'goods',
--	         COUNT([id]),
--             'insert', 
--             Getdate(), 
--             Suser_name() 
--      FROM   inserted 
--  END 
--go 

--CREATE TRIGGER tr_good_groups_d ON [dbo].[good_groups]
--after DELETE 
--AS 
--  BEGIN 
--      INSERT INTO tbcategory_log 
--      SELECT 'good_groups',
--	         COUNT([id]),
--             'delete', 
--             Getdate(), 
--             Suser_name() 
--      FROM   deleted 
--  END 
--go 



--SET ansi_padding OFF 
--go

--TRUNCATE TABLE tbcategory_log 
--DROP TRIGGER tr_suppliers
--DROP TRIGGER tr_goods
--DROP TRIGGER tr_good_groups
--DROP TRIGGER tr_manufactures
--DROP TRIGGER tr_stores

--CREATE TABLE tbcategory_log 
--  ( 
--     [tabel_name]   VARCHAR(255) NULL,
--     [count_row]    int, 
--     [operation]      VARCHAR(20) NULL, 
--     [operation_dt]   DATETIME NULL, 
--     [operation_user] VARCHAR(255) NULL 
--  ) 
--go 

--CREATE TRIGGER tr_suppliers
--ON [suppliers]
--AFTER INSERT, UPDATE, DELETE
--AS
--BEGIN
--	DECLARE @operation CHAR(6)
--		SET @operation = CASE
--				WHEN EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted)
--					THEN 'Update'
--				WHEN EXISTS(SELECT * FROM inserted)
--					THEN 'Insert'
--				WHEN EXISTS(SELECT * FROM deleted)
--					THEN 'Delete'
--				ELSE NULL
--		END
--	IF @operation = 'Delete'
--			INSERT INTO tbcategory_log 
--            SELECT 'suppliers', COUNT([id]), 'delete', Getdate(), Suser_name() 
--              FROM   deleted 

--	IF @operation = 'Insert'
--			INSERT INTO tbcategory_log 
--			SELECT 'suppliers', COUNT([id]), 'insert', Getdate(), Suser_name() 
--              FROM   inserted 

--	IF @operation = 'Update'
--			INSERT INTO tbcategory_log 
--            SELECT 'suppliers', COUNT([id]), 'update', Getdate(), Suser_name() 
--              FROM   inserted 
--END
--GO

--CREATE TRIGGER tr_stores
--ON [stores]
--AFTER INSERT, UPDATE, DELETE
--AS
--BEGIN
--	DECLARE @operation CHAR(6)
--		SET @operation = CASE
--				WHEN EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted)
--					THEN 'Update'
--				WHEN EXISTS(SELECT * FROM inserted)
--					THEN 'Insert'
--				WHEN EXISTS(SELECT * FROM deleted)
--					THEN 'Delete'
--				ELSE NULL
--		END
--	IF @operation = 'Delete'
--			INSERT INTO tbcategory_log 
--            SELECT 'stores', COUNT([id]), 'delete', Getdate(), Suser_name() 
--              FROM   deleted 

--	IF @operation = 'Insert'
--			INSERT INTO tbcategory_log 
--			SELECT 'stores', COUNT([id]), 'insert', Getdate(), Suser_name() 
--              FROM   inserted 

--	IF @operation = 'Update'
--			INSERT INTO tbcategory_log 
--            SELECT 'stores', COUNT([id]), 'update', Getdate(), Suser_name() 
--              FROM   inserted 
--END
--GO

--CREATE TRIGGER tr_manufactures
--ON [manufactures]
--AFTER INSERT, UPDATE, DELETE
--AS
--BEGIN
--	DECLARE @operation CHAR(6)
--		SET @operation = CASE
--				WHEN EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted)
--					THEN 'Update'
--				WHEN EXISTS(SELECT * FROM inserted)
--					THEN 'Insert'
--				WHEN EXISTS(SELECT * FROM deleted)
--					THEN 'Delete'
--				ELSE NULL
--		END
--	IF @operation = 'Delete'
--			INSERT INTO tbcategory_log 
--            SELECT 'manufactures', COUNT([id]), 'delete', Getdate(), Suser_name() 
--              FROM   deleted 

--	IF @operation = 'Insert'
--			INSERT INTO tbcategory_log 
--			SELECT 'manufactures', COUNT([id]), 'insert', Getdate(), Suser_name() 
--              FROM   inserted 

--	IF @operation = 'Update'
--			INSERT INTO tbcategory_log 
--            SELECT 'manufactures', COUNT([id]), 'update', Getdate(), Suser_name() 
--              FROM   inserted 
--END
--GO

--CREATE TRIGGER tr_goods
--ON [goods]
--AFTER INSERT, UPDATE, DELETE
--AS
--BEGIN
--	DECLARE @operation CHAR(6)
--		SET @operation = CASE
--				WHEN EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted)
--					THEN 'Update'
--				WHEN EXISTS(SELECT * FROM inserted)
--					THEN 'Insert'
--				WHEN EXISTS(SELECT * FROM deleted)
--					THEN 'Delete'
--				ELSE NULL
--		END
--	IF @operation = 'Delete'
--			INSERT INTO tbcategory_log 
--            SELECT 'goods', COUNT([id]), 'delete', Getdate(), Suser_name() 
--              FROM   deleted 

--	IF @operation = 'Insert'
--			INSERT INTO tbcategory_log 
--			SELECT 'goods', COUNT([id]), 'insert', Getdate(), Suser_name() 
--              FROM   inserted 

--	IF @operation = 'Update'
--			INSERT INTO tbcategory_log 
--            SELECT 'goods', COUNT([id]), 'update', Getdate(), Suser_name() 
--              FROM   inserted 
--END
--GO

--CREATE TRIGGER tr_good_groups
--ON [good_groups]
--AFTER INSERT, UPDATE, DELETE
--AS
--BEGIN
--	DECLARE @operation CHAR(6)
--		SET @operation = CASE
--				WHEN EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted)
--					THEN 'Update'
--				WHEN EXISTS(SELECT * FROM inserted)
--					THEN 'Insert'
--				WHEN EXISTS(SELECT * FROM deleted)
--					THEN 'Delete'
--				ELSE NULL
--		END
--	IF @operation = 'Delete'
--			INSERT INTO tbcategory_log 
--            SELECT 'good_groups', COUNT([id]), 'delete', Getdate(), Suser_name() 
--              FROM   deleted 

--	IF @operation = 'Insert'
--			INSERT INTO tbcategory_log 
--			SELECT 'good_groups', COUNT([id]), 'insert', Getdate(), Suser_name() 
--              FROM   inserted 

--	IF @operation = 'Update'
--			INSERT INTO tbcategory_log 
--            SELECT 'good_groups', COUNT([id]), 'update', Getdate(), Suser_name() 
--              FROM   inserted 
--END
--GO



--exec Insert_Update_Suppliers 'C:\Users\konda\Desktop\ЭТАП 2 Lasmart\virtualpos\suppliers.xml'
--exec Insert_Update_Stores 'C:\Users\konda\Desktop\ЭТАП 2 Lasmart\virtualpos\stores.xml'
--exec Insert_Update_Manufactures 'C:\Users\konda\Desktop\ЭТАП 2 Lasmart\virtualpos\manufactures.xml'
--exec Insert_Update_Goods 'C:\Users\konda\Desktop\ЭТАП 2 Lasmart\virtualpos\goods.xml'
--exec Insert_Update_Good_Groups 'C:\Users\konda\Desktop\ЭТАП 2 Lasmart\virtualpos\goodgroups.xml'

/*
if object_id('dbo.TriggerTable') is not null drop table dbo.TriggerTable
if object_id('dbo.LogTable') is not null drop table dbo.LogTable
create table dbo.TriggerTable( field int )
create table dbo.LogTable( field nvarchar(4000) )
 
/*создаем триггер на вставку*/
go
create trigger TriggerTable_insert on  dbo.TriggerTable after insert, update, delete as
begin
    set nocount on;
 
    declare @temp table(EventType nvarchar (30), Parameters int, EventInfo nvarchar(4000) )
    insert into @temp
    exec sp_executesql N'DBCC inputbuffer (@@spid) WITH NO_INFOMSGS'
 
    insert into dbo.LogTable
    select EventInfo from @temp
 
end

go
insert into dbo.TriggerTable values (1)
go
insert into dbo.TriggerTable values (2)
go
 
/* проверяем что записалось в лог */
select * from dbo.LogTable
go
 
/* удаляем тестовые таблицы */
drop table dbo.LogTable
drop table dbo.TriggerTable
go
*/

--USE [BaseOne]
--GO
--/****** Object:  StoredProcedure [BaseOne].[Log_ProcedureCall]    Script Date: 15.10.2020 0:18:26 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
--ALTER PROCEDURE [BaseOne].[Log_ProcedureCall]
-- @ObjectID       INT,
-- @DatabaseID     INT = NULL,
-- @AdditionalInfo NVARCHAR(MAX) = NULL,
-- @RowCount INT

--AS
--BEGIN
-- SET NOCOUNT ON;

-- DECLARE 
--  @ProcedureName NVARCHAR(400)
  
-- SELECT
--  @DatabaseID = COALESCE(@DatabaseID, DB_ID()), --если null вернет null
--  @ProcedureName = COALESCE
--  (
--   QUOTENAME(DB_NAME(@DatabaseID)) + '.'
--   + QUOTENAME(OBJECT_SCHEMA_NAME(@ObjectID, @DatabaseID)) 
--   + '.' + QUOTENAME(OBJECT_NAME(@ObjectID, @DatabaseID)),
--   ERROR_PROCEDURE()
--  );

--  DECLARE 
--   @EventType nvarchar(400)
--   SET @EventType = NULL
-- -- SELECT * FROM inserted

--  --DECLARE @data XML,
--  --      @EventType nvarchar(100);
--  --SET @data = EVENTDATA();
--  --SET @EventType = @data.value('(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(100)');
 
-- INSERT BaseOne.dbo.ProcedureLog
-- (
--  DatabaseID,
--  ObjectID,
--  ProcedureName,
--  ErrorLine,
--  ErrorMessage,
--  AdditionalInfo,
--  Row_count,
--  [User],
--  EventType
-- )
-- SELECT
--  @DatabaseID,
--  @ObjectID,
--  @ProcedureName,
--  ERROR_LINE(),
--  ERROR_MESSAGE(),
--  @AdditionalInfo,
--  @RowCount,
--  Suser_name(),
--  @EventType;
--END

--INSERT BaseOne.dbo.ProcedureLog
--    OUTPUT INSERTED.ScrapReasonID, INSERTED.Name, INSERTED.ModifiedDate  
--        INTO @MyTableVar  
--VALUES (N'Operator error', GETDATE());  


--TRUNCATE TABLE [dbo].[suppliers]
exec Insert_Update_Suppliers 'C:\Users\konda\Desktop\ЭТАП 2 Lasmart\virtualpos\suppliers.xml'
exec Insert_Update_Stores 'C:\Users\konda\Desktop\ЭТАП 2 Lasmart\virtualpos\stores.xml'
exec Insert_Update_Manufactures 'C:\Users\konda\Desktop\ЭТАП 2 Lasmart\virtualpos\manufactures.xml'
exec Insert_Update_Goods 'C:\Users\konda\Desktop\ЭТАП 2 Lasmart\virtualpos\goods.xml'
exec Insert_Update_Good_Groups 'C:\Users\konda\Desktop\ЭТАП 2 Lasmart\virtualpos\goodgroups.xml'
--exec BaseOne.Log_ProcedureCall @ObjectID = @@PROCID;

--DECLARE @data XML,
--        @EventType nvarchar(100);
--SET @data = EVENTDATA();

--SET @EventType = @data.value('(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(100)');

--SELECT @EventType


--select tab.name
--FROM sys.sql_modules   m 
--INNER JOIN sys.objects o ON m.object_id=o.object_id
--INNER JOIN sys.sql_dependencies dep ON m.object_id = dep.object_id
--INNER JOIN sys.columns col ON dep.referenced_major_id = col.object_id
--INNER JOIN sys.tables tab ON tab.object_id = col.object_id
--INNER JOIN sys.sql_expression_dependencies AS sed ON sed.referencing_id = o.object_id 
--WHERE m.object_id = 1458104235


--SELECT *
--FROM sys.fn_dblog(null, null)
--SELECT * FROM sys.dm_sql_referenced_entities ('stores', 'OBJECT')


--CREATE TABLE [dbo].[ProcedureLog](
--[LogDate] [smalldatetime] NOT NULL,
--[DatabaseID] [int] NULL,
--[ObjectID] [int] NULL,
--[ProcedureName] [nvarchar](400) NULL,
--[ErrorLine] [int] NULL,
--[ErrorMessage] [nvarchar](max) NULL,
--[AdditionalInfo] [nvarchar](max) NULL,
--[Row_count] [int] NULL,
--[User] [nvarchar](max),
--[EventType] [nvarchar](max),
--[Tabel_name] [nvarchar](max)

--) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
--GO

--ALTER TABLE [dbo].[ProcedureLog] ADD DEFAULT (getdate()) FOR [LogDate]
--GO


--CREATE CLUSTERED INDEX cx_LogDate ON dbo.ProcedureLog(LogDate);
--GO


--+

CREATE TABLE fac_receipt (
        [receipt_id] nvarchar(255), -- уникальный GUID чека
        [terminalid] bigint, -- регистрационный номер фискального регистратора. Если ФР не используется, то передается некий уникальный идентификатор рабочего места кассира
        [warehouseid] int REFERENCES dim_stock([id_s]), -- ID склада/магазина в системе VirtualPos
        [doc_type] nvarchar(255), -- тип чека: sale или return
        [date] date REFERENCES dim_date([TheDate]), -- дата продажи в формате dd.mm.yyy hh:mi:ss
        [items_count] bigint,-- количество товаров в чеке
		[line_id] nvarchar(255), -- уникальный GUID строки чека 
        [itemid] int REFERENCES goods([id]), -- ID товара в ВиртуалПос+
        [discount_name] nvarchar(max),  -- наименование акции
        [quantity] float, -- количество товара в чеке
        [pricebase] float, --цена по прайслисту за единицу товара (без учета скидки)
        [pricesale] float, -- цена продажи за единицу товара (с учетом скидки)
        [discount] float, -- сумма скидки
        [amount] float, --сумма по строке чека (с учетом скидки)
        [cogs] float --себестоимость товара
		)
go

--CREATE TABLE f_receipt_lines (
----строки чека
--        [line_id] nvarchar(255) PRIMARY KEY, -- уникальный GUID строки чека
--        --[receipt_id] nvarchar(255) REFERENCES f_receipt([receipt_id]), -- уникальный GUID строки чека
--        [itemid] bigint, -- ID товара в ВиртуалПос+
--        [discount_name] nvarchar(max),  -- наименование акции
--        [quantity] nvarchar(max), -- количество товара в чеке
--        [pricebase] nvarchar(max), --цена по прайслисту за единицу товара (без учета скидки)
--        [pricesale] nvarchar(max), -- цена продажи за единицу товара (с учетом скидки)
--        [discount] nvarchar(max), -- сумма скидки
--        [amount] nvarchar(max), --сумма по строке чека (с учетом скидки)
--        [cogs] nvarchar(max) --себестоимость товара
--		);
--go

--CREATE CLUSTERED INDEX CIX_f_receipt ON fac_receipt
--CREATE CLUSTERED INDEX CIX_f_receipt_line ON f_receipt_lines 
 
 --заголовок прихода
CREATE TABLE fac_income (
        [id] int, -- ID документа поступления
        [warehouse_id] int REFERENCES dim_stock([id_s]), -- код склада, на который оформлено поступление
        [docdate] date REFERENCES dim_date([TheDate]), --дата документа поступления
        [supplier_id] int, /*REFERENCES suppliers([id])*/ -- ID Поставщика
        [amount_income] nvarchar(max), -- сумма поставки NULL
        [status] nvarchar(max), -- статус документа поставки (accept – принят, drаft – черновик)
		[line_id] int , --line id
		[item_id] int REFERENCES goods([id]), -- ID товарной позиции по номенклатурному справочнику ??????????????
        [quantity] float, -- количество товара в чеке
        [price] float, --цена поступления
        [amount] float --сумма
)
go

--CREATE TABLE f_income_lines (
--        [item_id] int, /*REFERENCES goods([id])*/ -- ID товарной позиции по номенклатурному справочнику
--		--[id] int REFERENCES f_income([id]), -- ID документа поступления
--        [quantity] float, -- количество товара в чеке
--        [price] float, --цена поступления
--        [amount] float --сумма
--)
--go

CREATE TABLE fac_movegood (
		--заголовок перемещения
		[id] int, -- уникальный GUID перемещения
		[src_warehouse_id] int REFERENCES dim_stock([id_s]), -- Код склада, с которого перемещается товар
		[dst_warehouse_id] int REFERENCES dim_stock([id_s]), -- Код склада, на который перемещается товар
		[amount_movegod] float, --Сумма перемещения
		[status] nvarchar(max), -- Код статуса документа
		[status_name] nvarchar(max), -- Статус документа
		[created_date] date REFERENCES dim_date([TheDate]), -- Дата создания документа Перемещения в формате dd.mm.yyy hh:mi:ss
		[line_id] int , -- уникальный GUID строки перемещения
		[item_id] int REFERENCES goods([id]), -- ID товара в ВиртуалПос
		[quantity] float, -- количество товара
		[price] float, -- Себестоимость товара в перемещении
		[amount] float --сумма по строке
)
go

--CREATE TABLE f_movegood_lines (
----строки перемещения
--[line_id] int PRIMARY KEY, -- уникальный GUID строки перемещения
----[id] int REFERENCES f_movegood([id]), -- уникальный GUID перемещения
--[item_id] int, -- ID товара в ВиртуалПос
--[quantity] float, -- количество товара
--[price] float, -- Себестоимость товара в перемещении
--[amount] float --сумма по строке
--)
--go

CREATE TABLE [fac_returns] (
--заголовок возврата
[id] int, -- уникальный GUID возврата
[warehouse_id] int REFERENCES dim_stock([id_s]), -- Код склада 
[docnum] nvarchar(max), -- Код документа
[docdate] date REFERENCES dim_date([TheDate]), -- Дата документа Возврат поставщику
[supplier_id] nvarchar(max), -- Код поставщика
[amount_returns] float, --Сумма возврата
[status] nvarchar(max), -- Код статуса документа
[status_name] nvarchar(max), -- Статус документа
[line_id] int,-- уникальный GUID строки возврата
--[id] int REFERENCES f_returns([id]), -- уникальный GUID возврата
[item_id] int REFERENCES goods ([id]),-- ID товара в ВиртуалПос
[quantity] float, -- количество товара в чеке
[price] float,-- Себестоимость товара в перемещении
[amount] float,--сумма по строке
[expir_date] nvarchar(max)-- Срок годности товара
)
go

--CREATE TABLE [f_returns_lines] (
----строки возврата
--[line_id] int PRIMARY KEY,-- уникальный GUID строки возврата
----[id] int REFERENCES f_returns([id]), -- уникальный GUID возврата
--[item_id] int,-- ID товара в ВиртуалПос
--[quantity] float, -- количество товара в чеке
--[price] float,-- Себестоимость товара в перемещении
--[amount] float,--сумма по строке
--[expir_date] nvarchar(max)-- Срок годности товара
--)
--go

CREATE TABLE dim_stock (
[id_s] int PRIMARY KEY,
[name_s] nvarchar(max)
)

CREATE TABLE fac_stock (
--заголовок остатков
[id_s] int REFERENCES dim_stock([id_s]), -- Код склада
[id_n] int REFERENCES goods([id]),-- ID товарной позиции по номенклатурному справочнику
[quantity] float,-- количество товара в чеке
[date] date REFERENCES dim_date([TheDate]),
--[price] float,--цена поступления
[cogs] float --себестоимость
)
go

--CREATE TABLE f_stock_lines (
----строки остатков
--[id_s] int REFERENCES f_stock([id_s]) , -- Код склада
--[id_n] int REFERENCES goods([id]),-- ID товарной позиции по номенклатурному справочнику
--[quantity] nvarchar(max),-- количество товара в чеке
--[price] nvarchar(max),--цена поступления
--[cogs] nvarchar(max)--себестоимость
--)


--	  DECLARE @x1 xml
--DECLARE @x varchar(max)
--Create table asd_stock (x xml)
--SELECT @x=P
--FROM OPENROWSET (BULK 'C:\Users\konda\Desktop\ЭТАП 2 Lasmart\virtualpos\stock.xml', SINGLE_BLOB, CODEPAGE='1251') AS Product(P)

--SET @x = REPLACE (@x, 'UTF-8', 'windows-1251')
--SET @x1 = @x
--SELECT @x1 INSERT INTO asd_stock(x) Values (@x1)


exec Insert_fac_stock 'C:\Users\konda\Desktop\ЭТАП 2 Lasmart\virtualpos\stock.xml'
exec Insert_fac_receipt 'C:\Users\konda\Desktop\ЭТАП 2 Lasmart\virtualpos\receipt.xml'
exec Insert_fac_movegood 'C:\Users\konda\Desktop\ЭТАП 2 Lasmart\virtualpos\movegood.xml'
exec Insert_fac_income 'C:\Users\konda\Desktop\ЭТАП 2 Lasmart\virtualpos\income.xml'
exec Insert_fac_returns 'C:\Users\konda\Desktop\ЭТАП 2 Lasmart\virtualpos\returns.xml'

--?????

-- ПЕРЕДЕЛАТЬ ТАБЛИЦУ СКЛАД
DELETE FROM [goods] 
WHERE id = 0;

  INSERT INTO [goods] ([id], [name], [group_ids])
VALUES (0 , 'unamed', 615);

SELECT f.[item_id], g.name
  FROM [BaseOne].[dbo].[fac_income] as f
  left join goods as g on f.item_id = g.id
  WHERE g.id is null

  SELECT *
  FROM [BaseOne].[dbo].[f_income] as a
  INNER JOIN f_income_lines as x ON a.id = x.id
  WHERE item_id = 0


  
  IF EXISTS (SELECT * FROM information_schema.tables WHERE Table_Name = 'dim_date' AND Table_Type = 'BASE TABLE')
BEGIN
DROP TABLE [dim_date]
END

CREATE TABLE [dim_date]
(
[date] DATE PRIMARY KEY,
[month] int,
[day] int,
[year] int
)

DECLARE @StartDate DATE
DECLARE @EndDate DATE
SET @StartDate = '20180101'
SET @EndDate = DATEADD(d, 3000, @StartDate)

WHILE @StartDate <= @EndDate
BEGIN
INSERT INTO [dim_date]
(
[date],
[month],
[day],
[year]
)
SELECT
@StartDate,
DATEPART(MM, @StartDate),
DAY(@StartDate),
YEAR(@StartDate)
--SUBSTRING(CAST(MONTH(@StartDate) as nvarchar), 0, 3) + '/' + CAST(YEAR(@StartDate) as nvarchar)

SET @StartDate = DATEADD(dd, 1, @StartDate)
END
  


  SELECT CONVERT(INT, CONVERT(DATETIME,'2013-08-05 09:23:30'))

SELECT CONVERT(INT, CAST ('2013-08-05 09:23:30' as DATETIME))


--SELECT a.[date] 
--  FROM [BaseOne].[dbo].[f_receipt] as a
--  LEFT JOIN [dim_date] as d ON a.[date] = d.[date]
--  WHERE d.[date] IS NULL


--CREATE VIEW move_goods (кол_во_год, [Название_Опасного_Явления], Название_Субъекта,            Год, ср_длитОЯ, Повтор_всего_П1, К, S_9vl, S_syb, VRP, Населен,R) AS 
--SELECT COUNT (i.[Название_Опасного_Явления]),
--              i.[Название_Опасного_Явления], 
--			   i.Название_Субъекта, 
			   
--			   YEAR(Дата_Начала),
--               AVG(datediff(DAY,Дата_Начала,Дата_Окончания))+1,
--			   COUNT (i.[Название_Опасного_Явления])/27.0,
--			   j.КоэффициентАгрессивности,
--			   j.Средн_Площадь,
--			   k.Площадь,
--			   k.ВРП /365 / k.Население,
--			   k.Население,
--			   COUNT (i.[Название_Опасного_Явления])*j.Средн_Площадь/k.Площадь*(AVG(datediff(DAY,Дата_Начала,Дата_Окончания))+1)*j.КоэффициентАгрессивности*k.Население*(k.ВРП/365 / k.Население)
--FROM [Список_опасных_явлений] AS i
--INNER JOIN Опасные_Явления1 AS j ON i.Название_Опасного_Явления = j.Название_Опасного_Явления
--INNER JOIN Субъекты_Сведения AS k ON i.Название_Субъекта = k.Название_Субъекта

--WHERE Дата_Начала IS NOT NULL
--GROUP BY i.[Название_Опасного_Явления], i.Название_Субъекта,           j.КоэффициентАгрессивности, j.Средн_Площадь, YEAR(Дата_Начала),k.Площадь, k.ВРП,
--		 k.Население
----ORDER BY YEAR(Дата_Начала) ASC
--go



select [warehouse_id], [item_id], [docdate], sum(quantity) as количество
from [fac_income]
group by [warehouse_id], [item_id], [docdate]

select [src_warehouse_id], [dst_warehouse_id], [status], [status_name], [created_date], 
       [item_id], SUM([quantity]) as количество, SUM([amount]) as сумма
from [fac_movegood]
group by [src_warehouse_id], [dst_warehouse_id], [status], [status_name], [created_date], 
       [item_id]


select [warehouseid], [doc_type], [date], [itemid], sum([quantity]) as количество, 
       sum([pricebase]) as pricebase, sum([pricesale]) as pricesale, sum([discount]) as discount, sum([amount]) as amount, sum([cogs]) as cogs
	  FROM [dbo].[fac_receipt]
group by [warehouseid], [doc_type], [date], [itemid]

select [warehouse_id], [docdate], [status], [status_name], [item_id],
       sum([quantity]) as quantity, sum([price]) as price, sum([amount]) as amount
FROM [dbo].[fac_returns]
group by [warehouse_id], [docdate], [item_id], [status], [status_name]

select [id_s], [id_n], sum([quantity]) as [quantity], sum([cogs]) as [cogs]
FROM [dbo].[fac_stock]
group by [id_s], [id_n]

---------------------

select i.[warehouse_id], i.[item_id], i.[docdate], sum(i.quantity - r.quantity + ret.quantity) as количество
from [fac_income] as i
inner join fac_receipt as r on i.warehouse_id = r.warehouseid and i.item_id = r.itemid and i.docdate = r.[date]
inner join fac_returns as ret on r.warehouseid = ret.warehouse_id and r.itemid = ret.item_id and r.[date] = ret.[docdate]
group by i.[warehouse_id], i.[item_id], i.[docdate]
order by docdate desc

-------------------- расчетный остаток на основании всех описанных видов движений



ALTER VIEW calculated_balance_good as
SELECT [warehouse_id], [docdate], [item_id], sum(quantity) as quantity
	FROM 
		(
		-- quantity, price, amount, status - accept/complite/draft
		select [warehouse_id], [item_id], quantity
		from [fac_income]
		
		
		
		UNION ALL 
		
		--[pricebase] ,[pricesale] ,[discount] ,[amount] ,[cogs]  doctype - sales/return
		select [warehouseid], [date], [itemid], -[quantity]
		FROM [dbo].[fac_receipt] 
		WHERE doc_type = 'sales'
		UNION ALL 
		select [warehouseid], [date], [itemid], [quantity]
		FROM [dbo].[fac_receipt] 
		WHERE doc_type = 'return'

		UNION ALL 
		--[quantity] ,[price] ,[amount], status - accept
		select [warehouse_id], [docdate], [item_id], [quantity]
		FROM [dbo].[fac_returns]
		UNION ALL

		--,[quantity] ,[price] ,[amount], status - accept/send
		select [src_warehouse_id], [created_date], [item_id], -[quantity]
		from [fac_movegood]
		WHERE [status] = 'accept'
		UNION ALL
		--,[quantity] ,[price] ,[amount], status - accept/send
		select [dst_warehouse_id], [created_date], [item_id], [quantity]
		from [fac_movegood]
		WHERE [status] = 'accept'
        UNION ALL

		--cogs(себестоимость)
		select [id_s], [date], [id_n], [quantity]
        FROM [fac_stock]
		
		) as details
	GROUP BY [warehouse_id], [docdate], [item_id]
	


ALTER VIEW calculated_balance_good as
SELECT [warehouse_id], [docdate], [item_id], sum(quantity) as quantity
	FROM 
		(
		-- amount, status - accept/complite/draft
		select [warehouse_id], [docdate], [item_id], quantity
		from [fac_income] 
		UNION ALL 
		
		--[amount] ,[cogs]  doctype - sales/return
		select [warehouseid], [date], [itemid], -[quantity]
		FROM [dbo].[fac_receipt] 
		UNION ALL 
		--[amount], status - accept
		select [warehouse_id], [docdate], [item_id], [quantity]
		FROM [dbo].[fac_returns]
		UNION ALL
		--[amount], statis - accept/send
		select [src_warehouse_id], [created_date], [item_id], -[quantity]
		from [fac_movegood]
		UNION ALL
		--[amount], statis - accept/send
		select [dst_warehouse_id], [created_date], [item_id], [quantity]
		from [fac_movegood]
        UNION ALL
		--cogs(себестоимость)
		select [id_s], [date], [id_n], [quantity]
        FROM [fac_stock]
		
		) as details
	GROUP BY [warehouse_id], [docdate], [item_id]



	-----last
	create VIEW calculated_balance_good as
SELECT [warehouse_id], [docdate], [item_id], sum(quantity) as quantity, sum([amount]) as amount
	FROM 
		(
		-- quantity, price, amount, status - accept/complite/draft
		select [warehouse_id],[docdate], [item_id], quantity, [amount]
		from [fac_income]
		
		
		
		UNION ALL 
		
		--[pricebase] ,[pricesale] ,[discount] ,[amount] ,[cogs]  doctype - sales/return
		select [warehouseid], [date], [itemid], -[quantity], -[cogs]
		FROM [dbo].[fac_receipt] 
		WHERE doc_type = 'sales'
		UNION ALL 
		select [warehouseid], [date], [itemid], [quantity], [cogs]
		FROM [dbo].[fac_receipt] 
		WHERE doc_type = 'return'

		UNION ALL 
		--[quantity] ,[price] ,[amount], status - accept
		select [warehouse_id], [docdate], [item_id], [quantity], [amount]
		FROM [dbo].[fac_returns]
		UNION ALL

		--,[quantity] ,[price] ,[amount], status - accept/send
		select [src_warehouse_id], [created_date], [item_id], -[quantity] , -[amount]
		from [fac_movegood]
		WHERE [status] = 'accept'
		UNION ALL
		--,[quantity] ,[price] ,[amount], status - accept/send
		select [dst_warehouse_id], [created_date], [item_id], [quantity], [amount]
		from [fac_movegood]
		WHERE [status] = 'accept'
        UNION ALL

		--cogs(себестоимость)
		select [id_s], [date], [id_n], [quantity], [cogs]
        FROM [fac_stock]
		
		) as details
	GROUP BY [warehouse_id], [docdate], [item_id]

--чеки
	create VIEW calculated_receipt as
SELECT [warehouse_id], [docdate], [item_id], sum(quantity) as quantity, sum([amount]) as amount
	FROM 
		(
		-- quantity, price, amount, status - accept/complite/draft
		select [warehouse_id],[docdate], [item_id], quantity, [amount]
		from [fac_income]
		
		
		
		UNION ALL 
		
		--[pricebase] ,[pricesale] ,[discount] ,[amount] ,[cogs]  doctype - sales/return
		select [warehouseid], [date], [itemid], -[quantity], -[cogs]
		FROM [dbo].[fac_receipt] 
		WHERE doc_type = 'sales'
		UNION ALL 
		select [warehouseid], [date], [itemid], [quantity], [cogs]
		FROM [dbo].[fac_receipt] 
		WHERE doc_type = 'return'

		UNION ALL 
		--[quantity] ,[price] ,[amount], status - accept
		select [warehouse_id], [docdate], [item_id], [quantity], [amount]
		FROM [dbo].[fac_returns]
		UNION ALL

		--,[quantity] ,[price] ,[amount], status - accept/send
		select [src_warehouse_id], [created_date], [item_id], -[quantity] , -[amount]
		from [fac_movegood]
		WHERE [status] = 'accept'
		UNION ALL
		--,[quantity] ,[price] ,[amount], status - accept/send
		select [dst_warehouse_id], [created_date], [item_id], [quantity], [amount]
		from [fac_movegood]
		WHERE [status] = 'accept'
        UNION ALL

		--cogs(себестоимость)
		select [id_s], [date], [id_n], [quantity], [cogs]
        FROM [fac_stock]
		
		) as details
	GROUP BY [warehouse_id], [docdate], [item_id]











select [id_s], [id_n], sum([quantity]) as [quantity]
FROM [dbo].[fac_stock]
group by [id_s], [id_n]

select [src_warehouse_id], [dst_warehouse_id], [created_date], 
       [item_id], SUM([quantity]) as количество
from [fac_movegood]
group by [src_warehouse_id], [dst_warehouse_id], [status], [status_name], [created_date], 
       [item_id]


DELETE FROM [goods] 
WHERE id = 0;

  INSERT INTO [good_groups] ([id], [name], [parent_id])
VALUES (0 , 'unamed', 0);



	   --good_groups

	CREATE TABLE [dim_goods_parent]
	(
	[id] int REFERENCES goods ([id]), 
	[name] nvarchar(max), 
	[groups] int REFERENCES good_groups ([id]),
	[id_group] int IDENTITY(1,1) primary key--uniqueidentifier DEFAULT NEWSEQUENTIALID() Primary key
	)
	go
	CREATE TABLE [dim_good_groups]
	(
	[id_type_group] int, 
	[name_type_group] nvarchar(max),	
	[id_group] int, 
	[name_group] nvarchar(max), 
	[id_goods] int /*REFERENCES goods([id])*/, 
	[name_goods] nvarchar(max),
	[id_key] bigint
	--CONSTRAINT [DOCUMENT2_PK] PRIMARY KEY CLUSTERED ([id_type_group] ASC, [id_group] ASC, [id_goods] ASC))
	)
	go
	

  SET IDENTITY_INSERT dbo.[dim_goods_parent] OFF;  
  GO  

  INSERT INTO dim_goods_parent ([id], [name], [groups])
  SELECT id, name, CAST(value as int)
  FROM goods
  CROSS APPLY string_split(group_ids, ',')

  INSERT INTO dim_good_groups ([id_type_group], [name_type_group], [id_group], [name_group], [id_goods], [name_goods],[id_key])
  SELECT a.[id], a.name, b.id, b.name, c.id, c.name, CAST((a.id +''+ b.id+''+c.id) as bigint)
  FROM [BaseOne].[dbo].[good_groups] as a
  inner join [good_groups] as b ON b.parent_id = a.id 
  inner join [dim_goods_parent] as c ON c.groups = b.id
  ORDER BY a.id, b.id, c.id

  DROP TABLE [dim_goods_parent]
	go




	create view dbo.Good_Dimensions

as

select    P0.id as Level0ID,
 P0.[name] as Level0Name,
 coalesce(P1.id, P0.id) as Level1ID,
 P1.[name] as Level1Name,
 coalesce(P2.id, P1.id, P0.id) as Level2ID,
 P2.[name] as Level2Name,
 CAST((P2.id+''+P1.id+''+P0.id) as bigint) as [key] 
 

from    good_groups P0
INNER JOIN    good_groups P1
 on        P0.id = P1.parent_id
INNER JOIN    dim_goods_parent P2
 on        P1.id = P2.groups



 ---DATE DIM

 DECLARE @StartDate  date = '20100101';

DECLARE @CutoffDate date = DATEADD(DAY, -1, DATEADD(YEAR, 30, @StartDate));

;WITH seq(n) AS 
(
  SELECT 0 UNION ALL SELECT n + 1 FROM seq
  WHERE n < DATEDIFF(DAY, @StartDate, @CutoffDate)
),
d(d) AS 
(
  SELECT DATEADD(DAY, n, @StartDate) FROM seq
),
src AS
(
  SELECT
    TheDate         = CONVERT(date, d),
    TheDay          = DATEPART(DAY,       d),
    TheDayName      = DATENAME(WEEKDAY,   d),
    TheWeek         = DATEPART(WEEK,      d),
    TheISOWeek      = DATEPART(ISO_WEEK,  d),
    TheDayOfWeek    = DATEPART(WEEKDAY,   d),
    TheMonth        = DATEPART(MONTH,     d),
    TheMonthName    = DATENAME(MONTH,     d),
	TheSemester     = ((DATEPART(quarter,Convert(date,d))-1)/2)+1,
    TheQuarter      = DATEPART(Quarter,   d),
    TheYear         = DATEPART(YEAR,      d),
	FiscalYear      = 1 + year(dateadd(month, -3, TheDate)),
    TheFirstOfMonth = DATEFROMPARTS(YEAR(d), MONTH(d), 1),
    TheLastOfYear   = DATEFROMPARTS(YEAR(d), 12, 31),
    TheDayOfYear    = DATEPART(DAYOFYEAR, d)
  FROM d
),
dim AS
(
  SELECT
    TheDate, 
    TheDay,
    TheDaySuffix        = CONVERT(char(2), CASE WHEN TheDay / 10 = 1 THEN 'th' ELSE 
                            CASE RIGHT(TheDay, 1) WHEN '1' THEN 'st' WHEN '2' THEN 'nd' 
                            WHEN '3' THEN 'rd' ELSE 'th' END END),
    TheDayName,
    TheDayOfWeek,
    TheDayOfWeekInMonth = CONVERT(tinyint, ROW_NUMBER() OVER 
                            (PARTITION BY TheFirstOfMonth, TheDayOfWeek ORDER BY TheDate)),
    TheDayOfYear,
    IsWeekend           = CASE WHEN TheDayOfWeek IN (CASE @@DATEFIRST WHEN 1 THEN 6 WHEN 7 THEN 1 END,7) 
                            THEN 1 ELSE 0 END,
    TheWeek,
    TheISOweek,
    TheFirstOfWeek      = DATEADD(DAY, 1 - TheDayOfWeek, TheDate),
    TheLastOfWeek       = DATEADD(DAY, 6, DATEADD(DAY, 1 - TheDayOfWeek, TheDate)),
    TheWeekOfMonth      = CONVERT(tinyint, DENSE_RANK() OVER 
                            (PARTITION BY TheYear, TheMonth ORDER BY TheWeek)),
    TheMonth,
    TheMonthName,
    TheFirstOfMonth,
    TheLastOfMonth      = MAX(TheDate) OVER (PARTITION BY TheYear, TheMonth),
    TheFirstOfNextMonth = DATEADD(MONTH, 1, TheFirstOfMonth),
    TheLastOfNextMonth  = DATEADD(DAY, -1, DATEADD(MONTH, 2, TheFirstOfMonth)),
    TheSemester,
	TheQuarter,
    TheFirstOfQuarter   = MIN(TheDate) OVER (PARTITION BY TheYear, TheQuarter),
    TheLastOfQuarter    = MAX(TheDate) OVER (PARTITION BY TheYear, TheQuarter),
    TheYear,
	FiscalYear,
    TheISOYear          = TheYear - CASE WHEN TheMonth = 1 AND TheISOWeek > 51 THEN 1 
                            WHEN TheMonth = 12 AND TheISOWeek = 1  THEN -1 ELSE 0 END,      
    TheFirstOfYear      = DATEFROMPARTS(TheYear, 1,  1),
    TheLastOfYear,
    IsLeapYear          = CONVERT(bit, CASE WHEN (TheYear % 400 = 0) 
                            OR (TheYear % 4 = 0 AND TheYear % 100 <> 0) 
                            THEN 1 ELSE 0 END),
    Has53Weeks          = CASE WHEN DATEPART(ISO_WEEK, TheLastOfYear) = 53 THEN 1 ELSE 0 END,
    Has53ISOWeeks       = CASE WHEN DATEPART(WEEK,     TheLastOfYear) = 53 THEN 1 ELSE 0 END,
    MMYYYY              = CONVERT(char(2), CONVERT(char(8), TheDate, 101))
                          + CONVERT(char(4), TheYear),
    Style101            = CONVERT(char(10), TheDate, 101),
    Style103            = CONVERT(char(10), TheDate, 103),
    Style112            = CONVERT(char(8),  TheDate, 112),
    Style120            = CONVERT(char(10), TheDate, 120)
  FROM src
)
SELECT * INTO dbo.dim_date FROM dim
  ORDER BY TheDate
  OPTION (MAXRECURSION 0);

  CREATE UNIQUE CLUSTERED INDEX PK_DateDimension ON dbo.dim_date(TheDate);

