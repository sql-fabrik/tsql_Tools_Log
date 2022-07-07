----

CREATE VIEW dbo.vw_Database_LoginUser_Mapping
AS
SELECT distinct
       create_date
     , Servername
     , Servicename
     , Login_name
     , Login_type
     , Login_sid
     , DatabaseName
     , User_name
     , User_type
     , User_sid
FROM   dbo.Database_LoginUser_Mapping
WHERE  User_name not in ('guest', 'INFORMATION_SCHEMA', 'public', 'sys')
--  end VIEW
