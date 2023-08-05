CREATE TABLE #tb_test
(
store_id integer,
did int,
persent float
);

BULK
INSERT #tb_test
FROM 'C:\Lasmart\Nekhvyadovich\Plan2018_2019.txt'
WITH
(
FIRSTROW = 2,
FIELDTERMINATOR = ';',
ROWTERMINATOR = '\n'
)
go

SELECT * FROM #tb_test
--group by store_id
--order by store_id

IF OBJECT_ID(N'tempdb..#tb_test', N'U') IS NOT NULL
	DROP TABLE #tb_test
