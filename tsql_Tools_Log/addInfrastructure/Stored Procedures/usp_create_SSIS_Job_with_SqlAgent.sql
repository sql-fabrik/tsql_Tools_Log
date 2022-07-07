CREATE PROC [addInfrastructure].[usp_create_SSIS_Job_with_SqlAgent]
                               @pSSIS_Folder_name    sysname
							 , @pSSIS_Project_name   sysname  

AS
BEGIN

Set NoCount ON;

Declare @tempSteps TABLE( 
          ID  int                    identity(1,1)
        , job_Name                   sysname
        , step_Name                  sysname
        , Folder_Name                sysname NULL
        , Project_Name               sysname NULL
        , Environment_reference_id   bigint  NULL
        , Environment_reference_type sysname NULL
        , Package_Name               sysname NULL
        , step_nr                    int     
        , max_step_nr                int
        )

INSERT INTO @tempSteps
     (   job_Name
     ,   step_Name
     ,   Folder_Name
     ,   Project_Name
     ,   Environment_reference_id
     ,   Environment_reference_type
     ,   Package_Name
     ,   step_nr
     ,   max_step_nr 
     )
SELECT T.job_Name
     , T.step_Name
     , T.Folder_Name
     , T.Project_Name
     , T.Environment_reference_id
     , T.Environment_reference_type
     , T.Package_Name
     , ROW_NUMBER()  over (partition by T.job_Name order by T.step_Name) as 'step_nr'
     , COUNT(*)      over (partition by T.job_Name )                     as 'max_step_nr'
FROM  
(
select 'job_' + pr.name                    as 'job_Name' 
   --  , 'step100_start_Job'                 as 'step_Name'
     , LEFT(
        Replace( pr.name, 'proj', 'step' ) 
                                , 8 )
       + '_start_Job'                      as 'step_Name'
     , NULL                                as 'Folder_Name'
     , NULL                                as 'Project_Name'
     , NULL                                as 'Environment_reference_id'
     , NULL                                as 'Environment_reference_type'
     , NULL                                as 'Package_Name'
from   SSISDB.catalog.folders fo 
join   SSISDB.catalog.projects pr
on     fo.folder_id = pr.folder_id
where  fo.name  like  @pSSIS_Folder_name
  and  pr.name  like  @pSSIS_Project_name  --'proj0100%'

UNION
select 'job_' + pr.name                    as 'job_Name' 
     , Replace( 
        Replace( pa.name, 'pack', 'step' )
                        , '.dtsx', ''    ) as 'step_Name'
     , fo.name                             as 'Folder_Name'
     , pr.name                             as 'Project_Name'
     , er.reference_id                     as 'Environment_reference_id'
     , er.reference_type                   as 'Environment_reference_type'
     , pa.name                             as 'Package_Name'
from   SSISDB.catalog.folders fo
join   SSISDB.catalog.projects pr
on     fo.folder_id = pr.folder_id
left   join
       SSISDB.catalog.environment_references er
on     pr.project_id = er.project_id
join   SSISDB.catalog.packages pa
on     pr.project_id = pa.project_id
where  fo.name  like  @pSSIS_Folder_name
  and  pr.name  like  @pSSIS_Project_name  --'proj0100%'
) T
ORDER  by T.job_Name, T.step_Name

----select * from @tempSteps
----------------------------
Declare @Servername                  sysname = @@SERVERNAME --// SERVERPROPERTY('ServerName') AS InstanceName
      , @job_Name_prev               sysname = ''  -- initial !!

      , @job_Name_new                sysname
      , @step_Name                   sysname
      , @Folder_Name                 sysname
      , @Project_Name                sysname
      ,	@Environment_reference_id    bigint 
      , @Environment_reference_type  sysname
      , @Package_Name                sysname
      , @step_nr                     int    
      , @max_step_nr                 int    

      , @step_action                 int    
      , @SSIS_cmd                    nvarchar(2000)
      , @Envi_cmd                    nvarchar(100) 

-- WHILE-Loop
Declare @min  int = ( select min(ID) from @tempSteps )
      , @max  int = ( select max(ID) from @tempSteps )

---- Object: Job ...
DECLARE @ReturnCode INT = 0
DECLARE @jobId      BINARY(16)

