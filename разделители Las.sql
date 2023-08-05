IF EXISTS(SELECT * FROM sys.objects WHERE name='pStringToTable' AND TYPE='P') DROP proc  pStringToTable
IF EXISTS(SELECT * FROM sys.objects WHERE name='pGroupSelect'   AND TYPE='P') DROP proc  pGroupSelect
IF EXISTS(SELECT * FROM sys.tables  WHERE name='tGroupProduct'              ) DROP TABLE tGroupProduct
CREATE TABLE tGroupProduct
 (
  Dtm datetime
 ,GroupName nvarchar(255)
 )
GO
INSERT tGroupProduct
              SELECT '20190101', 'Биологически активные добавки'
    UNION ALL SELECT '20190102', 'Косметические средства'
    UNION ALL SELECT '20190102', 'Противозачаточные средства'
    UNION ALL SELECT '20190103', 'Косметические средства'
    UNION ALL SELECT '20190105', 'Биологически активные добавки'
    UNION ALL SELECT '20190102', 'Примочки от прыщей'
 
GO
--Преобразование строки в таблицу
CREATE proc pStringToTable
@nList nvarchar(MAX)
AS SET nocount ON
--
IF ascii(RIGHT(@nList,1))<>44 SET @nList=@nList+CHAR(44)
DECLARE @temp TABLE (GroupName nvarchar(255))
DECLARE @pos INT
DECLARE @len INT SET @len=len(@nList)
while @len>0
 BEGIN
 SET @pos=charindex(CHAR(44),@nList)
 INSERT @temp SELECT LEFT(@nList,@pos-1)
 SET @nList=SUBSTRING(@nList,@pos+1,len(@nList))
 SET @len=len(@nList)
 END
--output result
SELECT * FROM @temp
--
GO
CREATE proc pGroupSelect
 @dBeg datetime
,@dEnd datetime
,@nGrp nvarchar(MAX)
AS SET nocount ON
DECLARE @temp TABLE (GroupName nvarchar(255))
INSERT @temp EXEC pStringToTable @nGrp
--output result
SELECT Dtm, G.GroupName FROM tGroupProduct G JOIN @temp Tmp ON G.GroupName=Tmp.GroupName WHERE Dtm BETWEEN @dBeg AND @dEnd
GO
 
DECLARE @dBeg datetime SET @dBeg='20190101'
DECLARE @dEnd datetime SET @dEnd='20190102'
DECLARE @nGrp nvarchar(MAX) SET @nGrp='Биологически активные добавки,Косметические средства'
EXEC pGroupSelect @dBeg, @dEnd, @nGrp
GO
 
IF EXISTS(SELECT * FROM sys.objects WHERE name='pStringToTable' AND TYPE='P') DROP proc  pStringToTable
IF EXISTS(SELECT * FROM sys.objects WHERE name='pGroupSelect'   AND TYPE='P') DROP proc  pGroupSelect
IF EXISTS(SELECT * FROM sys.tables  WHERE name='tGroupProduct'              ) DROP TABLE tGroupProduct
GO
