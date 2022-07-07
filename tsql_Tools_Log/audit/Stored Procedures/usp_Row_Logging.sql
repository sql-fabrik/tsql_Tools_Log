CREATE PROC [audit].[usp_Row_Logging]
				   @pPackStartTime     datetime      --  = ?
                 , @pPackageName       nvarchar(100) --  = ?
                 , @pTaskName          nvarchar(100) --  = ?
                 , @vCurrRowsSource    bigint        --  = ?
                 , @vCurrRowsTarget    bigint        --  = ?
                 , @vInsDelta          bigint        --  = ?
                 , @vUpdDelta          bigint        --  = ?
                 , @vDelDelta          bigint        --  = ?
AS
BEGIN

Set @pPackStartTime = CAST( @pPackStartTime as smalldatetime );

INSERT INTO [audit].[Row_Logging]
	   (   PackStartTime,   PackageName,   TaskName,  vCurrRowsSource,  vCurrRowsTarget,  vInsDelta,  vUpdDelta,  vDelDelta )
VALUES ( @pPackStartTime, @pPackageName, @pTaskName, @vCurrRowsSource, @vCurrRowsTarget, @vInsDelta, @vUpdDelta, @vDelDelta )

END  --  end Proc