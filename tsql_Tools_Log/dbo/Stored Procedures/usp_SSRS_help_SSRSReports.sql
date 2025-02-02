/*
    EXEC sp_HelpSSRSReport 'AP1099VoucherListing';

    https://gallery.technet.microsoft.com/scriptcenter/42440a6b-c5b1-4acc-9632-d608d1c40a5c
*/


CREATE PROC dbo.usp_SSRS_help_SSRSReports
                @ReportName NVARCHAR(850) = 'R01__VB_Kundenumsatz_v2022'
              , @ShowExecutionLog bit = 0
AS 
BEGIN

Declare @Namespace NVARCHAR(500);
Declare @SQL   VARCHAR(max);

WITH X AS (
    SELECT TOP 1 CatContent = CONVERT(NVARCHAR(MAX),CONVERT(XML,CONVERT(VARBINARY(MAX),C.Content)))
        ,CIndex    = CHARINDEX('xmlns="',CONVERT(NVARCHAR(MAX),CONVERT(XML,CONVERT(VARBINARY(MAX),C.Content))))
    FROM [ReportServer].dbo.Catalog C
    WHERE C.Content is not null
    AND C.Type  = 2
)
SELECT @Namespace= SUBSTRING(
                   x.CatContent  
                  ,x.CIndex
                  ,CHARINDEX('"',x.CatContent,x.CIndex+7) - x.CIndex
                )
FROM    X;

SELECT @Namespace = REPLACE(@Namespace,'xmlns="','') + '';

SELECT ReportName = Name,CreatedBy = U.UserName
      ,CreationDate = C.CreationDate
      ,ModifiedBy = UM.UserName
    --  ,ModifiedDate
  FROM [ReportServer].dbo.Catalog C
  JOIN [ReportServer].dbo.Users U
    ON C.CreatedByID = U.UserID
  JOIN [ReportServer].dbo.Users UM
    ON c.ModifiedByID = UM.UserID
 WHERE Name = @ReportName;

----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Get parameters of the report
----------------------------------------------------------------------------------------------------------------------------------------------------------
WITH a AS (  
    SELECT    C.Name,CONVERT(XML,C.Parameter) AS ParameterXML
    FROM    [ReportServer].dbo.Catalog C
    WHERE    C.Content is not null
            AND  C.Type  = 2
            AND  C.Name  =  @ReportName
) 
 SELECT 
        ParameterName = Paravalue.value('Name[1]', 'VARCHAR(250)') 
       , Type = Paravalue.value('Type[1]', 'VARCHAR(250)') 
       , Nullable = Paravalue.value('Nullable[1]', 'VARCHAR(250)') 
       , AllowBlank = Paravalue.value('AllowBlank[1]', 'VARCHAR(250)') 
       , MultiValue = Paravalue.value('MultiValue[1]', 'VARCHAR(250)') 
       , UsedInQuery = Paravalue.value('UsedInQuery[1]', 'VARCHAR(250)') 
       , Prompt = Paravalue.value('Prompt[1]', 'VARCHAR(250)') 
       , DynamicPrompt = Paravalue.value('DynamicPrompt[1]', 'VARCHAR(250)') 
       , PromptUser = Paravalue.value('PromptUser[1]', 'VARCHAR(250)') 
       , State = Paravalue.value('State[1]', 'VARCHAR(250)') 
 FROM a
CROSS APPLY ParameterXML.nodes('//Parameters/Parameter') p ( Paravalue );

