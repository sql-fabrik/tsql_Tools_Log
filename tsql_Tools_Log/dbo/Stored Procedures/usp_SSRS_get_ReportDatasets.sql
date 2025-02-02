


CREATE PROC [dbo].[usp_SSRS_get_ReportDatasets]
AS 
BEGIN
/* --  https://gallery.technet.microsoft.com/scriptcenter/42440a6b-c5b1-4acc-9632-d608d1c40a5c  */

Declare @Namespace nvarchar(800)
      , @sqlCmd    nvarchar(max)
;
WITH 
tmp AS 
(
  SELECT TOP(1)
	     CONVERT(NVARCHAR(MAX),CONVERT(XML,CONVERT(VARBINARY(MAX),c.Content)))                       as 'CatContent'
       , CHARINDEX('xmlns="',CONVERT(NVARCHAR(MAX),CONVERT(XML,CONVERT(VARBINARY(MAX),c.Content))))  as 'CIndex'
  FROM   ReportServer.dbo.Catalog c
  WHERE  c.Content is not null
    and  c.Type = 2
)
SELECT @Namespace= SUBSTRING( CatContent, CIndex, CHARINDEX('"', CatContent, CIndex+7) - CIndex )
FROM   tmp;

SELECT @Namespace = REPLACE( @Namespace,'xmlns="','') + '';

----
SELECT @sqlCmd = '
WITH 
XMLNAMESPACES ( DEFAULT ''' + @Namespace +''', ''http://schemas.microsoft.com/SQLServer/reporting/reportdesigner'' AS rd )
SELECT name                                                                       as ReportName        
     , x.value(''(@Name)[1]''                              , ''VARCHAR(250)'' )   as DataSourceName    
     , x.value(''(ConnectionProperties/DataProvider)[1]''  , ''VARCHAR(250)'' )	  as DataProvider      
     , x.value(''(ConnectionProperties/ConnectString)[1]'' , ''VARCHAR(250)'' )   as ConnectionString  
FROM (  
  SELECT C.Name,CONVERT(XML,CONVERT(VARBINARY(MAX),C.Content)) AS reportXML
  FROM   ReportServer.dbo.Catalog c
  WHERE  c.Content is not null
    AND  c.Type  = 2
) a
CROSS APPLY reportXML.nodes(''/Report/DataSources/DataSource'') r ( x )
ORDER BY name ;';

EXEC sp_executesql @sqlCmd

END  -- end Proc