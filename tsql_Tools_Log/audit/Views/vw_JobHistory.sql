/****** Script for SelectTopNRows command from SSMS  ******/

create view audit.vw_JobHistory
as 

select 
       J.name as 'Jobname'
     , H.*
from   msdb.dbo.sysjobs J
JOIN   msdb.dbo.sysjobhistory H
ON     J.job_id = H.job_id
where  J.name like 'job_proj%'
  and  H.run_status <> 1

-- end view