WHILE @min <= @max
BEGIN
    SET  @job_Name_new                = ( select job_Name                   from @tempSteps  where ID = @min )
    SET  @step_Name                   = ( select step_Name                  from @tempSteps  where ID = @min )
    SET  @Folder_Name                 = ( select Folder_Name                from @tempSteps  where ID = @min )
    SET  @Project_Name                = ( select Project_Name               from @tempSteps  where ID = @min )
    SET  @Environment_reference_id    = ( select Environment_reference_id   from @tempSteps  where ID = @min )
    SET  @Environment_reference_type  = ( select Environment_reference_type from @tempSteps  where ID = @min )
    SET  @Package_Name                = ( select Package_Name               from @tempSteps  where ID = @min )
    SET  @step_nr                     = ( select step_nr                    from @tempSteps  where ID = @min )
    SET  @max_step_nr                 = ( select max_step_nr                from @tempSteps  where ID = @min )

    IF ( @job_Name_prev <> @job_Name_new )
    BEGIN
        IF EXISTS( select * from msdb.dbo.sysjobs where name = @job_Name_new )
           EXEC msdb.dbo.sp_delete_job @job_name = @job_Name_new	    
        EXEC msdb.dbo.sp_add_job 
                      @job_name         = @job_Name_new
                    , @enabled          = 1
                    , @owner_login_name = N'sa'
                    , @job_id           = @jobId OUTPUT
    END  -- IF @pjob_Name_prev <> @pjob_Name_new
    --------------------------------------------
    IF ( @step_nr = 1 )
    BEGIN
        IF ( @step_nr < @max_step_nr )
           SET @step_action = 3  -- "Go to next step"
        ELSE
           SET @step_action = 1  -- (default)

        EXEC msdb.dbo.sp_add_jobstep 
                      @job_id            = @jobId
                    , @step_name         = @step_Name
                    , @step_id           = @step_nr
                    , @on_success_action = @step_action
                    , @on_fail_action    = 2  -- "Quit with failure (default)"
                    , @subsystem         = N'TSQL'
                    , @command           = N'SELECT ''start Job'' '
                    , @database_name     = N'tempdb'
    END  -- IF ( @pstep_nr = 1 )
    --------------------------------------------
    IF ( @step_nr > 1 )
    BEGIN
        IF ( @step_nr < @max_step_nr )
           SET @step_action = 3  -- "Go to next step"
        ELSE
           SET @step_action = 1  -- (default)
        --
        -- if environment is configured and referenced
        IF ( @Environment_reference_id is NULL )
           SET @Envi_cmd = N''
        ELSE
           SET @Envi_cmd = N' /ENVREFERENCE ' + CAST( @Environment_reference_id as nvarchar(20) ) + N'  '
        --
        SET @SSIS_cmd = N'/ISSERVER "\"\SSISDB\' + @pSSIS_Folder_name + '\' + @pSSIS_Project_name        +   '\' + @Package_Name           + '\""  /SERVER "\"' + @Servername + '\"" ' +  @Envi_cmd + ' /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E'
                    -- = N'/ISSERVER "\"\SSISDB\FBI_DataMigration\proj0100_Basic_configuration_import\pack0101_ApplicationSetting.dtsx\""  /SERVER localhost                         /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E'
        -- end IF   

        EXEC msdb.dbo.sp_add_jobstep 
                      @job_id            = @jobId
                    , @step_name         = @step_Name
                    , @step_id           = @step_nr
                    , @on_success_action = @step_action
                    , @subsystem         = N'SSIS'
                    , @command           = @SSIS_cmd
                    , @database_name     = N'master'
					, @flags             = 0

    END  -- IF ( @pstep_nr > 1 )
    --------------------------------------------
    IF ( @step_nr = @max_step_nr )
    BEGIN
        EXEC msdb.dbo.sp_update_job @job_id        = @jobId
		                          , @start_step_id = 1
        EXEC msdb.dbo.sp_add_jobserver @job_id      = @jobId
		                             , @server_name = @Servername
    END  -- IF ( @pstep_nr = @pmax_step_nr )

    --------------------------------------------
    --------------------------------------------
    SET @job_Name_prev = @job_Name_new
    SET @min = @min + 1

END  -- end WHILE 


END -- end PROC