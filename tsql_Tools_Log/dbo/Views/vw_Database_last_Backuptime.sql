﻿CREATE VIEW [dbo].[vw_Database_last_Backuptime] 
AS

WITH
SQ_last_db_FullBackup_date as
(
SELECT ROW_NUMBER()  over (Order by db.database_id)  as 'rowNr'       
     , @@SERVERNAME                                  as 'Servername'  
     , db.name                                       as 'DatabaseName'
     , db.recovery_model_desc  --
     , db.database_id
     , IsNULL(bs.type, '')                           as 'backup_type'
     , CASE
          WHEN bs.type = 'D'        THEN  'Fullbackup Database'   
          WHEN bs.type = 'I'        THEN  'Differential Database' 
          WHEN bs.type = 'L'        THEN  'Log'                   
          WHEN bs.type = 'F'        THEN  'File or filegroup'     
          WHEN bs.type = 'G'        THEN  'Differential file'     
          WHEN bs.type = 'P'        THEN  'Partial'               
          WHEN bs.type = 'Q'        THEN  'Differential partial'  
          WHEN db.database_id = 2   THEN  ''   -- tempdb          
          ELSE                            'na'                    
       END                          as 'backup_type_desc'         
     , MAX(bs.backup_finish_date)   as 'last_db_FullBackup_date'  
FROM   sys.databases db
left   join
       msdb.dbo.backupset bs
ON     db.name                = bs.database_name  collate Latin1_General_CI_AS
  and  db.recovery_model_desc = bs.recovery_model collate Latin1_General_CI_AS
WHERE  bs.type = 'D'  -- 'Fullbackup Database'
--  and  db.database_id = 1
GROUP  by db.name
     , db.recovery_model_desc
     , db.database_id
     , bs.type
) ,
SQ_backup_finish_date as
(
SELECT ROW_NUMBER()  over (Order by db.database_id)  as 'rowNr'       
     , @@SERVERNAME                                  as 'Servername'  
     , db.name                                       as 'DatabaseName'
     , db.compatibility_level                                         
     , CASE
          WHEN  db.compatibility_level = 160       THEN  'SQL Server 2022'    
          WHEN  db.compatibility_level = 150       THEN  'SQL Server 2019'    
          WHEN  db.compatibility_level = 140       THEN  'SQL Server 2017'    
          WHEN  db.compatibility_level = 130       THEN  'SQL Server 2016'    
          WHEN  db.compatibility_level = 120       THEN  'SQL Server 2014'    
          WHEN  db.compatibility_level = 110       THEN  'SQL Server 2012'    
--        WHEN  db.compatibility_level = 105       THEN  'SQL Server 2008 R2' 
          WHEN  db.compatibility_level = 100       THEN  'SQL Server 2008'    
          WHEN  db.compatibility_level =  90       THEN  'SQL Server 2005'    
          WHEN  db.compatibility_level =  80       THEN  'SQL Server 2000'    
       END                                           as 'comp_level_desc'     
     , db.recovery_model_desc  --
     , db.database_id
     , IsNULL(bs.type, '')                           as 'backup_type'
     , CASE
          WHEN bs.type = 'D'        THEN  'Fullbackup Database'   
          WHEN bs.type = 'I'        THEN  'Differential Database' 
          WHEN bs.type = 'L'        THEN  'Log'                   
          WHEN bs.type = 'F'        THEN  'File or filegroup'     
          WHEN bs.type = 'G'        THEN  'Differential file'     
          WHEN bs.type = 'P'        THEN  'Partial'               
          WHEN bs.type = 'Q'        THEN  'Differential partial'  
          WHEN db.database_id = 2   THEN  ''   -- tempdb          
          ELSE                            'na'                    
       END                          as 'backup_type_desc'         
     , bs.backup_finish_date        as 'backup_finish_date'       
FROM   sys.databases db
left   join
       msdb.dbo.backupset bs
ON     db.name                = bs.database_name  collate Latin1_General_CI_AS
  and  db.recovery_model_desc = bs.recovery_model collate Latin1_General_CI_AS
)
SELECT FD.Servername         
     , FD.DatabaseName       
     , FD.compatibility_level
     , FD.comp_level_desc    
     , FD.recovery_model_desc
     , FD.database_id        
     , FD.backup_type        
     , FD.backup_type_desc   
     , FD.backup_finish_date 
FROM   SQ_last_db_FullBackup_date SQ
join
       SQ_backup_finish_date FD
ON     SQ.Servername              =  FD.Servername         
  and  SQ.database_id             =  FD.database_id        
  and  SQ.last_db_FullBackup_date <= FD.backup_finish_date 
ORDER  by FD.Servername     
     , FD.database_id       
     , FD.backup_finish_date

--  end VIEW
