
CREATE TABLE lasmart_fact_balance_report(
[did] int,
[store_name] nvarchar(500),
[goodgroups_name] nvarchar(500),
[goods_name] nvarchar(500),
[quantity] money,
[Cost] money
)
go

ALTER PROCEDURE [dbo].[p_lasmart_fact_balance_report] (@dt int, @id_store int)
	
AS
SET NOCOUNT ON;
BEGIN
/*
declare @dt_min int
SET @dt_min = (SELECT min(dt) FROM [OrganicNeva_Nekhvyadovich].[dbo].[lasmart_v_fact_movement])
*/

/*
Входные параметры Дата, Идентификатор магазина. 
Возвращаемые колокнки - Название магазина, Группа товаров, Номенклатура, Остаток шт, Остаток руб
*/

IF @dt not in (SELECT [did] FROM lasmart_fact_balance_report)
BEGIN

--INSERT INTO lasmart_fact_balance_report ([did], [store_name], [goodgroups_name], [goods_name], [quantity], [Cost])
SELECT t.[date_final], s.[name], gg.[name], g.[name], t.[quantity], t.[Cost] 
FROM [dbo].[lasmart_fact_month_balance] as t
  INNER JOIN [dbo].[lasmart_dim_stores] as s ON t.id_store = s.store_id
  INNER JOIN [dbo].[lasmart_dim_goods] as g ON t.id_goods = g.good_id
  INNER JOIN [dbo].[lasmart_dim_goodgroups] as gg ON g.group_id = gg.goodgroup_id
WHERE t.[date_final] = @dt and t.[id_store] = @id_store
END
ELSE
RETURN


END
go

exec [p_lasmart_fact_balance_report] @dt = 20190801, @id_store =8