CREATE FUNCTION [dbo].[sfn_convert_INT_run_date] ( @int_date  INT )
RETURNS DATE
AS
BEGIN
    DECLARE @result_Date date

    SET @result_Date = CONVERT( date, CAST( @int_date as nvarchar(8) ), 112)
    ----

    RETURN @result_Date

END  --  end FUNCTION
