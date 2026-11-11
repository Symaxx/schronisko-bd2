-- security.sql - login, uzytkownik i rola aplikacji

USE master;
GO
IF SUSER_ID(N'app_schronisko') IS NULL
    EXEC (N'CREATE LOGIN app_schronisko WITH PASSWORD = N''$(APP_PASSWORD)'';');
ELSE
    EXEC (N'ALTER LOGIN app_schronisko WITH PASSWORD = N''$(APP_PASSWORD)'';');
GO
USE schronisko;
GO
IF DATABASE_PRINCIPAL_ID(N'rola_aplikacji') IS NULL CREATE ROLE rola_aplikacji;
IF DATABASE_PRINCIPAL_ID(N'app_schronisko') IS NULL CREATE USER app_schronisko FOR LOGIN app_schronisko;
ALTER ROLE rola_aplikacji ADD MEMBER app_schronisko;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Zwierze      TO rola_aplikacji;
GRANT SELECT                         ON dbo.v_Psy        TO rola_aplikacji;
GRANT SELECT                         ON dbo.v_Statystyki TO rola_aplikacji;
GO