-- data.sql - dane przykladowe (tylko gdy tabela jest pusta)
USE schronisko;
GO
IF NOT EXISTS (SELECT 1 FROM dbo.Zwierze)
    INSERT INTO dbo.Zwierze (imie, gatunek, rasa, data_przyjecia, stan_zdrowia) VALUES
        (N'Burek',   N'Pies', N'Mieszaniec', '2026-09-01', N'Dobry'),
        (N'Luna',    N'Pies', N'Labrador',   '2026-10-02', N'Po zabiegu'),
        (N'Rex',     N'Pies', N'Owczarek',   '2026-08-20', N'Dobry'),
        (N'Mruczek', N'Kot',  N'Europejski', '2026-09-15', N'Wymaga szczepienia'),
        (N'Filemon', N'Kot',  NULL,          '2026-10-10', N'Dobry'),
        (N'Kicia',   N'Kot',  N'Syjamski',   '2026-07-05', N'Odrobaczona'),
        (N'Kuba',    N'Inne', N'Krolik',     '2026-10-20', N'Dobry');
GO