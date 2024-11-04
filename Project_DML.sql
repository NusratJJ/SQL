-- ID:1284630_DML
--Name:Nusrat jahan Jisa

USE DonationDB
GO

-- SECTION 02: Insert Records
INSERT INTO Donation_T (DonationNo, DonorFName, DonorLName, Amount, DonationDate)
VALUES ('DN01', 'Peter', 'Mark', 200, '2019-08-01'), 
       ('DN02', 'Victor', 'Gomez', 100, '2019-08-05')
GO

INSERT INTO Collector_T (CollectorID, CollectedBy) 
VALUES (1, 'Jhon Doe'), (2, 'Joseph Hardy'), (3, 'James Kaarry')
GO

INSERT INTO Project_T (ProjectID, ProjectName, ProjectDescription) 
VALUES (1, 'Solar Scholars', 'Powering schools with solar energy'), 
       (2, 'Creek Cleanup', 'Cleaning up litter from the creek'), 
       (3, 'Forest Asia', 'Planting trees in Asia')
GO

INSERT INTO DonationManagement_T (DM_ID, DonationNo, CollectorID, ProjectID) 
VALUES (1, 'DN01', 1, 1), (2, 'DN02', 2, 2), (3, 'DN02', 3, 3)
GO

-- SECTION 03: Delete Query
DELETE FROM Donation_T WHERE DonationNo = 'DN01'
GO

-- SECTION 04: Update Query
UPDATE Donation_T SET Amount = 250 WHERE DonationNo = 'DN02'
GO

-- SECTION 07: Join with Group By and Having Clause
SELECT D.DonorFName, D.DonorLName, SUM(D.Amount) AS TotalDonation
FROM Donation_T D
JOIN DonationManagement_T DM ON D.DonationNo = DM.DonationNo
GROUP BY D.DonorFName, D.DonorLName
HAVING SUM(D.Amount) > 100
GO

-- SECTION 08: Sub-query for Donor Victor Gomez
SELECT * FROM Donation_T D
WHERE D.DonorFName = 'Victor' AND D.DonorLName = 'Gomez'
GO

-- SECTION 15: Transaction Statement
BEGIN TRANSACTION
    UPDATE Donation_T SET Amount = 300 WHERE DonationNo = 'DN02'
COMMIT TRANSACTION
GO

-- SECTION 16: Error Handling for Question 5 (Deleting Table)
BEGIN TRY
    DROP TABLE Donation_T
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ErrorMessage, ERROR_NUMBER() AS ErrorNumber;
END CATCH
GO

-- SECTION 18: Simple CASE and Search CASE
SELECT DonationNo 
    CASE 
        WHEN Amount > 200 THEN 'Large Donation'
        WHEN Amount BETWEEN 100 AND 200 THEN 'Medium Donation'
        ELSE 'Small Donation'
    END AS DonationCategory
FROM Donation_T
GO

-- SECTION 19: Create a Cursor to Insert Data
DECLARE @DonationNo VARCHAR(5), @DonorFName VARCHAR(20), @DonorLName VARCHAR(20)

DECLARE DonationCursor CURSOR FOR
SELECT DonationNo, DonorFName, DonorLName FROM Donation_T;

OPEN DonationCursor

FETCH NEXT FROM DonationCursor INTO @DonationNo, @DonorFName, @DonorLName;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT @DonationNo + ' ' + @DonorFName + ' ' + @DonorLName;
    FETCH NEXT FROM DonationCursor INTO @DonationNo, @DonorFName, @DonorLName
END

CLOSE DonationCursor
DEALLOCATE DonationCursor
GO

-- SECTION 20: NTILE Function
SELECT DonationNo, DonorFName, DonorLName, 
       NTILE(2) OVER (ORDER BY Amount) AS Rank2,
       NTILE(3) OVER (ORDER BY Amount) AS Rank3,
       NTILE(4) OVER (ORDER BY Amount) AS Rank4
FROM Donation_T
GO

-- SECTION 22.1: Retrieve records from Purchase_T between 2023-01-03 and 2023-03-01
SELECT * FROM Purchase_T
WHERE PurchaseDate BETWEEN '2023-01-03' AND '2023-03-01'
GO

-- SECTION 22.2: Retrieve Customer_T records where CustomerFName starts with 'J'
SELECT * FROM Customer_T
WHERE CustomerFName LIKE 'J%'
GO

-- SECTION 22.3: Retrieve Customer_T records where CustomerFName contains one of 'j', 'f', 'd', 's', 'l'
SELECT * FROM Customer_T
WHERE CustomerFName LIKE '[jfdsl]%'
GO

-- SECTION 22.4: Find Car_T where CarModelName starts with 'A' and next letter is between 'A' and 'J'
SELECT * FROM Car_T
WHERE CarModelName LIKE 'A[A-J]%'
GO

-- SECTION 22.5: Find Car_T where CarModelName starts with 'A' and next letter is not 'O' through 'R'
SELECT * FROM Car_T
WHERE CarModelName LIKE 'A[^O-R]%'
GO

-- SECTION 22.6: Retrieve 2nd and 3rd records from Purchase_T
SELECT * FROM Purchase_T
ORDER BY PurchaseID
OFFSET 1 ROWS FETCH NEXT 2 ROWS ONLY
GO

-- SECTION 22.7: CUBE Operator
SELECT ProductID, ProductName, SUM(Quantity)
FROM Sales_T
GROUP BY CUBE(ProductID, ProductName)
GO

-- SECTION 22.8: ROLLUP Operator
SELECT ProductID, ProductName, SUM(Quantity)
FROM Sales_T
GROUP BY ROLLUP(ProductID, ProductName)
GO

-- SECTION 22.9: Grouping Sets Operator
SELECT ProductID, ProductName, SUM(Quantity)
FROM Sales_T
GROUP BY GROUPING SETS ((ProductID), (ProductName))
GO

-- SECTION 22.10: ANY Operator
SELECT * FROM Purchase_T
WHERE Amount > ANY (SELECT Amount FROM Purchase_T WHERE CustomerID = 101)
GO

-- SECTION 22.11: ALL Operator
SELECT * FROM Purchase_T
WHERE Amount > ALL (SELECT Amount FROM Purchase_T WHERE CustomerID = 101)
GO

-- SECTION 22.12: SOME Operator
SELECT * FROM Purchase_T
WHERE Amount > SOME (SELECT Amount FROM Purchase_T WHERE CustomerID = 101)
GO

-- SECTION 22.13: OVER Clause
SELECT PurchaseID, Amount, 
    SUM(Amount) OVER (ORDER BY PurchaseDate) AS RunningTotal
FROM Purchase_T
GO

-- SECTION 22.14: Subquery
SELECT * FROM Customer_T
WHERE CustomerID IN (SELECT CustomerID FROM Purchase_T WHERE Amount > 500)
GO

-- SECTION 22.15: EXISTS Clause
SELECT * FROM Customer_T
WHERE EXISTS (SELECT 1 FROM Purchase_T WHERE Customer_T.CustomerID = Purchase_T.CustomerID)
GO

-- SECTION 22.16: Group Query to retrieve average amount
SELECT CustomerID, AVG(Amount) AS AvgAmount
FROM Purchase_T
GROUP BY CustomerID
HAVING AVG(Amount) > 1000
GO
