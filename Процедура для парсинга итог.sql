
CREATE PROCEDURE Insert_Update_Region
( @file_path varchar(max) )
AS
BEGIN
    BEGIN TRANSACTION
    BEGIN TRY

	DECLARE @x xml

    DECLARE @cmd varchar(300)
    SET @cmd= 'SELECT @x=P FROM OPENROWSET (BULK N' + '''' + @file_path + '''' + ',' + ' SINGLE_BLOB, CODEPAGE=' + '''' + '1251' + '''' + ') AS Product(P);'
    SELECT @cmd
    EXEC @cmd


    --    DECLARE @doc nvarchar(1000);
    --DECLARE @xmlDoc integer;
    
	DECLARE @hdoc int

    EXEC sp_xml_preparedocument @hdoc OUTPUT, @x
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
					created_date datetime,
					last_update_date datetime,
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
    ROLLBACK
END CATCH
END