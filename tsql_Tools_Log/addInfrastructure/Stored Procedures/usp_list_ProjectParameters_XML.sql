CREATE   PROC [addInfrastructure].[usp_list_ProjectParameters_XML]    
                                         @pSSIS_Folder_name   sysname 
                                       , @pSSIS_Project_name  sysname 
AS
BEGIN

;
WITH parameterTable 
as
(
select DISTINCT 
       op.parameter_name
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
)

SELECT parameter_name        as '@parameter_name'
     , data_type             as '@data_type'
     , design_default_value  as '@configValue'
FROM   parameterTable pt
FOR    XML PATH('keyValue'), ROOT('allValues')

END  -- end PROC