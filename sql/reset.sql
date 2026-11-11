-- reset.sql - usuwa baze i login aplikacji (kasuje dane!)
USE master;
GO
IF DB_ID(N'schronisko') IS NOT NULL
BEGIN
    ALTER DATABASE schronisko SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE schronisko;
END
IF SUSER_ID(N'app_schronisko') IS NOT NULL DROP LOGIN app_schronisko;
GO