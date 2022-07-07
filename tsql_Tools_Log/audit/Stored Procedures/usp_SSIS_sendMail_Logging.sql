CREATE PROC [audit].[usp_SSIS_sendMail_Logging]
                   @pPackageName        nvarchar(100) --  = ?
                 , @pTaskName           nvarchar(100) --  = ?
				 , @pPackStartTime      datetime 
                 , @pEmail_to           nvarchar(50)
				 , @pEmail_attachment   nvarchar(max)
AS
BEGIN

Set @pPackStartTime = CAST( @pPackStartTime as smalldatetime );

INSERT INTO [audit].[SSIS_sendMail_Logging]
	   (   PackStartTime,   PackageName,   TaskName,  pEmail_to,  pEmail_attachment )
VALUES ( @pPackStartTime, @pPackageName, @pTaskName, @pEmail_to, @pEmail_attachment )

END  --  end Proc