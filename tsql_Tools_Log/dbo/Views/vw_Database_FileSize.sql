
CREATE VIEW [dbo].[vw_Database_FileSize]
AS
SELECT @@SERVERNAME   as 'Servername'
     , @@SERVICENAME  as 'Servicename'
     , db.name        as 'DatabaseName'
	 , db.recovery_model_desc --
	 , db.database_id
     , mf.type_desc
	 , mf.size        as 'size_inPages'
	 , CAST(mf.size as bigint)  * 8192 / 1024 / 1024  as 'size_inMB'
FROM   sys.databases db
join   sys.master_files mf
ON     db.database_id = mf.database_id
--  end VIEW
