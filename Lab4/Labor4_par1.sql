CREATE TABLE Movies (
    movieId INT PRIMARY KEY,
    movieName VARCHAR(255),
    genre NVARCHAR(50),
    ageRestriction INT,
    director NVARCHAR(100)
);

CREATE FUNCTION checkAgeRestriction(
    @genre NVARCHAR(50),
    @ageRestriction INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @isValid BIT = 1

    IF @genre = 'Horror' AND (@ageRestriction IS NULL OR @ageRestriction < 18)
        SET @isValid = 0

    RETURN @isValid
END;

CREATE FUNCTION checkMovieName(
    @movieName VARCHAR(255)
)
RETURNS BIT
AS
BEGIN
    DECLARE @isValid BIT = 1 

    IF @movieName LIKE '%Hate%' OR
       @movieName LIKE '%Violence%' OR
       @movieName LIKE '%Drugs%' OR
       @movieName LIKE '%Sexual%' OR
       @movieName LIKE '%Discrimination%' OR
       @movieName LIKE '%Offensive%' OR
       @movieName LIKE '%Obscene%'
    BEGIN
        SET @isValid = 0
    END

    RETURN @isValid
END;


CREATE PROCEDURE insertData
    @movieId INT,
    @movieName VARCHAR(255),
    @genre NVARCHAR(50),
    @ageRestriction INT,
    @director NVARCHAR(100)
AS
BEGIN
    IF dbo.checkMovieName(@movieName) = 0
    BEGIN
        PRINT 'Inappropriate name! The movie name cannot contain words like Hate, Violence, Drugs, Sexual, Discrimination, Offensive, Obscene.'
        RETURN
    END

    IF dbo.checkAgeRestriction(@genre, @ageRestriction) = 0
    BEGIN
        PRINT 'Inappropriate age restriction. Horror movies should not be attended by people under 18!'
        RETURN
    END

    INSERT INTO Movies (movieId, movieName, genre, ageRestriction, director)
    VALUES (@movieId, @movieName, @genre, @ageRestriction, @director)

    PRINT 'Data added successfully.'
END
GO

DELETE FROM Movies
EXEC insertData 1, 'Movie1', 'Horror', 18, 'Director1';
EXEC insertData 2, 'Movie2', 'Horror', 12, 'Director2';
EXEC insertData 3, 'Drugs and Vegas', 'Action', 18, 'Director3';

