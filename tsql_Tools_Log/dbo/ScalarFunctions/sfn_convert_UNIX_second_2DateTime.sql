CREATE FUNCTION [dbo].[sfn_convert_UNIX_second_2DateTime] ( @in_seconds BIGINT )
RETURNS DATETIME
AS
BEGIN
    DECLARE @LocalTime_Offset       BIGINT = 0
          , @AdjustedLocal_seconds  BIGINT    

    DECLARE @result_DateTime    DATETIME      

    SET @LocalTime_Offset = DATEDIFF(second, GetDate() ,GetUTCdate())
    SET @AdjustedLocal_seconds = @in_seconds - @LocalTime_Offset     

    SET @result_DateTime = ( SELECT DATEADD( second, @AdjustedLocal_seconds , CAST('1970-01-01 00:00:00' AS datetime) ) )
    ----
    RETURN @result_DateTime

END;
