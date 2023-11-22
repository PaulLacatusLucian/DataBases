CREATE PROCEDURE changeColumnType(
    @tableName varchar(50),
    @columnName varchar(50),
    @newDataType varchar(50)
)
AS
BEGIN
    DECLARE @sqlQuery as varchar(MAX)

    DECLARE @oldDataType NVARCHAR(50);
    SELECT @oldDataType = DATA_TYPE
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = @tableName AND COLUMN_NAME = @columnName;

    UPDATE aktuallVersion SET versionNumber = versionNumber + 1;

    INSERT INTO versions (FunctionName, Param1, Param2, Param3, Param4)
    VALUES ('changeColumnType', @tableName, @columnName, @newDataType, @oldDataType);

    SET @sqlQuery = 'ALTER TABLE ' + @tableName + ' ALTER COLUMN ' + @columnName + ' ' + @newDataType
    EXECUTE (@sqlQuery);
END;


CREATE PROCEDURE rollbackchangeColumnType(
    @tableName varchar(50),
    @columnName varchar(50),
    @newDataType varchar(50)
)
AS
BEGIN
    DECLARE @sqlQuery as varchar(MAX)

    UPDATE aktuallVersion SET versionNumber = versionNumber - 1;

    SET @sqlQuery = 'ALTER TABLE ' + @tableName + ' ALTER COLUMN ' + @columnName + ' ' + @newDataType
    EXECUTE (@sqlQuery);
END;




CREATE PROCEDURE addDefaultConstraintToColumn(
    @tableName varchar(50),
    @columnName varchar(50),
    @defaultConstraint varchar(MAX)
)
AS
BEGIN
    DECLARE @sqlQuery AS varchar(MAX)

    IF EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @tableName AND COLUMN_NAME = @columnName
    )
    BEGIN
		UPDATE aktuallVersion SET versionNumber = versionNumber + 1;

		INSERT INTO versions (FunctionName, Param1, Param2, Param3)
        VALUES ('addDefaultConstraintToColumn', @tableName, @columnName, @defaultConstraint);

        SET @sqlQuery = 'ALTER TABLE ' + @tableName + ' ADD CONSTRAINT DF_' + @columnName + ' DEFAULT ' + @defaultConstraint + ' FOR ' + @columnName
        EXECUTE (@sqlQuery)
    END
	ELSE 
	BEGIN 
		PRINT 'Column does not exist'
	END
END;
GO

CREATE PROCEDURE addDefaultConstraintToColumn1(
    @tableName varchar(50),
    @columnName varchar(50),
    @defaultConstraint varchar(MAX)
)
AS
BEGIN
    DECLARE @sqlQuery AS varchar(MAX)

    IF EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @tableName AND COLUMN_NAME = @columnName
    )
    BEGIN
	    INSERT INTO versions (FunctionName, Param1, Param2, Param3)
        VALUES ('addDefaultConstraintToColumn1', @tableName, @columnName, @defaultConstraint);
        IF DATALENGTH(@defaultConstraint) IS NOT NULL
        BEGIN
            SET @defaultConstraint = '''' + REPLACE(@defaultConstraint, '''', '''''') + ''''  
        END
        SET @sqlQuery = 'ALTER TABLE ' + @tableName + ' ADD CONSTRAINT DF_' + @columnName + ' DEFAULT ' + @defaultConstraint + ' FOR ' + @columnName
        EXECUTE (@sqlQuery)
		UPDATE aktuallVersion SET versionNumber = versionNumber + 1;

    END
    ELSE 
    BEGIN 
        PRINT 'Column does not exist'
    END
END;
GO




CREATE PROCEDURE rollBackaddDefaultConstraintToColumn(
    @tableName varchar(50),
    @columnName varchar(50)
)
AS
BEGIN
    DECLARE @sqlQuery AS varchar(MAX)

    IF EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @tableName AND COLUMN_NAME = @columnName
    )
    BEGIN
		UPDATE aktuallVersion SET versionNumber = versionNumber - 1;
        SET @sqlQuery = 'ALTER TABLE ' + @tableName + ' DROP CONSTRAINT DF_' + @columnName
        EXECUTE (@sqlQuery)
    END
	ELSE 
	BEGIN 
		PRINT 'Column does not exist'
	END
END;
GO


CREATE PROCEDURE createTable(
    @tableName varchar(50),
    @columnDefinitions varchar(MAX),
    @primaryKeyColumnName varchar(50)
)
AS
BEGIN
    DECLARE @sqlQuery AS varchar(MAX)
	UPDATE aktuallVersion SET versionNumber = versionNumber + 1;

	INSERT INTO versions (FunctionName, Param1, Param2, Param3)
    VALUES ('createTable', @tableName, @columnDefinitions, @primaryKeyColumnName);

    SET @sqlQuery = 'CREATE TABLE ' + @tableName + ' (' + @columnDefinitions + ', PRIMARY KEY (' + @primaryKeyColumnName + '))'
    EXECUTE (@sqlQuery)
END;
GO


