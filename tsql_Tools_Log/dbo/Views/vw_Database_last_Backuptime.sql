CREATE VIEW [dbo].[vw_Database_last_Backuptime] 
AS
SELECT @@SERVERNAME   as 'Servername'
     , db.name        as 'DatabaseName'
	 , db.recovery_model_desc  --
	 , db.database_id
	 , bs.type                    as 'backup_type'
	 , MAX(bs.backup_finish_date) as 'last_db_backup_date'  
FROM   sys.databases db
left   join
       msdb.dbo.backupset bs
ON     db.name                = bs.database_name  collate Latin1_General_CI_AS
  and  db.recovery_model_desc = bs.recovery_model collate Latin1_General_CI_AS
GROUP  by db.name
     , db.recovery_model_desc
	 , db.database_id
	 , bs.type
--  end VIEW
