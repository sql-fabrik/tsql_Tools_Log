
CREATE PROC addInfrastructure.usp_deploy_SSIS_Project
                               @pFile_Folder        nvarchar(200) 
                             , @pFile_Name          nvarchar(200) 
                             , @pSSIS_Folder_name   sysname       
                             , @pSSIS_Project_name  sysname       
AS
BEGIN
----
-- refer "bulk-insert" Permissions

---- tech variables
Declare @sqlCmd   nvarchar(4000)    -- SQLcommand
      , @parDef   nvarchar(1000)    -- ParameterDefinition

---- return variables
DECLARE @ProjectBinary as varbinary(max)

---- internal sqlCommand variables
Set @parDef = N' @dsqlProjectBinary   varbinary(max) OUTPUT '

Set @sqlCmd = N'
Set @dsqlProjectBinary =
( SELECT * FROM OPENROWSET( BULK ''' + @pFile_Folder + @pFile_Name + '''
                          , SINGLE_BLOB ) as BinaryData )  '

exec sp_executesql @sqlCmd
                 , @parDef
                 , @dsqlProjectBinary = @ProjectBinary  OUTPUT
----
    
Exec SSISDB.catalog.deploy_project @folder_name    = @pSSIS_Folder_name
                                 , @project_name   = @pSSIS_Project_name
                                 , @project_stream = @ProjectBinary

END  -- end PROC 