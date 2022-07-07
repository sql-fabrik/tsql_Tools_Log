CREATE PROC [audit].[usp_End_Logging]
                   @pPackageName       nvarchar(100) --  = ?
                 , @pTaskName          nvarchar(100) --  = ?
                 , @pUserName          nvarchar(100) --  = ?
				 , @pPackStartTime     datetime      --  = ?
                 , @vSuccessCode       int           --  = ?
                 , @vConfigSource      nvarchar(100) --  = ?  
                 , @vConfigPackagename nvarchar(100) --  = ?    
                 , @vConfigValue       int           --  = ?   
AS
BEGIN

Set @pPackStartTime = CAST( @pPackStartTime as smalldatetime );

Declare @MessageText nvarchar(500);
Set     @MessageText = N',"vConfigSource":"'        + @vConfigSource                       + '"'
                     + N',"vConfigPackagename":"'   + @vConfigPackagename                  + '"'
					 + N',"vConfigValue":"'         + CAST(@vConfigValue as nvarchar(10))  + '"'
				     + N'}'


-- specific "end-message"
IF ( @pPackageName = N'pack01_' and @pTaskName = N'SQL_end_Logging_error1' )
   SET @MessageText  = N'{ "Packagestatus":"irgend ein Fehler / Package ist beendet"' + @MessageText

IF ( @pPackageName = N'pack01_' and @pTaskName = N'SQL_end_Logging__OK' )
   Set @MessageText  = N'{ "Packagestatus":"Package ist beendet"' + @MessageText
---------

IF ( @pPackageName = N'pack00__template_from_BIML' and @pTaskName = N'SQL_end_Logging_error1' )
   Set @MessageText  = N'{ "Packagestatus":"T-SQL MERGE hat einen Fehler verursacht! / Package ist beendet"' + @MessageText

IF ( @pPackageName = N'pack00__template_from_BIML' and @pTaskName = N'SQL_end_Logging__OK' )
   Set @MessageText  = N'{ "Packagestatus":"Package ist beendet"' + @MessageText

-- default "end-messaage"
IF LEFT(@MessageText, 7) <> '{ "Pack'
   Set @MessageText  = N'{ "Packagestatus":"Package ist beendet"' + @MessageText
---------------------------------------------------------------------------------------

 
INSERT INTO [audit].[SSIS_Logging]
	   (   PackStartTime,   SuccessCode,   PackageName,   TaskName,   UserName,  MessageText )
VALUES ( @pPackStartTime, @vSuccessCode, @pPackageName, @pTaskName, @pUserName, @MessageText )

END  --  end Proc