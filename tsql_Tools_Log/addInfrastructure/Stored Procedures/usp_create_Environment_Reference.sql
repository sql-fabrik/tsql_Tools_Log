CREATE PROC [addInfrastructure].[usp_create_Environment_Reference]
                               @pSSIS_Folder_name       sysname  
							 , @pSSIS_Project_name      sysname  
							 , @pEnvironment_name		sysname  

AS
BEGIN
--  3 steps:
--  del_Environment_Reference
--  create_Environment_Reference
--  set_object_parameter_value


Declare @tbl_del_Environment_Reference TABLE( 
          ID               int Identity(1,1) primary key
        , reference_id     bigint
        , environment_name sysname
        )

Insert into @tbl_del_Environment_Reference
     ( reference_id, environment_name ) 
select er.reference_id
--   , fo.folder_id
--   , fo.name    as 'folder_name'
--   , pr.project_id
--   , pr.name    as 'project_name'
	 , er.environment_name
from   SSISDB.catalog.folders fo
join   SSISDB.catalog.projects pr
on     fo.folder_id = pr.folder_id
join   SSISDB.catalog.environment_references er
on     pr.project_id = er.project_id
where  fo.name             like @pSSIS_Folder_name
  and  pr.name             like @pSSIS_Project_name
  and  er.environment_name like @pEnvironment_name

-- min/ max WHILE 
Declare @min  int = ( select MIN(ID) from @tbl_del_Environment_Reference ) 
      , @max  int = ( select MAX(ID) from @tbl_del_Environment_Reference )
Declare @ref  int

WHILE @min <= @max
BEGIN
    Set @ref = ( select reference_id from @tbl_del_Environment_Reference where ID = @min )

    exec SSISDB.catalog.delete_environment_reference @reference_id = @ref 
    ----
    Set @min = @min + 1
END  -- end WHILE
---------------------------------------------------------------------	  

Declare @tbl_create_Environment_Reference TABLE( 
          ID               int Identity(1,1) primary key
        , folder_name      sysname
        , project_name     sysname
        )

Insert into @tbl_create_Environment_Reference
     ( folder_name, project_name )
select fo.name  as 'folder_name'
     , pr.name  as 'project_name'
from   SSISDB.catalog.folders fo
join   SSISDB.catalog.projects pr
on     fo.folder_id = pr.folder_id
where  fo.name  like @pSSIS_Folder_name
  and  pr.name  like @pSSIS_Project_name
order  by fo.name
     , pr.name

-- min/ max WHILE 
Set @min = ( select MIN(ID) from @tbl_create_Environment_Reference ) 
Set @max = ( select MAX(ID) from @tbl_create_Environment_Reference )
Declare @project_name sysname
      , @reference_id bigint

WHILE @min <= @max
BEGIN
    Set @project_name = ( select project_name from @tbl_create_Environment_Reference where ID = @min )

    EXEC SSISDB.catalog.create_environment_reference @environment_name   = @pEnvironment_name
                                                   , @folder_name        = @pSSIS_Folder_name
                                                   , @project_name       = @project_name  -- <<
                                                   , @reference_type     = R  -- Relative reference
                                                   , @reference_id       = @reference_id OUTPUT    
    ----
    Set @min = @min + 1
END  -- end WHILE
---------------------------------------------------------------------

Declare @tbl_set_object_parameter_value TABLE(
          ID                    int Identity(1,1) primary key
        , folder_name           sysname
        , project_name          sysname
        , package_name          sysname
        , parameter_name        sysname
        , environment_variable  sysname
        )

Insert into @tbl_set_object_parameter_value
     (   folder_name,   project_name,   package_name,   parameter_name,   environment_variable )
SELECT P.folder_name, P.project_name, P.package_name, P.parameter_name, E.environment_variable 
FROM ( select fo.name      as 'folder_name'
            , pr.name      as 'project_name'
       --   , op.object_type  -- = 30  fix
            , op.object_name  as 'package_name'
            , op.parameter_name
       from   SSISDB.catalog.folders fo
	   join   SSISDB.catalog.projects pr
	   on     fo.folder_id = pr.folder_id
       join   SSISDB.catalog.object_parameters op
       on     pr.project_id = op.project_id
       where  fo.name               like @pSSIS_Folder_name
         and  pr.name               like @pSSIS_Project_name
         and  op.parameter_name not like 'CM.%'
     ) P
join 
     (
       select en.environment_id
            , en.name    as 'environment_name'
            , ev.name    as 'environment_variable'
            , ev.value   as 'environment_value'
            , ev.type    as 'environment_variable_type'
       from   SSISDB.catalog.folders fo
	   join   SSISDB.catalog.environments en
	   on     fo.folder_id = en.folder_id
       join   SSISDB.catalog.environment_variables ev
       on     en.environment_id = ev.environment_id
       where  fo.name   like @pSSIS_Folder_name
	     and  en.name   like @pEnvironment_name
     ) E
ON     P.parameter_name = E.environment_variable
ORDER  by P.project_name, P.package_name, P.parameter_name

---- min/ max WHILE 
Set @min = ( select MIN(ID) from @tbl_set_object_parameter_value ) 
Set @max = ( select MAX(ID) from @tbl_set_object_parameter_value )

--      @project_name          sysname   >> already exists
Declare @package_name          sysname
      , @parameter_name        sysname
      , @environment_variable  sysname

WHILE @min <= @max
BEGIN
    Set @project_name         = ( select project_name         from @tbl_set_object_parameter_value where ID = @min )
    Set @package_name         = ( select package_name         from @tbl_set_object_parameter_value where ID = @min )
    Set @parameter_name       = ( select parameter_name       from @tbl_set_object_parameter_value where ID = @min )
    Set @environment_variable = ( select environment_variable from @tbl_set_object_parameter_value where ID = @min )


EXEC SSISDB.catalog.set_object_parameter_value @object_type     = 30  -- for package parameter
                                             , @folder_name     = @pSSIS_Folder_name
                                             , @project_name    = @project_name
                                             , @object_name     = @package_name
                                             , @parameter_name  = @parameter_name
                                             , @parameter_value = @environment_variable
                                             , @value_type      = R --!!
---- !! R to indicate that parameter_value is a referenced value and has been set to the name of an environment variable 
    ----
    Set @min = @min + 1
END  -- end WHILE

END -- end PROC