CREATE PROCEDURE rollBackCreateTable(
    @tableName varchar(50)
)
AS
BEGIN
    DECLARE @sqlQuery AS varchar(MAX)
	UPDATE aktuallVersion SET versionNumber = versionNumber - 1;
    SET @sqlQuery = 'DROP TABLE IF EXISTS ' + @tableName
    EXECUTE (@sqlQuery)
END;
GO

CREATE PROCEDURE addColumnToTable(
    @tableName varchar(50),
    @columnName varchar(50),
    @columnDataType varchar(50)
)
AS
BEGIN
        DECLARE @sqlQuery AS varchar(MAX)
		UPDATE aktuallVersion SET versionNumber = versionNumber + 1;
		INSERT INTO versions (FunctionName, Param1, Param2, Param3)
        VALUES ('addColumnToTable', @tableName, @columnName, @columnDataType);

        SET @sqlQuery = 'ALTER TABLE ' + @tableName + ' ADD ' + @columnName + ' ' + @columnDataType
        EXECUTE (@sqlQuery)
END;
GO


CREATE PROCEDURE rollBackaddColumnToTable
(
    @tableName varchar(50),
    @columnName varchar(50)
)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = @columnName)
    BEGIN
        DECLARE @sqlQuery AS varchar(MAX)
		UPDATE aktuallVersion SET versionNumber = versionNumber - 1;
        SET @sqlQuery = 'ALTER TABLE ' + @tableName + ' DROP COLUMN ' + @columnName
        EXEC (@sqlQuery)
    END
    ELSE
    BEGIN
        PRINT 'Column does not exist'
    END
END;
GO

CREATE PROCEDURE addForeignKeyConstraint(
    @tableName varchar(50), 
    @columnName varchar(50),
    @referencedTable varchar(50),
    @referencedColumn varchar(50)
)
AS
BEGIN
    DECLARE @sqlQuery AS varchar(MAX)
		UPDATE aktuallVersion SET versionNumber = versionNumber + 1;		
		
		INSERT INTO versions (FunctionName, Param1, Param2, Param3, Param4)
        VALUES ('addForeignKeyConstraint', @tableName, @columnName, @referencedTable, @referencedColumn);

        SET @sqlQuery = 'ALTER TABLE ' + @tableName + ' ADD CONSTRAINT FK_' + @columnName + '_' + @referencedTable +
                        ' FOREIGN KEY (' + @columnName + ') REFERENCES ' + @referencedTable + '(' + @referencedColumn + ')'
	   EXECUTE (@sqlQuery)
END;
GO


CREATE PROCEDURE rollBackaddForeignKeyConstraint(
    @tableName varchar(50),
    @constraintName varchar(100),
	@referencedTableName varchar(100)
)
AS
BEGIN
    DECLARE @sqlQuery AS varchar(MAX)

    IF EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @tableName
    )
    BEGIN
	   UPDATE aktuallVersion SET versionNumber = versionNumber - 1;
       SET @sqlQuery = 'ALTER TABLE ' + @tableName + ' DROP CONSTRAINT FK_' + @constraintName +'_' +@referencedTableName
       EXECUTE (@sqlQuery)
    END
    ELSE 
    BEGIN 
        PRINT 'Table does not exist'
    END
END;
GO

DROP Procedure addForeignKeyConstraint


CREATE TABLE aktuallVersion (
    versionNumber INT PRIMARY KEY
);
INSERT INTO aktuallVersion
VALUES (0)

CREATE TABLE versions (
    versionId INT IDENTITY(1,1) PRIMARY KEY,
    FunctionName VARCHAR(100),
    Param1 VARCHAR(MAX) DEFAULT NULL,
    Param2 VARCHAR(MAX) DEFAULT NULL,
    Param3 VARCHAR(MAX) DEFAULT NULL,
	Param4 VARCHAR(MAX) DEFAULT NULL
);
GO

CREATE PROCEDURE universalRollbackToVersion
    @targetVersion INT
