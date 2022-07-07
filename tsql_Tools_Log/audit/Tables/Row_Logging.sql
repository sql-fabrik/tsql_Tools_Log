CREATE TABLE [audit].[Row_Logging] (
    [ID]              BIGINT         IDENTITY (1, 1) NOT NULL,
    [created]         DATETIME       CONSTRAINT [DF_audit_Row_Logging_created] DEFAULT (getdate()) NULL,
    [PackStartTime]   SMALLDATETIME  NULL,
    [PackageName]     NVARCHAR (100) NULL,
    [TaskName]        NVARCHAR (100) NULL,
    [vCurrRowsSource] BIGINT         NULL,
    [vCurrRowsTarget] BIGINT         NULL,
    [vInsDelta]       BIGINT         NULL,
    [vUpdDelta]       BIGINT         NULL,
    [vDelDelta]       BIGINT         NULL,
    CONSTRAINT [PK_Row_Logging] PRIMARY KEY CLUSTERED ([ID] ASC)
);