----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Get Datasources Associated with the report
----------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT @SQL = 'WITH XMLNAMESPACES ( DEFAULT ''' + @Namespace +''', ''http://schemas.microsoft.com/SQLServer/reporting/reportdesigner'' AS rd )
                SELECT  ReportName         = name
                       ,DataSourceName     = x.value(''(@Name)[1]'', ''VARCHAR(250)'') 
                       ,DataProvider     = x.value(''(ConnectionProperties/DataProvider)[1]'',''VARCHAR(250)'')
                       ,ConnectionString = x.value(''(ConnectionProperties/ConnectString)[1]'',''VARCHAR(250)'')
                  FROM (  SELECT C.Name,CONVERT(XML,CONVERT(VARBINARY(MAX),C.Content)) AS reportXML
                           FROM  [ReportServer].dbo.Catalog C
                          WHERE  C.Content is not null
                            AND  C.Type  = 2
                            AND  C.Name  = ''' + @ReportName + '''
                  ) a
                  CROSS APPLY reportXML.nodes(''/Report/DataSources/DataSource'') r ( x )
                ORDER BY name ;';

EXEC(@SQL);

----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Get Data Sets , Command , Data fields Associated with the report
----------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT @SQL = 'WITH XMLNAMESPACES ( DEFAULT ''' + @Namespace + ''', ''http://schemas.microsoft.com/SQLServer/reporting/reportdesigner'' AS rd )
SELECT  ReportName        = name
       ,DataSetName        = x.value(''(@Name)[1]'', ''VARCHAR(250)'') 
       ,DataSourceName    = x.value(''(Query/DataSourceName)[1]'',''VARCHAR(250)'')
       ,CommandText        = x.value(''(Query/CommandText)[1]'',''VARCHAR(250)'')
       ,Fields            = df.value(''(@Name)[1]'',''VARCHAR(250)'')
       ,DataField        = df.value(''(DataField)[1]'',''VARCHAR(250)'')
       ,DataType        = df.value(''(rd:TypeName)[1]'',''VARCHAR(250)'')
  FROM (  SELECT C.Name,CONVERT(XML,CONVERT(VARBINARY(MAX),C.Content)) AS reportXML
           FROM  [ReportServer].dbo.Catalog C
          WHERE  C.Content is not null
            AND  C.Type = 2
            AND  C.Name = ''' + @ReportName + '''
       ) a
  CROSS APPLY reportXML.nodes(''/Report/DataSets/DataSet'') r ( x )
  CROSS APPLY x.nodes(''Fields/Field'') f(df) 
ORDER BY name';

EXEC(@SQL);

----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Get subscription Associated with the report
----------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT Reportname = c.Name
      ,SubscriptionDesc=su.Description
      ,Subscriptiontype=su.EventType
      ,su.LastStatus
      ,su.LastRunTime
      ,Schedulename=sch.Name
      ,ScheduleType = sch.EventType
      ,ScheduleFrequency =
       CASE sch.RecurrenceType
       WHEN 1 THEN 'Once'
       WHEN 2 THEN 'Hourly'
       WHEN 4 THEN 'Daily/Weekly'
       WHEN 5 THEN 'Monthly'
       END
       ,su.Parameters
  FROM [ReportServer].dbo.Subscriptions su
  JOIN [ReportServer].dbo.Catalog c
    ON su.Report_OID = c.ItemID
  JOIN [ReportServer].dbo.ReportSchedule rsc
    ON rsc.ReportID = c.ItemID
   AND rsc.SubscriptionID = su.SubscriptionID
  JOIN [ReportServer].dbo.Schedule Sch
    ON rsc.ScheduleID = sch.ScheduleID
WHERE c.Name = @ReportName;

----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Get Snapshot associated with the report
----------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT C.Name
      ,H.SnapshotDate
      ,S.Description
      ,ScheduleForSnapshot = ISNULL(Sc.Name,'No Schedule available for Snapshot')
      ,ScheduleType = sc.EventType
       ,ScheduleFrequency =
       CASE sc.RecurrenceType
       WHEN 1 THEN 'Once'
       WHEN 2 THEN 'Hourly'
       WHEN 4 THEN 'Daily/Weekly'
       WHEN 5 THEN 'Monthly'
       END
      ,sc.LastRunTime
      ,sc.LastRunStatus
        ,ScheduleNextRuntime = SC.NextRunTime
        ,S.EffectiveParams
      ,S.QueryParams
  FROM [ReportServer].dbo.History H
  JOIN [ReportServer].dbo.SnapshotData S
    ON H.SnapshotDataID = S.SnapshotDataID
  JOIN [ReportServer].dbo.Catalog c
    ON C.ItemID = H.ReportID
LEFT JOIN [ReportServer].dbo.ReportSchedule Rs
    ON RS.ReportID = H.ReportID
   AND RS.ReportAction = 2
LEFT JOIN [ReportServer].dbo.Schedule Sc
    ON Sc.ScheduleID = rs.ScheduleID
 WHERE C.Name = @ReportName;

 ----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Get Users List having access to reports and tasks they can perform on the report
----------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT C.Name
      ,U.UserName
      ,R.RoleName
      ,R.Description
      ,U.AuthType
  FROM [ReportServer].dbo.Users U
  JOIN [ReportServer].dbo.PolicyUserRole PUR
    ON U.UserID = PUR.UserID
  JOIN [ReportServer].dbo.Policies P
    ON P.PolicyID = PUR.PolicyID
  JOIN [ReportServer].dbo.Roles R
    ON R.RoleID = PUR.RoleID
  JOIN [ReportServer].dbo.Catalog c
    ON C.PolicyID = P.PolicyID
 WHERE c.Name = @ReportName
ORDER BY U.UserName;

----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Execution Log fo the report
----------------------------------------------------------------------------------------------------------------------------------------------------------

--If @ShowExecutionLog = 1
    SELECT C.Name
          ,Case E.Requesttype 
           WHEN 1 THEN 'Subscription' 
           WHEN 0 THEN 'Report Launch'
           ELSE ''
           END
          ,E.TimeStart 
          ,E.TimeProcessing
          ,E.TimeRendering
          ,E.TimeEnd
          ,E.Status
          ,E.InstanceName
          ,E.UserName
     FROM [ReportServer].dbo.ExecutionLog E
     JOIN [ReportServer].dbo.Catalog C
       ON E.ReportID = C.ItemID
    WHERE C.Name = @ReportName
    ORDER BY E.TimeStart DESC;

END  -- end Proc