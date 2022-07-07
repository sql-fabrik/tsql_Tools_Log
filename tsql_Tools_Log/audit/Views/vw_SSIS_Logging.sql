CREATE VIEW [audit].[vw_SSIS_Logging]
AS

With tblStart as (
select ID             as 'ID_Start'
     , created        as 'created_Start'
     , PackStartTime
     , PackageName
     , TaskName       as 'Task_Start'
from   audit.SSIS_Logging 
where  TaskName like 'SQL_start_Logging'
),
     tblEnd as(
select ID             as 'ID_End'
     , created        as 'created_End'
     , PackStartTime
     , PackageName
     , TaskName       as 'Task_End'
from   audit.SSIS_Logging
where  TaskName like 'SQL_end%'
)
SELECT TS.ID_Start
     , TE.ID_End
     , (TE.ID_End - TS.ID_Start)  as 'ID_delta'
     , TS.created_Start
     , TE.created_End
     , CASE  
          WHEN DATEDIFF( second, TS.created_Start, TE.created_End ) < 0  THEN NULL
          WHEN DATEDIFF( second, TS.created_Start, TE.created_End ) = 0  THEN 1   
          ELSE DATEDIFF( second, TS.created_Start, TE.created_End )               
       END                                                    as 'duration_Second'
     , TS.PackStartTime
     , TS.PackageName
     , TS.Task_Start
     , TE.Task_End
FROM   tblStart TS
join   tblEnd   TE
ON     TS.PackStartTime = TE.PackStartTime
  and  TS.PackageName   = TE.PackageName
WHERE  TE.ID_End > TS.ID_Start
--  end VIEW