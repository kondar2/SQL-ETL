USE [OrganicNeva_Nekhvyadovich]
GO
/****** Object:  StoredProcedure [dbo].[p_lasmart_fact_except_movement]    Script Date: 23.11.2020 13:47:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[p_lasmart_fact_except_movement] (@date_from int, @date_to int)
	
AS
SET NOCOUNT ON;
BEGIN
/*
Сверку ХД осуществлять с таблицей [lasmart_v_fact_movement_FROM_OLAP] за период с 20190601 по 20190831.
По [OperTypeID] = "Приход", "Продажа" и "Списание" в шт. и руб. в разрезах месяц и аптека.
*/
--Пример запуска
--exec [dbo].[p_lasmart_fact_except_movement] @date_from = 20190601, @date_to = 20190831

DECLARE 
	@name varchar(500) = '[' + OBJECT_SCHEMA_NAME(@@PROCID) + '].[' + OBJECT_NAME(@@PROCID) + ']',
	@description varchar(500) = '[dbo].[lasmart_fact_discrepancy_OLAP_DWH]',
	@input_parametrs varchar(500) = N'no_parametrs'

begin try

EXEC [oth].[fill_sup_log] @name = @name, @state_name = 'start', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs

truncate table lasmart_fact_discrepancy_OLAP_DWH

INSERT INTO lasmart_fact_discrepancy_OLAP_DWH(
[dm],
[name],
[order_type],
[dwh_kol],
[dwh_sum],
[olap_kol],
[olap_sum])

SELECT [dm] as 'Месяц',
       s.[name] as 'Магазин',
	   [order_type],
       sum([dwh_kol]) as 'DWH Количество, шт.',
       sum([dwh_sum]) as 'DWH Сумма, руб.',
	   sum([olap_kol]) as 'OLAP Количество, шт.',
	   sum([olap_sum]) as 'OLAP Сумма, руб.'
FROM(

SELECT d.m as [dm],
       m.[id_store] as [store_id],
	   m.[OperTypeID] as [order_type],
       sum(m.[quantity]) as [dwh_kol],
       sum(m.[Cost]) as [dwh_sum],
	   0 as [olap_kol],
	   0 as [olap_sum]
FROM [dbo].[lasmart_v_fact_movement] as m
left join [dbo].[lasmart_dim_date] as d
on m.dt = d.did
where (m.[dt] between 20190601 and 20190831) and 
      (m.[OperTypeID] = 'Приход' or
	  m.[OperTypeID] = 'Продажа' or
	  m.[OperTypeID] = 'Списание')
group by d.m,
m.[id_store],
[OperTypeID]
EXCEPT
SELECT d.m as [dm],
       m.[id_store] as [store_id],
	   m.[OperTypeID] as [order_type],
       sum(m.[quantity]) as [dwh_kol],
       sum(m.[Cost]) as [dwh_sum],
	   0 as [olap_kol],
	   0 as [olap_sum]
FROM [dbo].[lasmart_v_fact_movement_FROM_OLAP] as m
left join [dbo].[lasmart_dim_date] as d
on m.dt = d.did
where (m.[dt] between 20190601 and 20190831) and 
      (m.[OperTypeID] = 'Приход' or
	  m.[OperTypeID] = 'Продажа' or
	  m.[OperTypeID] = 'Списание')
group by d.m,
m.[id_store],
[OperTypeID]

UNION ALL

SELECT d.m as [dm],
       m.[id_store] as [store_id],
	   m.[OperTypeID] as [order_type],
	   0 as [dwh_kol],
	   0 as [dwh_sum],
       sum(m.[quantity]) as [olap_kol],
       sum(m.[Cost]) as [olap_sum]
FROM [dbo].[lasmart_v_fact_movement_FROM_OLAP] as m
left join [dbo].[lasmart_dim_date] as d
on m.dt = d.did
where (m.[dt] between 20190601 and 20190831) and 
      (m.[OperTypeID] = 'Приход' or
	  m.[OperTypeID] = 'Продажа' or
	  m.[OperTypeID] = 'Списание')
group by d.m,
m.[id_store],
[OperTypeID]
EXCEPT
SELECT d.m as [dm],
       m.[id_store] as [store_id],
	   m.[OperTypeID] as [order_type],
	   0 as [dwh_kol],
	   0 as [dwh_sum],
       sum(m.[quantity]) as [olap_kol],
       sum(m.[Cost]) as [olap_sum]
FROM [dbo].[lasmart_v_fact_movement] as m
left join [dbo].[lasmart_dim_date] as d
on m.dt = d.did
where (m.[dt] between 20190601 and 20190831) and 
      (m.[OperTypeID] = 'Приход' or
	  m.[OperTypeID] = 'Продажа' or
	  m.[OperTypeID] = 'Списание')
group by d.m,
m.[id_store],
[OperTypeID]
) as [except]
left join lasmart_dim_stores as s
on [except].store_id = s.store_id
GROUP BY [dm],
         s.[name],
	     [order_type]


EXEC [oth].[fill_SUP_LOG] @name = @name, @state_name = 'finish', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs

 
end try
begin catch
	EXEC [oth].[fill_SUP_LOG] @name = @name, @state_name = 'error', @sp_id = @@SPID, @description = @description, @input_parametrs = @input_parametrs

	RETURN
end catch

END