AS
BEGIN
    DECLARE @currentVersion INT;

    SELECT @currentVersion = versionNumber FROM aktuallVersion;

    WHILE @currentVersion <> @targetVersion
    BEGIN
        DECLARE @functionName VARCHAR(100),
                @tableName NVARCHAR(255),
                @param1 NVARCHAR(255),
                @param2 NVARCHAR(255),
                @param3 NVARCHAR(255);

        IF @currentVersion > @targetVersion
        BEGIN
            SELECT TOP 1
                @functionName = FunctionName,
                @tableName = Param1,
                @param1 = Param2,
                @param2 = Param3,
                @param3 = Param4
            FROM versions
            WHERE versionId = @currentVersion;

            IF @functionName = 'addDefaultConstraintToColumn1'
            BEGIN
                EXEC rollbackaddDefaultConstraintToColumn @tableName, @param1;
            END
            ELSE IF @functionName = 'createTable'
            BEGIN
                EXEC rollbackcreateTable @tableName;
            END
            ELSE IF @functionName = 'addColumnToTable'
            BEGIN
                EXEC rollbackaddColumnToTable @tableName, @param1;
            END
            ELSE IF @functionName = 'changeColumnType'
            BEGIN
                DECLARE @originalDataType NVARCHAR(50);
                SELECT @originalDataType = @param3
                FROM versions
                WHERE versionId = @currentVersion;

                EXEC rollbackchangeColumnType @tableName, @param1, @originalDataType;
            END
            ELSE IF @functionName = 'addForeignKeyConstraint'
            BEGIN
                EXEC rollbackaddForeignKeyConstraint @tableName, @param1, @param2;
            END

            SET @currentVersion = @currentVersion - 1;
        END
        ELSE IF @currentVersion < @targetVersion
        BEGIN
            SELECT TOP 1
                @functionName = FunctionName,
                @tableName = Param1,
                @param1 = Param2,
                @param2 = Param3,
                @param3 = Param4
            FROM versions
            WHERE versionId = @currentVersion + 1;

            IF @functionName = 'addDefaultConstraintToColumn1'
            BEGIN
                EXEC addDefaultConstraintToColumn1 @tableName, @param1, @param2;
				DELETE FROM versions 
				WHERE versionId = (SELECT TOP 1 versionId FROM versions ORDER BY versionId DESC);
            END
            ELSE IF @functionName = 'createTable'
            BEGIN
                EXEC createTable @tableName, @param1, @param2;
				DELETE FROM versions 
				WHERE versionId = (SELECT TOP 1 versionId FROM versions ORDER BY versionId DESC);
            END
            ELSE IF @functionName = 'addColumnToTable'
            BEGIN
                EXEC addColumnToTable @tableName, @param1, @param2;
				DELETE FROM versions 
				WHERE versionId = (SELECT TOP 1 versionId FROM versions ORDER BY versionId DESC);
            END
            ELSE IF @functionName = 'changeColumnType'
            BEGIN
                DECLARE @newDataType NVARCHAR(50);
                SELECT @newDataType = Param3
                FROM versions
                WHERE versionId = @targetVersion;

                EXEC changeColumnType @tableName, @param1, @newDataType;
				DELETE FROM versions 
				WHERE versionId = (SELECT TOP 1 versionId FROM versions ORDER BY versionId DESC);
            END
            ELSE IF @functionName = 'CreateForeignKeyConstraint'
            BEGIN
                EXEC addForeignKeyConstraint @tableName, @param1, @param2, @param1;
				DELETE FROM versions 
				WHERE versionId = (SELECT TOP 1 versionId FROM versions ORDER BY versionId DESC);
            END

            SET @currentVersion = @currentVersion + 1;
        END
    END
END;





DROP TABLE aktuallVersion
drop table versions
drop table T1
DROP TABLE T2
DROP PROCEDURE universalRollbackToVersion


EXEC createTable 'T1', 'id int, nume varchar(50)', 'nume'
EXEC addColumnToTable 'T1', 'rating', 'int'
EXEC changeColumnType 'T1', 'id', 'varchar(50)'
EXEC addDefaultConstraintToColumn1 'T1', 'nume', 'test'
EXEC addDefaultConstraintToColumn1 'T1', 'rating', '0'

EXEC createTable 'T2', 'id int', 'id'
EXEC addColumnToTable 'T2', 'nume', 'varchar(50)'
EXEC addForeignKeyConstraint 'T2', 'nume', 'T1', 'nume'

EXEC universalRollbackToVersion 6
EXEC universalRollbackToVersion 7
EXEC universalRollbackToVersion 5
EXEC universalRollbackToVersion 0
EXEC universalRollbackToVersion 8
EXEC universalRollbackToVersion 4








EXEC rollBackChangeColumnType 'Ex1', 'String', 'varchar(1)'
EXEC rollBackAddColumnToTable 'Ex1', 'String'
EXEC rollBackAddDefaultConstraintToColumn 'Ex1', 'Numar'
EXEC rollBackCreateTable 'Ex1'


 EXEC changeColumnType 'TestDelete', 'Column3', 'int'
EXEC rollBackchangeColumnType 'Test', 'test_var', 'real'



--rezolvat
EXEC addDefaultConstraintToColumn1 'TestDelete', 'Column2', 'test';
EXEC rollBackaddDefaultConstraintToColumn 'TestCreate', 'Column1'

EXEC createTable 'TestDelete', 'Column1 int, Column2 varchar(50), Column3 real', 'Column1';
EXEC rollBackcreateTable 'TestDelete'

EXEC addColumnToTable 'TestDelete', 'TestCreateAddColumn', 'int'
EXEC rollBackaddColumnToTable 'Test', 'TestCreateAddColumn'

EXEC addForeignKeyConstraint 'TestCreate', 'Column3', 'Test', 'Column3'
EXEC rollBackaddForeignKeyConstraint 'TestCreate', 'FK_Column3_Test'

DROP PROCEDURE addColumnToTable
DROP PROCEDURE addDefaultConstraintToColumn1
DROP PROCEDURE addForeignKeyConstraint
DROP PROCEDURE createTable
DROP PROCEDURE addDefaultConstraintToColumn