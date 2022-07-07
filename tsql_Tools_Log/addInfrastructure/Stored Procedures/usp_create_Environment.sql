
CREATE PROC [addInfrastructure].[usp_create_Environment]
                               @keep_force                     sysname = 'keep_current'      -- [ keep_current | force_new ]
                             , @pSSIS_Folder_name              sysname       
                             , @pSSIS_Environment_name         sysname       
                             , @pSSIS_Environment_description  nvarchar(200) 
                             , @pXML_Environment_Config        xml
AS
BEGIN

Set NoCount ON;

IF ( @keep_force = 'force_new')
BEGIN
print 'parameter: force_new'

-- delete prev.environment
IF EXISTS
 ( SELECT * 
   FROM   SSISDB.catalog.folders fo  
   join   SSISDB.catalog.environments en
   ON     fo.folder_id = en.folder_id
   WHERE  fo.name = @pSSIS_Folder_name 
     and  en.name = @pSSIS_Environment_name )
exec SSISDB.catalog.delete_environment @folder_name             = @pSSIS_Folder_name
                                     , @environment_name        = @pSSIS_Environment_name

-- create new environment
EXEC SSISDB.catalog.create_environment @environment_name        = @pSSIS_Environment_name
                                     , @environment_description = @pSSIS_Environment_description
                                     , @folder_name             = @pSSIS_Folder_name

-- provide config-Values 
Declare @idoc int
Exec sp_xml_preparedocument @idoc OUTPUT, @pXML_Environment_Config

Declare @tbl_Config_Values TABLE(
          ID               int Identity(1,1) primary key
        , [variable_name]  sysname    
        , [value]          sql_variant
        , [data_type]      sysname    
        )
-- here...
INSERT into @tbl_Config_Values
     ( [variable_name] , [value] , [data_type]  )
SELECT parameter_name  as 'variable_name'
     , configValue     as 'value'
     , data_type       as 'data_type'
FROM   OpenXML( @idoc, 'allValues/keyValue', 1 )
WITH  ( parameter_name   sysname
      , data_type        sysname 
      , configValue      sysname
      )

Exec sp_xml_removedocument @idoc

-- min/ max WHILE 
Declare @min  int = ( select MIN(ID) from @tbl_Config_Values )
      , @max  int = ( select MAX(ID) from @tbl_Config_Values )

Declare @vVar_Name  sysname    
      , @vValue     sql_variant
      , @vData_Type sysname    

WHILE @min <= @max
BEGIN
    Set @vVar_Name   = ( select [variable_name] from @tbl_Config_Values where ID = @min )
    Set @vValue      = ( select [value]         from @tbl_Config_Values where ID = @min )
    Set @vData_Type  = ( select [data_type]     from @tbl_Config_Values where ID = @min )

    EXEC SSISDB.catalog.create_environment_variable @variable_name    = @vVar_Name
                                                  , @sensitive        = False     
                                                  , @description      = N'var.description'
                                                  , @environment_name = @pSSIS_Environment_name
                                                  , @folder_name      = @pSSIS_Folder_name
                                                  , @value            = @vValue    
                                                  , @data_type        = @vData_Type
    ----
    Set @min = @min + 1
END  -- end WHILE

END -- IF ( @keep_force = 'force_new')
--------------------------------------
IF ( @keep_force = 'keep_current' )
BEGIN
    print 'parameter: keep_current'
END

END -- end PROC