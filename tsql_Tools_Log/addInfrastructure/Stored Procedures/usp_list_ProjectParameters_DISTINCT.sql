
CREATE PROC addInfrastructure.usp_list_ProjectParameters_DISTINCT
                               @pSSIS_Folder_name   sysname      
                             , @pSSIS_Project_name  sysname      
AS
BEGIN

SELECT DISTINCT 
       op.parameter_name
     , op.data_type
     , op.design_default_value
FROM   SSISDB.catalog.folders fo
join   SSISDB.catalog.projects pr
ON     fo.folder_id = pr.folder_id
join   SSISDB.catalog.object_parameters op
ON     pr.project_id = op.project_id
WHERE  fo.name           like @pSSIS_Folder_name
  and  pr.name           like @pSSIS_Project_name
  and  op.parameter_name not like 'CM%'
ORDER  by parameter_name

END  -- end PROC 