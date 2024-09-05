CREATE FUNCTION [dbo].[sfn_convert_INT_run_time] ( @int_time  INT )
RETURNS TIME
AS
BEGIN
    DECLARE @int_time__string nvarchar(6)
          , @result_Time      time 

    SET @int_time__string = RIGHT( '000000' + CAST(@int_time as nvarchar(6)), 6)
    SET @result_Time = CONVERT( time
                              , SubString(@int_time__string, 1, 2) + ':' + SubString(@int_time__string, 3, 2) + ':' + SubString(@int_time__string, 5, 2)
                              , 114 )
    ----

    RETURN @result_Time

END  --  end FUNCTION
