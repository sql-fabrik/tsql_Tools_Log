
CREATE PROC [dbo].[usp_SSRS_get_ReportDetails]
AS
BEGIN

;
--data sources and shared datasets.
WITH 
ItemContentBinaries as
(
  SELECT ItemID
       , Name
       , Type
       , CASE Type
            WHEN 2 THEN 'Report'
            WHEN 5 THEN 'DataSource'
            WHEN 7 THEN 'ReportPart'
            WHEN 8 THEN 'SharedDataset'
            ELSE 'Other'
         END                             as 'Type_Desc'
       , CONVERT(varbinary(max),Content) as 'Content'
  FROM   ReportServer.dbo.Catalog
  WHERE  Type IN (2,5,7,8) 
    ------WHEN 1 THEN 'Folder'
    ------WHEN 2 THEN 'Report'
    ------WHEN 3 THEN 'File'
    ------WHEN 4 THEN 'Linked Report'
    ------WHEN 5 THEN 'Data Source'
    ------WHEN 6 THEN 'Report Model'
    ------WHEN 7 THEN 'Report Part'
    ------WHEN 8 THEN 'Shared Data Set'
    ------WHEN 9 THEN 'Image'
) ,
----strips off the BOM (ByteOrderMark) if it exists...
ItemContentNoBOM AS
(
  SELECT ItemID
       , Name
       , [Type]
       , [Type_Desc]
       , CASE
            WHEN LEFT(Content,3) = 0xEFBBBF THEN CAST( SUBSTRING(Content,4,LEN(Content)) as xml )
            ELSE Content
         END                  as 'Content'
  FROM   ItemContentBinaries
) ,
----
ItemContentXML as
(
  SELECT ItemID
       , Name
       , [Type]
       , [Type_Desc]
       , CAST( Content as xml ) as 'ContentXML'
  FROM   ItemContentNoBOM
)
----
SELECT ItemID
     , Name   as 'ReportName'
     , [Type]
     , [Type_Desc]
     , ContentXML
     , ISNULL(Query.value('(./*:CommandType/text())[1]' , 'nvarchar(1024)'),'Query') as 'CommandType'
     ,        Query.value('(./*:CommandText/text())[1]' , 'nvarchar(max)' )          as 'CommandText'
FROM   ItemContentXML
--Get all the Query elements (The "*:" ignores any xml namespaces)
CROSS APPLY ItemContentXML.ContentXML.nodes('//*:Query') Queries(Query)

END  -- end PROC