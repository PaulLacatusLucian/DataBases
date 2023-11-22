USE Hsg1;

CREATE FUNCTION getTotalSales(@gameId INT)
RETURNS TABLE
AS
RETURN (
    SELECT
        gameId,
        COUNT(orderId) AS TotalSales
    FROM [Order-Boardgame]
    WHERE gameId = @gameId
    GROUP BY gameId
);
GO

CREATE VIEW boardGameInfo AS
SELECT
    BG.GameId,
    BG.Name,
    BG.Type,
    BG.Price,
    BG.Description,
    BG.FactoryId,
    BG.AgeGroup,
    TS.TotalSales AS TotalSales
FROM BoardGame BG
LEFT JOIN getTotalSales(BG.GameId) AS TS ON BG.GameId = TS.GameId;

SELECT *
FROM boardGameInfo;
