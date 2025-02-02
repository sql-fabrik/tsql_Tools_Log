CREATE PROC [dbo].[usp_SSRS_get_ReportParameters]
AS
BEGIN

WITH 
SubQuery as
(  
  SELECT c.Name
       , CAST( c.Parameter as xml ) as ParameterXML
  FROM   ReportServer.dbo.Catalog c
  WHERE  c.Content is not null
    AND  c.Type  = 2  ---- Report
) 
SELECT Name                                                    as 'Reportname'
     , ParValue.value( 'Name[1]'         , 'VARCHAR(250)' )    as 'ParameterName' 
     , ParValue.value( 'Type[1]'         , 'VARCHAR(250)' )    as 'Type' 
     , ParValue.value( 'Nullable[1]'     , 'VARCHAR(250)' )    as 'Nullable' 
     , ParValue.value( 'AllowBlank[1]'   , 'VARCHAR(250)' )    as 'AllowBlank' 
     , ParValue.value( 'MultiValue[1]'   , 'VARCHAR(250)' )    as 'MultiValue' 
     , ParValue.value( 'UsedInQuery[1]'  , 'VARCHAR(250)' )    as 'UsedInQuery'
     , ParValue.value( 'Prompt[1]'       , 'VARCHAR(250)' )    as 'Prompt'
     , ParValue.value( 'DynamicPrompt[1]', 'VARCHAR(250)' )    as 'DynamicPrompt'
     , ParValue.value( 'PromptUser[1]'   , 'VARCHAR(250)' )    as 'PromptUser' 
     , ParValue.value( 'State[1]'        , 'VARCHAR(250)' )    as 'State' 
FROM   SubQuery s
CROSS  APPLY ParameterXML.nodes('//Parameters/Parameter') p ( ParValue );

END  -- end PROC