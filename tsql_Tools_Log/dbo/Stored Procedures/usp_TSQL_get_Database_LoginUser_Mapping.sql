----

CREATE PROC dbo.[usp_TSQL_get_Database_LoginUser_Mapping] 
AS
BEGIN

SET NoCount ON;

TRUNCATE TABLE dbo.Database_LoginUser_Mapping;
----

DECLARE @parTable TABLE (
          rowNr         int
        , DatabaseName  sysname
        )

INSERT INTO @parTable
SELECT ROW_NUMBER() over(Order by database_id) as 'rowNr'
     , name as 'DatabaseName'
FROM   sys.databases
WHERE  state_desc = 'ONLINE'

----
DECLARE @min  int = ( SELECT min(rowNr) FROM @parTable )
      , @max  int = ( SELECT max(rowNr) FROM @parTable )

DECLARE @pDatabaseName  sysname  
DECLARE @sqlCmd         nvarchar(4000)

WHILE @min <= @max
BEGIN

    SET @pDatabaseName = ( SELECT DatabaseName FROM @parTable WHERE rowNr = @min )

    SET @sqlCmd = N'
    ;
    WITH 
    LoginTbl as
    (
    SELECT @@SERVERNAME   as ''Servername''
         , @@SERVICENAME  as ''Servicename''
         , sp.name        as ''Login_name''
         , sp.type_desc   as ''Login_type''
         , sp.sid         as ''Login_sid''
    FROM   sys.server_principals sp
    WHERE  type not in (''R'')
    ) , 
    User_Tbl as
    (
    SELECT ''' + @pDatabaseName + '''  as ''DatabaseName''
         , dp.name        as ''User_name''
         , dp.type_desc   as ''User_type''
         , dp.sid         as ''User_sid''
    FROM  ' + @pDatabaseName + '.sys.database_principals dp
    WHERE  dp.is_fixed_role = 0
    )
    INSERT INTO dbo.Database_LoginUser_Mapping
         ( create_date, Servername
         , Servicename, Login_name, Login_type, Login_sid
         , DatabaseName, User_name, User_type, User_sid )
    SELECT CAST( GETDATE() as smalldatetime )  as ''create_date''
         , LT.Servername
         , LT.Servicename
         , LT.Login_name
         , LT.Login_type
         , LT.Login_sid
         , UT.DatabaseName
         , UT.User_name
         , UT.User_type
         , UT.User_sid
    FROM   LoginTbl LT
    FULL   JOIN
           User_Tbl UT
    ON     LT.Login_sid = UT.User_sid '-- end sqlCmd

    EXEC sp_executesql @sqlCmd

    ----
    SET @min = @min + 1

END  -- end WHILE

END  -- end PROC
