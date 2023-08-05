CREATE INDEX i1 ON [lasmart_fact_total_month_balance] ([date_final]);
CREATE CLUSTERED INDEX i2 ON [lasmart_dim_date] ([did]);

CREATE INDEX i3 ON [lasmart_v_fact_movement] ([dt]);  --Cannot create index on view 'lasmart_v_fact_movement' because the view is not schema bound.

CREATE INDEX i4 ON [lasmart_dim_goods] ([good_id]);
CREATE INDEX i5 ON [lasmart_dim_stores] ([store_id]);
CREATE CLUSTERED INDEX i6 ON [dbo].[lasmart_fact_plan_sales] ([dt]);
