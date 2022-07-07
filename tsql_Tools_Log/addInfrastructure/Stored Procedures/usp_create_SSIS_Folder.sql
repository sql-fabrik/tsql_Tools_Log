
CREATE PROC addInfrastructure.usp_create_SSIS_Folder
                              @pSSIS_Folder_name         sysname       
                            , @pSSIS_Folder_description  nvarchar(100) 
AS
BEGIN

Declare @Folder_id  bigint

IF NOT EXISTS( select folder_id 
               from   SSISDB.catalog.folders
               where  name = @pSSIS_Folder_name )
BEGIN
    exec  SSISDB.catalog.create_folder @folder_name = @pSSIS_Folder_name

    exec  SSISDB.catalog.set_folder_description @folder_name        = @pSSIS_Folder_name
                                              , @folder_description = @pSSIS_Folder_description 

END  -- end IF 

END  -- end PROC  