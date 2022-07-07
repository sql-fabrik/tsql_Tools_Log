CREATE TABLE [audit].[SSIS_sendMail_Logging] (
    [ID]                BIGINT         NOT NULL,
    [created]           DATETIME       CONSTRAINT [DF_SSIS_sendMail_Logging_created] DEFAULT (getdate()) NULL,
    [PackStartTime]     SMALLDATETIME  NULL,
    [PackageName]       NVARCHAR (100) NULL,
    [TaskName]          NVARCHAR (100) NULL,
    [pEmail_to]         NVARCHAR (50)  NULL,
    [pEmail_attachment] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_SSIS_sendMail_Logging] PRIMARY KEY CLUSTERED ([ID] ASC)
);

