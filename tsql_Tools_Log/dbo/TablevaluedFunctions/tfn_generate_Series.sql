CREATE FUNCTION [dbo].[tfn_generate_Series] (
                        @start int           
                      , @end   int           
                      )                      
RETURNS TABLE
--  **** new in SQL2022 (16.x)
--  https://learn.microsoft.com/en-us/sql/t-sql/functions/generate-series-transact-sql?view=sql-server-ver16
--  Compatibility level 160  required
--  *********************************
AS
RETURN
(
WITH                          
NumberSequence( Number ) as   
(   
    Select @start as Number   
    UNION  all                
    Select Number + 1         
    FROM   NumberSequence     
    WHERE  Number < @end  --  Number + 1
)   
    
SELECT Number  as 'value' 
FROM   NumberSequence     
-- Option ( MaxRecursion 32700 )  !! MUSS ins SELECT Statement
)
--  end FUNCTION
