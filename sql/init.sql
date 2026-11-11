-- init.sql - baza, tabela, indeks i widoki (idempotentny)
IF DB_ID(N'schronisko') IS NULL CREATE DATABASE schronisko;
GO
USE schronisko;
GO
IF OBJECT_ID(N'dbo.Zwierze', N'U') IS NULL
CREATE TABLE dbo.Zwierze (
    id_zwierzecia  INT IDENTITY(1,1) CONSTRAINT PK_Zwierze PRIMARY KEY,
    imie           NVARCHAR(50) NOT NULL
        CONSTRAINT CK_Zwierze_imie CHECK (LEN(LTRIM(RTRIM(imie))) > 0),
    gatunek        NVARCHAR(30) NOT NULL
        CONSTRAINT CK_Zwierze_gatunek CHECK (gatunek IN (N'Pies', N'Kot', N'Inne')),
    rasa           NVARCHAR(50) NULL,
    data_przyjecia DATE NOT NULL
        CONSTRAINT DF_Zwierze_data DEFAULT (CAST(GETDATE() AS DATE)),
    stan_zdrowia   NVARCHAR(100) NULL
);
GO
IF INDEXPROPERTY(OBJECT_ID(N'dbo.Zwierze'), N'IX_Zwierze_gatunek', 'IndexID') IS NULL
    CREATE INDEX IX_Zwierze_gatunek ON dbo.Zwierze (gatunek) INCLUDE (imie, rasa);
GO
CREATE OR ALTER VIEW dbo.v_Psy AS
SELECT id_zwierzecia, imie, rasa, data_przyjecia, stan_zdrowia
FROM dbo.Zwierze WHERE gatunek = N'Pies';
GO
CREATE OR ALTER VIEW dbo.v_Statystyki AS
SELECT gatunek, COUNT(*) AS liczba_zwierzat,
       MIN(data_przyjecia) AS pierwsze_przyjecie, MAX(data_przyjecia) AS ostatnie_przyjecie
FROM dbo.Zwierze GROUP BY gatunek;
GO