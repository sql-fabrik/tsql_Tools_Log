


CREATE PROC [audit].[usp_Start_Logging]
                   @pPackageName       nvarchar(100) --  = ?
                 , @pTaskName          nvarchar(100) --  = ?
                 , @pUserName          nvarchar(100) --  = ?
                 , @pPackStartTime     datetime      --  = ?
                 , @pSuccessCode       int           --  = ?
AS
BEGIN

Set @pPackStartTime = CAST( @pPackStartTime as smalldatetime );

Declare @MessageText nvarchar(500)

Set @MessageText = N'{'
                 + N' "Packagestatus":"Package ist gestartet"'
                 + N' }'
----
 
INSERT INTO [audit].[SSIS_Logging]
       (   PackStartTime,   SuccessCode,   PackageName,   TaskName,   UserName,  MessageText )
VALUES ( @pPackStartTime, @pSuccessCode, @pPackageName, @pTaskName, @pUserName, @MessageText )

END  --  end Proc