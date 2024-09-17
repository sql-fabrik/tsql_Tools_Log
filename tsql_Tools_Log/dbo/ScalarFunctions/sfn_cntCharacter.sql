CREATE FUNCTION dbo.sfn_cntCharacter
(
    @lineText  nvarchar(4000)
  , @char2cnt  nvarchar(1)   
)
RETURNS int
AS
BEGIN
    -- Declare the return variable here
    DECLARE @ResultVar  int            

    -- Add the T-SQL statements to compute the return value here                   
    SELECT @ResultVar = LEN(@lineText) - LEN( REPLACE( @lineText, @char2cnt, '' )) 

    -- Return the result of the function
    RETURN @ResultVar

END
