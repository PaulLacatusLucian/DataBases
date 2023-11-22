USE Hsg1
DROP TABLE IF EXISTS [Boardgame-Depo];

DROP TABLE IF EXISTS Review;


-- 1a. Tabelle erstellen 

CREATE TABLE Review (
    reviewId int PRIMARY KEY,
    description varchar(1000),
    rating varchar(50),
    customerId int,
    FOREIGN KEY (customerId) REFERENCES Customer(customerId)
);


CREATE TABLE [Boardgame-Depo] (
    gameId int,
    depoId int,
    PRIMARY KEY (gameId, depoId),
    FOREIGN KEY (gameId) REFERENCES Boardgame(gameId),
    FOREIGN KEY (depoId) REFERENCES Depo(depoId)
); 


-- 1b. einfugen von Daten

INSERT INTO [Boardgame-Depo] (gameId, depoId)
VALUES (1,1);

INSERT INTO [Boardgame-Depo] (gameId, depoId)
VALUES (1,4);

INSERT INTO [Boardgame-Depo] (gameId, depoId)
VALUES (1,2);

INSERT INTO [Boardgame-Depo] (gameId, depoId)
VALUES (1,3);

INSERT INTO [Boardgame-Depo] (gameId, depoId)
VALUES (2,2);

INSERT INTO [Boardgame-Depo] (gameId, depoId)
VALUES (3,3);

INSERT INTO Review (reviewId, description, rating, customerId)
VALUES (1, 'This is a great product!', '5 stars', 1); 

INSERT INTO Review (reviewId, description, rating, customerId)
VALUES (2, 'Meh', '3 stars', 2);

INSERT INTO Review (reviewId, description, rating, customerId)
VALUES (3, 'Happy with the product', '3 stars', 3);

/* 1c. Fremdschlusselintegritatregel nich erfullt

INSERT INTO Review (reviewId, description, rating, customerId)
VALUES (4, 'The product is too expensive', '1 stars', 5);

*/

-- 1d. Andern von Daten

UPDATE Review
SET description = 'I changed my mind', rating = '3 stars'
WHERE reviewId = 3 or rating LIKE '5%';

UPDATE BoardGame 
SET factoryId = 1
WHERE price = 85 and ageGroup LIKE '%6';

UPDATE BoardGame 
SET factoryId = 1
WHERE price = 85 and ageGroup LIKE '%6';

UPDATE BoardGame 
SET factoryId = 2
WHERE [type] IN ('Party', 'Fun', 'Escape')

UPDATE BoardGame
SET price = 199
WHERE factoryId IS NULL;

UPDATE BoardGame
SET factoryId = 2
WHERE price BETWEEN 90 AND 140;


-- 2.


SELECT DISTINCT Customer.name AS customer_with_review
FROM Customer
JOIN [Order] ON [Order].customerId = Customer.customerId
JOIN [Order-Boardgame] ON [Order-Boardgame].orderId = [Order].orderId
JOIN BoardGame ON [Order-Boardgame].gameId = BoardGame.gameId
WHERE Customer.customerId IN (SELECT  customerId FROM Review);


SELECT Customer.name AS customer_with_bothGames
FROM Customer
JOIN [Order] ON [Order].customerId = Customer.customerId
JOIN [Order-Boardgame] ON [Order-Boardgame].orderId = [Order].orderId
JOIN BoardGame ON [Order-Boardgame].gameId = BoardGame.gameId
WHERE BoardGame.name = 'Activity'
INTERSECT
SELECT Customer.customerId
FROM Customer
JOIN [Order] ON [Order].customerId = Customer.customerId
JOIN [Order-Boardgame] ON [Order-Boardgame].orderId = [Order].orderId
JOIN BoardGame ON [Order-Boardgame].gameId = BoardGame.gameId
WHERE BoardGame.name = 'Alias'

-- corectat
SELECT TOP(1) Customer.name as Name, SUM(amount) as Anzahl
FROM Customer
JOIN [Order] on [Order].customerId = Customer.customerId
GROUP BY Customer.customerId, Customer.name
HAVING SUM(amount) > 1
ORDER BY SUM(amount) DESC


SELECT BoardGame.name as boardgame_without_supplier
FROM BoardGame
JOIN [Boardgame-Depo] on [Boardgame-Depo].gameId = BoardGame.gameId
JOIN Depo on Depo.depoId = [Boardgame-Depo].depoId
WHERE BoardGame.gameId NOT IN (SELECT [Supplier-Depo].depoId FROM [Supplier-Depo])

SELECT  BoardGame.gameId, BoardGame.name AS boardgame_without_supplier_v2
FROM BoardGame 
JOIN [Boardgame-Depo] ON [Boardgame-Depo].gameId = BoardGame.gameId
JOIN Depo ON Depo.depoId = [Boardgame-Depo].depoId
EXCEPT
SELECT Boardgame.gameId
FROM BoardGame 
JOIN [Boardgame-Depo] ON [Boardgame-Depo].gameId = BoardGame.gameId
JOIN Depo ON Depo.depoId = [Boardgame-Depo].depoId
JOIN [Supplier-Depo] ON Depo.depoId = [Supplier-Depo].depoId;


SELECT BoardGame.name AS boardgame_in_any_depo
FROM BoardGame
WHERE BoardGame.gameId = ANY (
	SELECT  [Boardgame-Depo].gameId
    FROM [Boardgame-Depo]
    JOIN Depo ON Depo.depoId = [Boardgame-Depo].depoId
)


SELECT Customer.name, SUM(BoardGame.price * [Order].amount) AS Total_price
FROM [Order] 
JOIN [Order-Boardgame] ON [Order].orderId = [Order-Boardgame].orderId
JOIN BoardGame on [Order-Boardgame].gameId = BoardGame.gameId
RIGHT JOIN Customer on [Order].customerId = Customer.customerId
GROUP BY Customer.customerId, Customer.name
ORDER BY Total_price DESC


SELECT factoryName
FROM Factory
WHERE factoryLocation LIKE 'Romania%'
UNION
SELECT FactoryName
FROM Factory
WHERE factoryLocation LIKE 'Germany%'

SELECT BoardGame.name AS ordered_or_deposited_games
FROM BoardGame
WHERE BoardGame.gameId IN (SELECT gameId
					FROM [Boardgame-Depo])
OR
gameId IN (SELECT gameId
FROM [Order-Boardgame])


SELECT [Order].customerId
FROM [Order]
JOIN [Order-Boardgame] ON [Order].orderId = [Order-Boardgame].orderId
JOIN BoardGame ON [Order-Boardgame].gameId = BoardGame.gameId
GROUP BY [Order].customerId
HAVING COUNT(BoardGame.gameId) = (SELECT COUNT(*) FROM BoardGame)

-- corectat
SELECT BoardGame.name
FROM BoardGame
WHERE BoardGame.price > ALL (SELECT BoardGame.price
							FROM BoardGame
							WHERE BoardGame.type = 'Family')
