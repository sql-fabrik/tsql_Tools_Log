

CREATE PROC addInfrastructure.usp_create_Environment__custom
AS
BEGIN

---- SSIS  create Environment
---- SSIS  Environment-Variables
IF EXISTS( SELECT *
           FROM   SSISDB.catalog.folders fo
           join   SSISDB.catalog.environments en
           ON     fo.folder_id = en.folder_id
           WHERE  en.name = 'env_Prod' )
EXEC [SSISDB].[catalog].[delete_environment] @environment_name=N'env_Prod', @folder_name=N'OXAION'
;

EXEC [SSISDB].[catalog].[create_environment] 
     @environment_name=N'env_Prod'
   , @environment_description=N''
   , @folder_name=N'OXAION'
;
----

DECLARE @varSourceDB    sql_variant = N'sourceDB'
      , @varSourceSrv   sql_variant = N'sourceSrv\BI'
      , @varTargetDB    sql_variant = N'targetDB'
      , @varTargetSrv   sql_variant = N'sourceSrv\BI'
      , @varToolsDB     sql_variant = N'Tools_Log'
      , @varToolsSrv    sql_variant = N'sourceSrv\BI'


EXEC [SSISDB].[catalog].[create_environment_variable] 
     @variable_name=N'pSourceDB', @sensitive=False, @description=N''
   , @environment_name=N'env_Prod'
   , @folder_name=N'OXAION', @value=@varSourceDB, @data_type=N'String'
----
EXEC [SSISDB].[catalog].[create_environment_variable] 
     @variable_name=N'pSourceServername', @sensitive=False, @description=N''
   , @environment_name=N'env_Prod'
   , @folder_name=N'OXAION', @value=@varSourceSrv, @data_type=N'String'
----
EXEC [SSISDB].[catalog].[create_environment_variable] 
     @variable_name=N'pTargetDB', @sensitive=False, @description=N''
   , @environment_name=N'env_Prod'
   , @folder_name=N'OXAION', @value=@varTargetDB, @data_type=N'String'
----
EXEC [SSISDB].[catalog].[create_environment_variable] 
     @variable_name=N'pTargetServername', @sensitive=False, @description=N''
   , @environment_name=N'env_Prod'
   , @folder_name=N'OXAION', @value=@varTargetSrv, @data_type=N'String'
----
EXEC [SSISDB].[catalog].[create_environment_variable] 
     @variable_name=N'pToolsDB', @sensitive=False, @description=N''
   , @environment_name=N'env_Prod'
   , @folder_name=N'OXAION', @value=@varToolsDB, @data_type=N'String'
----
EXEC [SSISDB].[catalog].[create_environment_variable] 
     @variable_name=N'pToolsServername', @sensitive=False, @description=N''
   , @environment_name=N'env_Prod'
   , @folder_name=N'OXAION', @value=@varToolsSrv, @data_type=N'String'

END  -- end PROC
