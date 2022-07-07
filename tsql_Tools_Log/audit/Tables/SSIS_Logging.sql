CREATE TABLE [audit].[SSIS_Logging] (
    [ID]            BIGINT         IDENTITY (1, 1) NOT NULL,
    [created]       DATETIME       CONSTRAINT [DF_audit_SSIS_Logging_created] DEFAULT (getdate()) NULL,
    [PackStartTime] SMALLDATETIME  NULL,
    [SuccessCode]   INT            NULL,
    [PackageName]   NVARCHAR (100) NULL,
    [TaskName]      NVARCHAR (100) NULL,
    [UserName]      NVARCHAR (100) NULL,
    [MessageText]   NVARCHAR (500) NULL,
    CONSTRAINT [PK_SSIS_Logging] PRIMARY KEY CLUSTERED ([ID] ASC)
);

