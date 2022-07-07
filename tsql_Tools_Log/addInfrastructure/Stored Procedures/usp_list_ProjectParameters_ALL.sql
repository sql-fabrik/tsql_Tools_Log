
CREATE PROC [addInfrastructure].[usp_list_ProjectParameters_ALL]
                               @pSSIS_Folder_name   sysname    
                             , @pSSIS_Project_name  sysname 
AS
BEGIN

select fo.name      as 'folder_name'
     , pr.name      as 'project_name'
--   , op.object_type  -- = 30  fix
     , op.object_name  as 'package_name'
     , op.parameter_name
     , op.data_type
     , op.design_default_value
from   SSISDB.catalog.folders fo
join   SSISDB.catalog.projects pr
on     fo.folder_id = pr.folder_id
join   SSISDB.catalog.object_parameters op
on     pr.project_id = op.project_id
where  fo.name           like @pSSIS_Folder_name
  and  pr.name           like @pSSIS_Project_name
  and  op.parameter_name not like 'CM%'
order  by folder_name
     , project_name
     , package_name
     , parameter_name

END  -- end PROC 