
CREATE PROC [dbo].[usp_SSRS_get_Reports]
AS
BEGIN

SELECT CASE 
          WHEN Path = ''  THEN  'Root'
          ELSE Path
       END    as 'Path'
     , Name   as 'Foldername_or_Reportname'
     , ItemID
     , ParentID
     , CreationDate
     , ModifiedDate
FROM   ReportServer.dbo.Catalog

END  -- end PROC