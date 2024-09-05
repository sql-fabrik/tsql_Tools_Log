CREATE FUNCTION [dbo].[sfn_convert_UNIX_millisecond_2DateTime] ( @in_milliseconds BIGINT )
RETURNS DATETIME
AS
BEGIN
    DECLARE @LocalTime_Offset       BIGINT = 0
          , @AdjustedLocal_millisec BIGINT    

    DECLARE @result_DateTime    DATETIME      

    SET @LocalTime_Offset = DATEDIFF(millisecond, GetDate() ,GetUTCdate())
    SET @AdjustedLocal_millisec = @in_milliseconds - @LocalTime_Offset    

    SET @result_DateTime = ( SELECT DATEADD( SECOND     , @AdjustedLocal_millisec / 1000 , CAST('1970-01-01 00:00:00' AS datetime) ) )
    SET @result_DateTime = ( SELECT DATEADD( MILLISECOND, @AdjustedLocal_millisec % 1000 , @result_DateTime                        ) )
    ----
    RETURN @result_DateTime

END;
