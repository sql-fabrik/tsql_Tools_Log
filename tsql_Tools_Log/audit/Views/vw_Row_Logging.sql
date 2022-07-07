

CREATE VIEW audit.vw_Row_Logging
AS

with JoinTbl as(
select 'SL' as 'source', PackStartTime, PackageName, created 
from   audit.SSIS_Logging
union
select 'RL' as 'source', PackStartTime, PackageName, created 
from   audit.Row_Logging
--Order  by PackStartTime, PackageName, created
)
SELECT ROW_NUMBER() Over(Order by JT.created, JT.PackStartTime, JT.PackageName)  as 'RowNr'
     , JT.PackStartTime
    -- , JT.PackageName
     , CASE
          WHEN LAG( JT.PackageName, 1 ) Over( Order by JT.created ) IS NULL           THEN  JT.PackageName  -- very 1st row
          WHEN JT.PackageName = LAG( JT.PackageName, 1 ) Over( Order by JT.created )  THEN  NULL
          ELSE                                                                              JT.PackageName
       END                                                                       as 'PackageName'
     , JT.created
     , CASE
          WHEN COALESCE( SL.TaskName, RL.TaskName ) =    'SQL_log_RowCount'    THEN RL.TaskName
          WHEN COALESCE( SL.TaskName, RL.TaskName ) like 'SQL_log_RowCount_%'  THEN Replace(RL.TaskName, 'SQL_log_RowCount_', 'rowCnt_')   -- SQL_log_RowCount_FixingDetail  rowCnt_
          ELSE COALESCE( SL.TaskName, RL.TaskName )
       END                                                                        as 'TaskName'
    -- , COALESCE( SL.TaskName, RL.TaskName ) as 'TaskName'
     , RL.vCurrRowsSource
     , RL.vCurrRowsTarget
     , RL.vInsDelta
     , RL.vUpdDelta
     , RL.vDelDelta
FROM   audit.SSIS_Logging SL
full   join   
       JoinTbl JT
ON     SL.PackStartTime = JT.PackStartTime
  and  SL.PackageName   = JT.PackageName
  and  SL.created       = JT.created 
full   join
       audit.Row_Logging RL
ON     JT.PackStartTime = RL.PackStartTime
  and  JT.PackageName   = RL.PackageName
  and  JT.created       = RL.created
-- end VIEW