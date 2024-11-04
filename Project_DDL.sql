-- ID:1284630_DDL
--Name:Nusrat Jahan Jisa

-- SECTION 01: Create a 3NF Database with Data and Log Files
CREATE DATABASE DonationDB
ON 
(
    NAME = 'DonationDB_Data_1',
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\DonationDB_Data_1.mdf',
    SIZE = 25MB,
    MAXSIZE = 100MB,
    FILEGROWTH = 5%
)
LOG ON 
(
    NAME = 'DonationDB_Log_1',
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\DonationDB_Log_1.ldf',
    SIZE = 2MB,
    MAXSIZE = 25MB,
    FILEGROWTH = 1%
)
GO

USE DonationDB
GO

-- SECTION 02: Create Tables
CREATE TABLE Donation_T (
    DonationNo VARCHAR(5) PRIMARY KEY,
    DonorFName VARCHAR(20),
    DonorLName VARCHAR(20),
    Amount DECIMAL(10, 2),
    DonationDate DATE
)
GO

CREATE TABLE Collector_T (
    CollectorID INT PRIMARY KEY,
    CollectedBy VARCHAR(20)
)
GO

CREATE TABLE Project_T (
    ProjectID INT PRIMARY KEY,
    ProjectName VARCHAR(20),
    ProjectDescription VARCHAR(50)
)
GO

CREATE TABLE DonationManagement_T (
    DM_ID INT PRIMARY KEY,
    DonationNo VARCHAR(5) REFERENCES Donation_T(DonationNo),
    CollectorID INT REFERENCES Collector_T(CollectorID),
    ProjectID INT REFERENCES Project_T(ProjectID)
)
GO

-- SECTION 05: Script to delete a table
DROP TABLE DonationManagement_T
GO

-- SECTION 06: Script to delete a column
ALTER TABLE Donation_T
DROP COLUMN Amount
GO

-- SECTION 09: Create a view for Donor Victor Gomez
CREATE VIEW vwVictorGomezDonations
AS
SELECT D.DonationNo, D.DonorFName, D.DonorLName, D.DonationDate, 
       C.CollectedBy, P.ProjectName, P.ProjectDescription
FROM Donation_T D
JOIN DonationManagement_T DM ON D.DonationNo = DM.DonationNo
JOIN Collector_T C ON DM.CollectorID = C.CollectorID
JOIN Project_T P ON DM.ProjectID = P.ProjectID
WHERE D.DonorFName = 'Victor' AND D.DonorLName = 'Gomez'
GO

-- SECTION 10: Create a stored procedure to insert, update, and delete data
CREATE PROCEDURE spManageDonation
    @Functionality VARCHAR(10),
    @DonationNo VARCHAR(5),
    @DonorFName VARCHAR(20),
    @DonorLName VARCHAR(20),
    @Amount DECIMAL(10,2),
    @DonationDate DATE
AS
BEGIN
    IF @Functionality = 'INSERT'
    BEGIN
        INSERT INTO Donation_T (DonationNo, DonorFName, DonorLName, Amount, DonationDate)
        VALUES (@DonationNo, @DonorFName, @DonorLName, @Amount, @DonationDate)
    END
    ELSE IF @Functionality = 'UPDATE'
    BEGIN
        UPDATE Donation_T
        SET DonorFName = @DonorFName, DonorLName = @DonorLName, Amount = @Amount, DonationDate = @DonationDate
        WHERE DonationNo = @DonationNo
    END
    ELSE IF @Functionality = 'DELETE'
    BEGIN
        DELETE FROM Donation_T WHERE DonationNo = @DonationNo;
    END
END;
GO

-- SECTION 11: Create a Clustered Index
CREATE CLUSTERED INDEX idx_DonationDate ON Donation_T(DonationDate)
GO

-- SECTION 12: Create a Scalar Function to calculate the Next Visit Date
CREATE FUNCTION fnNextVisitDate(@DonationDate DATE)
RETURNS DATE
AS
BEGIN
    RETURN DATEADD(MONTH, 3, @DonationDate)
END;
GO

-- SECTION 13: Create a Table-Valued Function for Owner-wise Pet Information
CREATE FUNCTION fnGetOwnerWisePetInfo()
RETURNS TABLE
AS
RETURN (
    SELECT OwnerID, OwnerName, PetName FROM Pet_T
)
GO

-- SECTION 14: Create a Trigger for Insert, Update, and Delete on Donation_T
CREATE TRIGGER trgDonationAudit
ON Donation_T
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    INSERT INTO AuditLog (ActionType, DonationNo, ActionDate)
    SELECT 'INSERT', DonationNo, GETDATE() FROM inserted
    
    INSERT INTO AuditLog (ActionType, DonationNo, ActionDate)
    SELECT 'DELETE', DonationNo, GETDATE() FROM deleted
END;
GO

-- SECTION 17: Create a CTE
WITH DonorCTE AS (
    SELECT DonorFName, DonorLName, SUM(Amount) AS TotalDonation
    FROM Donation_T
    GROUP BY DonorFName, DonorLName
)
SELECT * FROM DonorCTE
GO

-- SECTION 21: Create a New Table and Use MERGE
CREATE TABLE DonationArchive_T (
    DonationNo VARCHAR(5),
    DonorFName VARCHAR(20),
    DonorLName VARCHAR(20),
    Amount DECIMAL(10, 2),
    DonationDate DATE
)
GO

MERGE DonationArchive_T AS target
USING Donation_T AS source
ON target.DonationNo = source.DonationNo
WHEN MATCHED THEN
    UPDATE SET target.Amount = source.Amount
WHEN NOT MATCHED BY TARGET THEN
    INSERT (DonationNo, DonorFName, DonorLName, Amount, DonationDate)
    VALUES (source.DonationNo, source.DonorFName, source.DonorLName, source.Amount, source.DonationDate);

