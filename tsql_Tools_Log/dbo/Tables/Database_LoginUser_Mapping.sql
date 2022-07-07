CREATE TABLE [dbo].[Database_LoginUser_Mapping] (
    [ID]           INT             IDENTITY (1, 1) NOT NULL,
    [create_date]  SMALLDATETIME   NULL,
    [Servername]   [sysname]       NULL,
    [Servicename]  [sysname]       NULL,
    [Login_name]   [sysname]       NULL,
    [Login_type]   [sysname]       NULL,
    [Login_sid]    VARBINARY (100) NULL,
    [DatabaseName] [sysname]       NULL,
    [User_name]    [sysname]       NULL,
    [User_type]    [sysname]       NULL,
    [User_sid]     VARBINARY (100) NULL,
    CONSTRAINT [PK_Database_LoginUser_Mapping] PRIMARY KEY CLUSTERED ([ID] ASC)
);

