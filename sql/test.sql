-- test.sql - testy CRUD, widokow, ograniczen, transakcji i uprawnien
USE schronisko;
GO
SET NOCOUNT ON;
DELETE FROM dbo.Zwierze WHERE imie LIKE N'TEST[_]%';  -- po ewentualnym przerwanym tescie
DECLARE @blad BIT = 0, @przed INT, @po INT;

PRINT N'=== 1. CREATE ===';
INSERT INTO dbo.Zwierze (imie, gatunek, rasa, stan_zdrowia)
VALUES (N'TEST_Azor', N'Pies', N'Owczarek', N'Dobry');
SELECT * FROM dbo.Zwierze WHERE imie = N'TEST_Azor';

PRINT N'=== 2. READ ===';
SELECT * FROM dbo.Zwierze ORDER BY id_zwierzecia;
SELECT imie, rasa FROM dbo.Zwierze WHERE gatunek = N'Pies' ORDER BY imie;

PRINT N'=== 3. UPDATE ===';
UPDATE dbo.Zwierze SET stan_zdrowia = N'Zaszczepiony' WHERE imie = N'TEST_Azor';
IF NOT EXISTS (SELECT 1 FROM dbo.Zwierze WHERE imie = N'TEST_Azor' AND stan_zdrowia = N'Zaszczepiony')
    THROW 50001, N'BLAD: UPDATE nie zadzialal', 1;
SELECT imie, stan_zdrowia FROM dbo.Zwierze WHERE imie = N'TEST_Azor';

PRINT N'=== 4. WIDOKI ===';
SELECT * FROM dbo.v_Psy;
SELECT * FROM dbo.v_Statystyki;
IF NOT EXISTS (SELECT 1 FROM dbo.v_Psy WHERE imie = N'TEST_Azor')  -- widok widzi nowego psa
    THROW 50002, N'BLAD: v_Psy nie zawiera nowego rekordu', 1;

PRINT N'=== 5. DELETE ===';
DELETE FROM dbo.Zwierze WHERE imie = N'TEST_Azor';
IF EXISTS (SELECT 1 FROM dbo.Zwierze WHERE imie = N'TEST_Azor')
    THROW 50003, N'BLAD: DELETE nie zadzialal', 1;

PRINT N'=== 6. OGRANICZENIA (oczekiwane bledy) ===';
BEGIN TRY
    INSERT INTO dbo.Zwierze (imie, gatunek) VALUES (N'TEST_Smok', N'Smok');
END TRY
BEGIN CATCH
    SET @blad = 1; PRINT N'Odrzucono (gatunek): ' + ERROR_MESSAGE();
END CATCH;
IF @blad = 0 THROW 50004, N'BLAD: CHECK na gatunku nie zadzialal', 1;

SET @blad = 0;
BEGIN TRY
    INSERT INTO dbo.Zwierze (imie, gatunek) VALUES (NULL, N'Pies');
END TRY
BEGIN CATCH
    SET @blad = 1; PRINT N'Odrzucono (imie): ' + ERROR_MESSAGE();
END CATCH;
IF @blad = 0 THROW 50005, N'BLAD: NOT NULL na imieniu nie zadzialal', 1;

PRINT N'=== 7. TRANSAKCJA (ROLLBACK) ===';
SET @przed = (SELECT COUNT(*) FROM dbo.Zwierze);
BEGIN TRANSACTION;
    INSERT INTO dbo.Zwierze (imie, gatunek) VALUES (N'TEST_Transakcja', N'Kot');
ROLLBACK TRANSACTION;
SET @po = (SELECT COUNT(*) FROM dbo.Zwierze);
PRINT N'Przed: ' + CAST(@przed AS NVARCHAR(10)) + N', po ROLLBACK: ' + CAST(@po AS NVARCHAR(10));
IF @przed <> @po THROW 50006, N'BLAD: ROLLBACK nie przywrocil stanu', 1;

PRINT N'=== 8. UPRAWNIENIA (app_schronisko) ===';
SET @blad = 0;
EXECUTE AS USER = N'app_schronisko';
SELECT TOP 3 imie, gatunek FROM dbo.Zwierze;  -- dozwolone
BEGIN TRY
    DROP TABLE dbo.Zwierze;                   -- zabronione
END TRY
BEGIN CATCH
    SET @blad = 1; PRINT N'DROP TABLE zablokowany: ' + ERROR_MESSAGE();
END CATCH;
REVERT;
IF @blad = 0 THROW 50007, N'BLAD: DROP TABLE nie powinien byc dozwolony', 1;
IF OBJECT_ID(N'dbo.Zwierze', N'U') IS NULL THROW 50008, N'BLAD: tabela zostala usunieta', 1;

PRINT N'=== WSZYSTKIE TESTY ZAKONCZONE POMYSLNIE ===';
GO